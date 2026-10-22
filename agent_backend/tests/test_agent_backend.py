"""Backend tests: platform rules, the agent loop (with a scripted fake model), the
confirm-only publishing path, connectors (mocked HTTP), auth and the scheduler."""
import json
from datetime import datetime, timedelta, timezone
from types import SimpleNamespace as NS

import httpx
import pytest
from cryptography.fernet import Fernet
from fastapi.testclient import TestClient

from app.agent import Agent
from app.config import Settings
from app.connectors import ApiConnector
from app.main import create_app
from app.platforms import RuleViolation, validate_post, validate_reply
from app.store import Store

KEY = Fernet.generate_key().decode()
FUTURE = (datetime.now(timezone.utc) + timedelta(days=2)).isoformat(timespec="seconds")


# ------------------------------------------------------------------ helpers
def text(t):
    return NS(type="text", text=t)


def tool(name, args, tid="tu_1"):
    return NS(type="tool_use", name=name, input=args, id=tid)


class FakeLLM:
    """Returns scripted responses and records every request."""

    def __init__(self, *responses):
        self.responses = list(responses)
        self.calls = []

    def create(self, *, system, messages, tools):
        self.calls.append({"system": system, "messages": [dict(m) for m in messages], "tools": tools})
        return self.responses.pop(0)


def resp(stop, *blocks):
    return NS(stop_reason=stop, content=list(blocks))


class Recorder:
    """httpx MockTransport that records requests and answers like the platform APIs."""

    def __init__(self):
        self.requests = []

    def __call__(self, request: httpx.Request) -> httpx.Response:
        self.requests.append(request)
        url = str(request.url)
        if url.endswith("/media"):
            return httpx.Response(200, json={"id": "container_1"})
        if url.endswith("/media_publish"):
            return httpx.Response(200, json={"id": "ig_post_1"})
        if url.endswith("/feed") and request.method == "POST":
            return httpx.Response(200, json={"id": "page_post_1"})
        if "api.linkedin.com" in url:
            return httpx.Response(201, headers={"x-restli-id": "urn:li:share:1"})
        if "api.x.com" in url:
            return httpx.Response(201, json={"data": {"id": "tweet_1"}})
        if url.endswith("/replies") or url.endswith("/comments"):
            return httpx.Response(200, json={"id": "reply_1"})
        if "/media?" in url or "/media" in request.url.path:
            return httpx.Response(200, json={"data": []})
        return httpx.Response(404, json={"error": {"message": "unexpected call"}})


@pytest.fixture
def env(tmp_path):
    settings = Settings(auth_mode="dev", database_path=str(tmp_path / "t.sqlite3"),
                        token_encryption_key=KEY, cron_secret="cron-secret-123")
    store = Store(settings.database_path, KEY)
    rec = Recorder()
    api = ApiConnector(settings, httpx.Client(transport=httpx.MockTransport(rec)))

    def make(llm):
        agent = Agent(store, llm, api)
        client = TestClient(create_app(settings, store, agent), headers={"X-Dev-User": "user_a"})
        return client, agent

    return NS(settings=settings, store=store, rec=rec, make=make)


# ------------------------------------------------------------ platform rules
def test_rules_enforced_in_code():
    validate_post("x", "short post")
    with pytest.raises(RuleViolation, match="280"):
        validate_post("x", "a" * 281)
    with pytest.raises(RuleViolation, match="image or video"):
        validate_post("instagram", "caption without media")
    with pytest.raises(RuleViolation, match="hashtags"):
        validate_post("instagram", " ".join(f"#t{i}" for i in range(31)), "https://cdn.example.com/a.jpg")
    with pytest.raises(RuleViolation, match="https"):
        validate_post("facebook", "hi", "http://insecure.example.com/a.jpg")
    with pytest.raises(RuleViolation, match="past"):
        validate_post("x", "hi", scheduled_for=datetime(2020, 1, 1, tzinfo=timezone.utc))
    with pytest.raises(RuleViolation, match="not supported"):
        validate_reply("linkedin", "thanks", "c1")


