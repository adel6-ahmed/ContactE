"""HTTP API for the ContactE social-media agent.

Run:  uvicorn app.main:app --port 8090   (from agent_backend/, with a .env — see .env.example)
"""
from __future__ import annotations

import hmac
from datetime import datetime, timezone

try:  # load agent_backend/.env when present
    from dotenv import load_dotenv

    load_dotenv()
except ImportError:
    pass

from fastapi import Depends, FastAPI, Header, HTTPException
from pydantic import BaseModel, Field

from .agent import Agent, ClaudeLLM, _parse_time
from .auth import make_current_user
from .config import Settings, get_settings
from .connectors import REQUIRED_EXTRA, ApiConnector, ConnectorError
from .platforms import PLATFORMS, RuleViolation, validate_post
from .store import Store, now_iso


class ChatTurn(BaseModel):
    role: str
    content: str = Field(max_length=4000)


class ChatIn(BaseModel):
    message: str = Field(min_length=1, max_length=2000)
    history: list[ChatTurn] = Field(default_factory=list, max_length=20)


class ConnectIn(BaseModel):
    handle: str = Field(min_length=1, max_length=100)
    access_token: str = Field(min_length=10)
    page_id: str | None = None
    ig_user_id: str | None = None
    author_urn: str | None = None


class EditIn(BaseModel):
    text: str | None = Field(default=None, max_length=63206)
    media_url: str | None = None
    scheduled_for: str | None = None


class ConfirmIn(BaseModel):
    publish_now: bool = False  # ignore a suggested schedule and publish immediately


def create_app(settings: Settings | None = None, store: Store | None = None, agent: Agent | None = None) -> FastAPI:
    settings = settings or get_settings()
    store = store or Store(settings.database_path, settings.token_encryption_key)
    agent = agent or Agent(store, ClaudeLLM(settings.claude_model, settings.claude_effort),
                           ApiConnector(settings), settings.agent_max_steps)
    current_user = make_current_user(settings)
    app = FastAPI(title="ContactE agent", version="1.0")

    def own(user: str, pid: str) -> dict:
        p = store.proposal(user, pid)
        if not p:
            raise HTTPException(status_code=404, detail="not found")
        return p

    @app.get("/health")
    def health():
        return {"status": "ok", "model": settings.claude_model}

    # ------------------------------------------------------------ accounts
    @app.get("/accounts")
    def accounts(user: str = Depends(current_user)):
        connected = {a["platform"]: a for a in store.accounts(user)}
        return [{"platform": p, "connected": p in connected, "handle": connected.get(p, {}).get("handle"),
                 "mode": "api" if p in connected else "drafts"} for p in PLATFORMS]

    @app.post("/accounts/{platform}", status_code=201)
    def connect(platform: str, body: ConnectIn, user: str = Depends(current_user)):
        if platform not in PLATFORMS:
            raise HTTPException(status_code=404, detail="unknown platform")
        extra = {k: getattr(body, k) for k in ("page_id", "ig_user_id", "author_urn") if getattr(body, k)}
        missing = [k for k in REQUIRED_EXTRA[platform] if k not in extra]
        if missing:
            raise HTTPException(status_code=422, detail=f"{platform} needs: {', '.join(missing)}")
        store.save_account(user, platform, body.handle, body.access_token, extra)
        return {"platform": platform, "connected": True, "handle": body.handle}

    @app.delete("/accounts/{platform}", status_code=204)
    def disconnect(platform: str, user: str = Depends(current_user)):
        store.remove_account(user, platform)

    # --------------------------------------------------------------- agent
    @app.post("/agent/chat")
    def chat(body: ChatIn, user: str = Depends(current_user)):
        try:
            return agent.chat(user, body.message, [t.model_dump() for t in body.history])
        except HTTPException:
            raise
        except Exception as e:  # provider outage, timeout, bad key
            store.audit(user, "agent_error", error=type(e).__name__)
            raise HTTPException(status_code=503, detail="the assistant is unavailable right now") from e

    # ----------------------------------------------------------- proposals
    @app.get("/proposals")
    def proposals(status: str | None = None, user: str = Depends(current_user)):
        return store.proposals(user, status)

    @app.patch("/proposals/{pid}")
    def edit(pid: str, body: EditIn, user: str = Depends(current_user)):
        p = own(user, pid)
        if p["status"] != "pending":
            raise HTTPException(status_code=409, detail="only pending drafts can be edited")
        text = body.text if body.text is not None else p["text"]
        media = body.media_url if body.media_url is not None else p["media_url"]
        when = _parse_time(body.scheduled_for) if body.scheduled_for else _parse_time(p["scheduled_for"])
        try:
            if p["kind"] == "post":
                validate_post(p["platform"], text, media, when)
        except RuleViolation as e:
            raise HTTPException(status_code=422, detail=str(e)) from e
        store.audit(user, "proposal_edited", id=pid)
        return store.update_proposal(user, pid, text=text, media_url=media,
                                     scheduled_for=when.isoformat() if when else None)

    @app.post("/proposals/{pid}/reject")
    def reject(pid: str, user: str = Depends(current_user)):
        p = own(user, pid)
        if p["status"] != "pending":
            raise HTTPException(status_code=409, detail=f"draft is already {p['status']}")
        store.audit(user, "proposal_rejected", id=pid)
        return store.update_proposal(user, pid, status="rejected")

    @app.post("/proposals/{pid}/confirm")
    def confirm(pid: str, body: ConfirmIn | None = None, user: str = Depends(current_user)):
        """The only path that publishes or sends — called when the user taps Confirm."""
        p = own(user, pid)
        if p["status"] != "pending":
            raise HTTPException(status_code=409, detail=f"draft is already {p['status']}")
        publish_now = bool(body and body.publish_now)
        if p["scheduled_for"] and not publish_now and _parse_time(p["scheduled_for"]) > datetime.now(timezone.utc):
            store.audit(user, "proposal_scheduled", id=pid, at=p["scheduled_for"])
            return store.update_proposal(user, pid, status="scheduled")
        return _send(user, p)

    def _send(user: str, p: dict) -> dict:
        try:
            result = agent.execute(user, p)
        except (RuleViolation, ConnectorError) as e:
            store.audit(user, "publish_failed", id=p["id"], platform=p["platform"], error=str(e))
            store.update_proposal(user, p["id"], status="failed", result={"error": str(e)})
            raise HTTPException(status_code=502, detail=str(e)) from e
        status = "published" if result.get("mode") == "api" else "shared"
        store.audit(user, "proposal_" + status, id=p["id"], platform=p["platform"], post_id=result.get("id"))
        return store.update_proposal(user, p["id"], status=status, result=result)

    # ----------------------------------------------------------- scheduler
    @app.post("/scheduler/run-due")
    def run_due(x_cron_secret: str | None = Header(default=None)):
        if not settings.cron_secret or not x_cron_secret or not hmac.compare_digest(x_cron_secret, settings.cron_secret):
            raise HTTPException(status_code=401, detail="unauthorized")
        done = []
        for p in store.due_scheduled(now_iso()):
            try:
                done.append(_send(p["user_id"], p)["id"])
            except HTTPException:
                continue  # recorded as failed
        return {"published": done}

    @app.get("/audit")
    def audit(user: str = Depends(current_user)):
        return store.audit_log(user)

    return app


try:
    app = create_app()
except RuntimeError:  # missing TOKEN_ENCRYPTION_KEY when imported without a .env (e.g. by tests)
    app = None
