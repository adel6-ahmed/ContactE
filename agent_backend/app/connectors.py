"""Platform connectors. They are called only from code paths the user confirmed
(never directly by the model). Each uses the platform's official REST API with the
user's own access token; if no account is connected, the drafts connector returns
text the app hands to the native share sheet instead of publishing.

API shapes (keep in sync with the platform docs; versions are configurable):
- Meta Graph API: Facebook Page feed posts, Instagram content publishing
  (create media container -> media_publish), comment replies.
- LinkedIn Posts API (/rest/posts) with versioned headers.
- X API v2 POST /2/tweets (needs a user-context OAuth 2.0 token).
"""
from __future__ import annotations

import httpx

from .config import Settings


class ConnectorError(RuntimeError):
    """Publishing failed; the message is safe to show to the user (no tokens)."""


class DraftsConnector:
    mode = "drafts"

    def publish_post(self, platform: str, account: dict | None, text: str, media_url: str | None) -> dict:
        share = text if not media_url else f"{text}\n\n{media_url}"
        return {"mode": "drafts", "share_text": share,
                "note": f"No {platform} account is connected: the app opens the share sheet with this text."}

    def reply(self, platform: str, account: dict | None, target_id: str, text: str) -> dict:
        return {"mode": "drafts", "share_text": text,
                "note": "No account is connected: copy this reply and post it in the app."}

    def recent_comments(self, platform: str, account: dict | None, limit: int = 10) -> list[dict]:
        return []


class ApiConnector:
    mode = "api"

    def __init__(self, settings: Settings, client: httpx.Client | None = None):
        self.s = settings
        self.http = client or httpx.Client(timeout=20.0)

    # ------------------------------------------------------------ helpers
    def _check(self, r: httpx.Response, platform: str) -> dict:
        if r.status_code >= 400:
            try:
                msg = r.json()
                msg = msg.get("error", {}).get("message") or msg.get("detail") or msg.get("message") or r.text
            except ValueError:
                msg = r.text
            raise ConnectorError(f"{platform} rejected the request (HTTP {r.status_code}): {str(msg)[:200]}")
        return r.json() if r.content else {}

    def _graph(self, path: str) -> str:
        return f"https://graph.facebook.com/{self.s.meta_graph_version}/{path.lstrip('/')}"

    # ------------------------------------------------------------ publish
    def publish_post(self, platform: str, account: dict, text: str, media_url: str | None) -> dict:
        token, extra = account["token"], account["extra"]
        if platform == "facebook":
            page = extra["page_id"]
            data = {"message": text, "access_token": token}
            if media_url:
                data["link"] = media_url
            body = self._check(self.http.post(self._graph(f"{page}/feed"), data=data), "Facebook")
            return {"mode": "api", "id": body.get("id")}
        if platform == "instagram":
            ig = extra["ig_user_id"]
            container = self._check(self.http.post(self._graph(f"{ig}/media"),
                                                   data={"image_url": media_url, "caption": text, "access_token": token}),
                                    "Instagram")
            body = self._check(self.http.post(self._graph(f"{ig}/media_publish"),
                                              data={"creation_id": container["id"], "access_token": token}),
                               "Instagram")
            return {"mode": "api", "id": body.get("id")}
        if platform == "linkedin":
            r = self.http.post("https://api.linkedin.com/rest/posts", headers={
                "Authorization": f"Bearer {token}", "LinkedIn-Version": self.s.linkedin_version,
                "X-Restli-Protocol-Version": "2.0.0", "Content-Type": "application/json"},
                json={"author": extra["author_urn"], "commentary": text, "visibility": "PUBLIC",
                      "distribution": {"feedDistribution": "MAIN_FEED", "targetEntities": [],
                                       "thirdPartyDistributionChannels": []},
                      "lifecycleState": "PUBLISHED", "isReshareDisabledByAuthor": False})
            self._check(r, "LinkedIn")
            return {"mode": "api", "id": r.headers.get("x-restli-id")}
        if platform == "x":
            body = self._check(self.http.post("https://api.x.com/2/tweets",
                                              headers={"Authorization": f"Bearer {token}"}, json={"text": text}), "X")
            return {"mode": "api", "id": (body.get("data") or {}).get("id")}
        raise ConnectorError(f"unsupported platform {platform}")

    def reply(self, platform: str, account: dict, target_id: str, text: str) -> dict:
        token = account["token"]
        if platform == "instagram":
            body = self._check(self.http.post(self._graph(f"{target_id}/replies"),
                                              data={"message": text, "access_token": token}), "Instagram")
        elif platform == "facebook":
            body = self._check(self.http.post(self._graph(f"{target_id}/comments"),
                                              data={"message": text, "access_token": token}), "Facebook")
        elif platform == "x":
            body = self._check(self.http.post("https://api.x.com/2/tweets", headers={"Authorization": f"Bearer {token}"},
                                              json={"text": text, "reply": {"in_reply_to_tweet_id": target_id}}), "X")
            body = body.get("data") or {}
        else:
            raise ConnectorError(f"replies are not supported on {platform}")
        return {"mode": "api", "id": body.get("id")}

    # ------------------------------------------------------------ read
    def recent_comments(self, platform: str, account: dict, limit: int = 10) -> list[dict]:
        token, extra = account["token"], account["extra"]
        if platform == "instagram":
            body = self._check(self.http.get(self._graph(f"{extra['ig_user_id']}/media"), params={
                "fields": "id,caption,comments.limit(5){id,text,username,timestamp}", "limit": 5,
                "access_token": token}), "Instagram")
            out = []
            for media in body.get("data", []):
                for c in (media.get("comments") or {}).get("data", []):
                    out.append({"id": c["id"], "author": c.get("username"), "text": c.get("text"),
                                "on": (media.get("caption") or "")[:80], "at": c.get("timestamp")})
            return out[:limit]
        if platform == "facebook":
            body = self._check(self.http.get(self._graph(f"{extra['page_id']}/feed"), params={
                "fields": "id,message,comments.limit(5){id,message,from,created_time}", "limit": 5,
                "access_token": token}), "Facebook")
            out = []
            for post in body.get("data", []):
                for c in (post.get("comments") or {}).get("data", []):
                    out.append({"id": c["id"], "author": (c.get("from") or {}).get("name"), "text": c.get("message"),
                                "on": (post.get("message") or "")[:80], "at": c.get("created_time")})
            return out[:limit]
        return []  # LinkedIn and X comment reading need extra API access; not supported yet


REQUIRED_EXTRA = {"facebook": ("page_id",), "instagram": ("ig_user_id",), "linkedin": ("author_urn",), "x": ()}