# ------------------------------------------------------------------ agent
def test_agent_drafts_but_never_publishes(env):
    llm = FakeLLM(
        resp("tool_use", tool("list_accounts", {}, "t1")),
        resp("tool_use", tool("propose_post", {"platform": "x", "text": "Launching ContactE 2.0 🚀"}, "t2"),
             tool("propose_post", {"platform": "linkedin", "text": "We are launching ContactE 2.0."}, "t3")),
        resp("end_turn", text("Two drafts are ready for your confirmation.")),
    )
    client, _ = env.make(llm)
    r = client.post("/agent/chat", json={"message": "Announce our launch on X and LinkedIn"})
    assert r.status_code == 200
    body = r.json()
    assert [p["platform"] for p in body["proposals"]] == ["x", "linkedin"]
    assert all(p["status"] == "pending" for p in body["proposals"])
    assert env.rec.requests == []  # nothing was sent to any platform
    # both tool results went back in ONE user message
    results = llm.calls[2]["messages"][-1]["content"]
    assert [x["tool_use_id"] for x in results] == ["t2", "t3"]


def test_rule_violation_goes_back_to_the_model_as_error(env):
    llm = FakeLLM(
        resp("tool_use", tool("propose_post", {"platform": "x", "text": "a" * 300}, "t1")),
        resp("tool_use", tool("propose_post", {"platform": "x", "text": "Shorter version"}, "t2")),
        resp("end_turn", text("Done.")),
    )
    client, _ = env.make(llm)
    body = client.post("/agent/chat", json={"message": "post this"}).json()
    first_result = llm.calls[1]["messages"][-1]["content"][0]
    assert first_result["is_error"] is True and "280" in first_result["content"]
    assert len(body["proposals"]) == 1 and body["proposals"][0]["text"] == "Shorter version"


def test_history_is_passed_and_refusal_is_handled(env):
    llm = FakeLLM(resp("refusal"))
    client, _ = env.make(llm)
    r = client.post("/agent/chat", json={"message": "and now?", "history": [
        {"role": "user", "content": "hi"}, {"role": "assistant", "content": "hello"}, {"role": "system", "content": "x"}]})
    assert r.json()["stop"] == "refusal"
    sent = llm.calls[0]["messages"]
    assert [m["role"] for m in sent] == ["user", "assistant", "user"]  # system turn from the client is dropped


def test_provider_outage_returns_503(env):
    class Down:
        def create(self, **_):
            raise TimeoutError("provider down")

    client, _ = env.make(Down())
    assert client.post("/agent/chat", json={"message": "hi"}).status_code == 503


# ------------------------------------------------- confirm / publish paths
def text_(t):
    return NS(type="text", text=t)


def test_confirm_without_account_returns_share_text(env):
    client, _ = env.make(FakeLLM(resp("tool_use", tool("propose_post", {"platform": "x", "text": "Hello world"})),
                                 resp("end_turn", text_("ok"))))
    pid = client.post("/agent/chat", json={"message": "x"}).json()["proposals"][0]["id"]
    r = client.post(f"/proposals/{pid}/confirm")
    assert r.status_code == 200 and r.json()["status"] == "shared"
    assert r.json()["result"]["share_text"] == "Hello world"
    assert env.rec.requests == []
    assert client.post(f"/proposals/{pid}/confirm").status_code == 409  # cannot confirm twice


def test_confirm_publishes_with_connected_instagram(env):
    client, _ = env.make(FakeLLM(
        resp("tool_use", tool("propose_post", {"platform": "instagram", "text": "New collection",
                                               "media_url": "https://cdn.example.com/p.jpg"})),
        resp("end_turn", text_("ok"))))
    assert client.post("/accounts/instagram", json={"handle": "@shop", "access_token": "IGTOKEN-1234567",
                                                    "ig_user_id": "1784"}).status_code == 201
    pid = client.post("/agent/chat", json={"message": "x"}).json()["proposals"][0]["id"]
    r = client.post(f"/proposals/{pid}/confirm")
    assert r.json()["status"] == "published" and r.json()["result"]["id"] == "ig_post_1"
    paths = [req.url.path for req in env.rec.requests]
    assert paths == ["/v21.0/1784/media", "/v21.0/1784/media_publish"]
    assert "IGTOKEN" not in json.dumps(client.get("/accounts").json())  # tokens never returned


