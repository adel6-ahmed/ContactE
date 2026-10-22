"""SQLite storage: proposals waiting for the user's confirmation, connected accounts
(access tokens encrypted at rest with Fernet) and an append-only audit log."""
from __future__ import annotations

import json
import os
import sqlite3
import threading
import uuid
from datetime import datetime, timezone

from cryptography.fernet import Fernet

SCHEMA = """
CREATE TABLE IF NOT EXISTS accounts (
  user_id TEXT NOT NULL, platform TEXT NOT NULL, handle TEXT NOT NULL,
  token_enc BLOB NOT NULL, extra TEXT NOT NULL DEFAULT '{}', connected_at TEXT NOT NULL,
  PRIMARY KEY (user_id, platform)
);
CREATE TABLE IF NOT EXISTS proposals (
  id TEXT PRIMARY KEY, user_id TEXT NOT NULL, kind TEXT NOT NULL, platform TEXT NOT NULL,
  text TEXT NOT NULL, media_url TEXT, target_id TEXT, scheduled_for TEXT,
  status TEXT NOT NULL, result TEXT, created_at TEXT NOT NULL, updated_at TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS proposals_user ON proposals(user_id, status);
CREATE TABLE IF NOT EXISTS audit (
  id INTEGER PRIMARY KEY AUTOINCREMENT, user_id TEXT NOT NULL, event TEXT NOT NULL,
  detail TEXT NOT NULL, at TEXT NOT NULL
);
"""

# pending -> (confirmed: published | scheduled -> published | shared) ; pending -> rejected ; any send -> failed
STATUSES = ("pending", "scheduled", "published", "shared", "rejected", "failed")


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


class Store:
    def __init__(self, path: str, encryption_key: str):
        if path != ":memory:":
            os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
        if not encryption_key:
            raise RuntimeError("TOKEN_ENCRYPTION_KEY is not set (generate one with Fernet.generate_key())")
        self._fernet = Fernet(encryption_key.encode() if isinstance(encryption_key, str) else encryption_key)
        self._db = sqlite3.connect(path, check_same_thread=False)
        self._db.row_factory = sqlite3.Row
        self._lock = threading.Lock()
        with self._lock:
            self._db.executescript(SCHEMA)

    # ---------------------------------------------------------------- audit
    def audit(self, user_id: str, event: str, **detail) -> None:
        with self._lock:
            self._db.execute("INSERT INTO audit(user_id,event,detail,at) VALUES (?,?,?,?)",
                             (user_id, event, json.dumps(detail, ensure_ascii=False), now_iso()))
            self._db.commit()

    def audit_log(self, user_id: str, limit: int = 100) -> list[dict]:
        rows = self._db.execute("SELECT event, detail, at FROM audit WHERE user_id=? ORDER BY id DESC LIMIT ?",
                                (user_id, limit)).fetchall()
        return [{"event": r["event"], "detail": json.loads(r["detail"]), "at": r["at"]} for r in rows]

    # ------------------------------------------------------------- accounts
    def save_account(self, user_id: str, platform: str, handle: str, token: str, extra: dict) -> None:
        enc = self._fernet.encrypt(token.encode())
        with self._lock:
            self._db.execute(
                "INSERT INTO accounts VALUES (?,?,?,?,?,?) ON CONFLICT(user_id,platform) DO UPDATE SET "
                "handle=excluded.handle, token_enc=excluded.token_enc, extra=excluded.extra, connected_at=excluded.connected_at",
                (user_id, platform, handle, enc, json.dumps(extra), now_iso()))
            self._db.commit()
        self.audit(user_id, "account_connected", platform=platform, handle=handle)

    def remove_account(self, user_id: str, platform: str) -> bool:
        with self._lock:
            cur = self._db.execute("DELETE FROM accounts WHERE user_id=? AND platform=?", (user_id, platform))
            self._db.commit()
        if cur.rowcount:
            self.audit(user_id, "account_disconnected", platform=platform)
        return bool(cur.rowcount)

    def accounts(self, user_id: str) -> list[dict]:
        rows = self._db.execute("SELECT platform, handle, extra, connected_at FROM accounts WHERE user_id=?",
                                (user_id,)).fetchall()
        return [{"platform": r["platform"], "handle": r["handle"], "extra": json.loads(r["extra"]),
                 "connected_at": r["connected_at"]} for r in rows]

    def account_with_token(self, user_id: str, platform: str) -> dict | None:
        r = self._db.execute("SELECT * FROM accounts WHERE user_id=? AND platform=?", (user_id, platform)).fetchone()
        if not r:
            return None
        return {"platform": r["platform"], "handle": r["handle"], "extra": json.loads(r["extra"]),
                "token": self._fernet.decrypt(r["token_enc"]).decode()}

    # ------------------------------------------------------------ proposals
    def create_proposal(self, user_id: str, kind: str, platform: str, text: str, media_url: str | None = None,
                        target_id: str | None = None, scheduled_for: str | None = None) -> dict:
        pid = "prp_" + uuid.uuid4().hex[:16]
        ts = now_iso()
        with self._lock:
            self._db.execute("INSERT INTO proposals VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
                             (pid, user_id, kind, platform, text, media_url, target_id, scheduled_for,
                              "pending", None, ts, ts))
            self._db.commit()
        self.audit(user_id, "proposal_created", id=pid, kind=kind, platform=platform)
        return self.proposal(user_id, pid)

    def proposal(self, user_id: str, pid: str) -> dict | None:
        r = self._db.execute("SELECT * FROM proposals WHERE id=? AND user_id=?", (pid, user_id)).fetchone()
        return _proposal(r) if r else None

    def proposals(self, user_id: str, status: str | None = None) -> list[dict]:
        q, args = "SELECT * FROM proposals WHERE user_id=?", [user_id]
        if status:
            q, args = q + " AND status=?", args + [status]
        return [_proposal(r) for r in self._db.execute(q + " ORDER BY created_at DESC", args).fetchall()]

    def update_proposal(self, user_id: str, pid: str, **fields) -> dict:
        allowed = {"text", "media_url", "scheduled_for", "status", "result"}
        sets = {k: (json.dumps(v, ensure_ascii=False) if k == "result" and v is not None else v)
                for k, v in fields.items() if k in allowed}
        sets["updated_at"] = now_iso()
        cols = ", ".join(f"{k}=?" for k in sets)
        with self._lock:
            self._db.execute(f"UPDATE proposals SET {cols} WHERE id=? AND user_id=?", [*sets.values(), pid, user_id])
            self._db.commit()
        return self.proposal(user_id, pid)

    def due_scheduled(self, now: str) -> list[dict]:
        rows = self._db.execute("SELECT * FROM proposals WHERE status='scheduled' AND scheduled_for<=?",
                                (now,)).fetchall()
        return [_proposal(r) for r in rows]


def _proposal(r: sqlite3.Row) -> dict:
    d = dict(r)
    d["result"] = json.loads(d["result"]) if d["result"] else None
    return d
