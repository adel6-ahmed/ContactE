"""Who is calling? The Flutter app sends the signed-in user's Firebase ID token as
`Authorization: Bearer <token>`; we verify it against Google's public keys, so no
service-account key is needed. AUTH_MODE=dev accepts `X-Dev-User` for local runs only."""
from fastapi import Header, HTTPException, Request

from .config import Settings


def make_current_user(settings: Settings):
    def current_user(request: Request, authorization: str | None = Header(default=None),
                     x_dev_user: str | None = Header(default=None)) -> str:
        if settings.auth_mode == "dev":
            host = request.client.host if request.client else ""
            if host not in {"127.0.0.1", "::1", "localhost", "testclient"} and not settings.allow_dev_auth_on_non_local:
                raise HTTPException(status_code=401, detail="dev auth is only allowed from localhost")
            if not x_dev_user:
                raise HTTPException(status_code=401, detail="missing X-Dev-User header")
            return x_dev_user
        if not authorization or not authorization.lower().startswith("bearer "):
            raise HTTPException(status_code=401, detail="missing bearer token")
        token = authorization.split(" ", 1)[1].strip()
        try:
            from google.auth.transport import requests as g_requests
            from google.oauth2 import id_token

            claims = id_token.verify_firebase_token(token, g_requests.Request(), audience=settings.firebase_project_id)
        except Exception as e:  # invalid, expired, wrong project, or network failure fetching keys
            raise HTTPException(status_code=401, detail="invalid or expired sign-in") from e
        if not claims or not claims.get("sub"):
            raise HTTPException(status_code=401, detail="invalid sign-in")
        return claims["sub"]

    return current_user