def test_x_and_linkedin_publish_shapes(env):
    client, agent = env.make(FakeLLM())
    client.post("/accounts/x", json={"handle": "@me", "access_token": "XTOKEN-12345678"})
    client.post("/accounts/linkedin", json={"handle": "me", "access_token": "LITOKEN-1234567",
                                            "author_urn": "urn:li:person:abc"})
    for platform in ("x", "linkedin"):
        p = env.store.create_proposal("user_a", "post", platform, "Hello")
        assert client.post(f"/proposals/{p['id']}/confirm").json()["status"] == "published"
    li = next(r for r in env.rec.requests if "linkedin" in str(r.url))
    assert li.headers["LinkedIn-Version"] == "202410" and json.loads(li.content)["author"] == "urn:li:person:abc"
    x = next(r for r in env.rec.requests if "api.x.com" in str(r.url))
    assert x.headers["Authorization"] == "Bearer XTOKEN-12345678"


def test_platform_error_marks_failed_without_leaking_token(env):
    def fail(request):
        return httpx.Response(400, json={"error": {"message": "Invalid OAuth access token"}})

    settings = env.settings
    api = ApiConnector(settings, httpx.Client(transport=httpx.MockTransport(fail)))
    agent = Agent(env.store, FakeLLM(), api)
    client = TestClient(create_app(settings, env.store, agent), headers={"X-Dev-User": "user_a"})
    client.post("/accounts/x", json={"handle": "@me", "access_token": "SECRET-TOKEN-999"})
    p = env.store.create_proposal("user_a", "post", "x", "Hello")
    r = client.post(f"/proposals/{p['id']}/confirm")
    assert r.status_code == 502 and "SECRET-TOKEN" not in r.text
    assert env.store.proposal("user_a", p["id"])["status"] == "failed"


def test_edit_revalidates_and_reject(env):
    client, _ = env.make(FakeLLM())
    p = env.store.create_proposal("user_a", "post", "x", "Hello")
    assert client.patch(f"/proposals/{p['id']}", json={"text": "b" * 400}).status_code == 422
    assert client.patch(f"/proposals/{p['id']}", json={"text": "Edited"}).json()["text"] == "Edited"
    assert client.post(f"/proposals/{p['id']}/reject").json()["status"] == "rejected"
    assert client.patch(f"/proposals/{p['id']}", json={"text": "late"}).status_code == 409


def test_users_cannot_see_each_others_drafts(env):
    client, _ = env.make(FakeLLM())
    p = env.store.create_proposal("user_b", "post", "x", "B's draft")
    assert client.get("/proposals").json() == []
    assert client.post(f"/proposals/{p['id']}/confirm").status_code == 404


# ------------------------------------------------------- schedule & cron
def test_scheduled_post_waits_for_cron(env):
    client, _ = env.make(FakeLLM())
    p = env.store.create_proposal("user_a", "post", "x", "Later", scheduled_for=FUTURE)
    assert client.post(f"/proposals/{p['id']}/confirm").json()["status"] == "scheduled"
    assert client.post("/scheduler/run-due").status_code == 401
    assert client.post("/scheduler/run-due", headers={"X-Cron-Secret": "wrong"}).status_code == 401
    assert client.post("/scheduler/run-due", headers={"X-Cron-Secret": "cron-secret-123"}).json()["published"] == []
    env.store.update_proposal("user_a", p["id"], scheduled_for="2020-01-01T00:00:00+00:00")
    done = client.post("/scheduler/run-due", headers={"X-Cron-Secret": "cron-secret-123"}).json()["published"]
    assert done == [p["id"]] and env.store.proposal("user_a", p["id"])["status"] == "shared"


# ------------------------------------------------------------------- auth
def test_auth_required_and_dev_mode_local_only(env):
    client, _ = env.make(FakeLLM())
    assert TestClient(client.app).get("/accounts").status_code == 401
    prod = Settings(auth_mode="firebase", database_path=env.settings.database_path, token_encryption_key=KEY)
    pc = TestClient(create_app(prod, env.store, Agent(env.store, FakeLLM(), None)))
    assert pc.get("/accounts", headers={"Authorization": "Bearer not-a-real-token"}).status_code == 401
    assert pc.get("/accounts", headers={"X-Dev-User": "user_a"}).status_code == 401


def test_tokens_encrypted_at_rest(env):
    env.store.save_account("user_a", "x", "@me", "PLAINTEXT-TOKEN", {})
    raw = env.store._db.execute("SELECT token_enc FROM accounts").fetchone()[0]
    assert b"PLAINTEXT-TOKEN" not in raw
    assert env.store.account_with_token("user_a", "x")["token"] == "PLAINTEXT-TOKEN"
