"""Settings, read once from the environment (see .env.example)."""
import os
from dataclasses import dataclass, field


def _bool(name: str, default: bool = False) -> bool:
    return os.getenv(name, str(default)).strip().lower() in {"1", "true", "yes"}


@dataclass(frozen=True)
class Settings:
    # Claude
    claude_model: str = field(default_factory=lambda: os.getenv("CLAUDE_MODEL", "claude-opus-5-5"))
    claude_effort: str = field(default_factory=lambda: os.getenv("CLAUDE_EFFORT", "low"))
    agent_max_steps: int = field(default_factory=lambda: int(os.getenv("AGENT_MAX_STEPS", "8")))

    # Auth: "firebase" verifies Firebase ID tokens; "dev" trusts an X-Dev-User header (local only).
    auth_mode: str = field(default_factory=lambda: os.getenv("AUTH_MODE", "firebase"))
    firebase_project_id: str = field(default_factory=lambda: os.getenv("FIREBASE_PROJECT_ID", "contacte-b2228"))

    # Storage
    database_path: str = field(default_factory=lambda: os.getenv("DATABASE_PATH", "data/agent.sqlite3"))
    token_encryption_key: str = field(default_factory=lambda: os.getenv("TOKEN_ENCRYPTION_KEY", ""))

    # Scheduler endpoint protection (called by a cron job)
    cron_secret: str = field(default_factory=lambda: os.getenv("CRON_SECRET", ""))

    # Platform API versions (they change; keep them configurable)
    meta_graph_version: str = field(default_factory=lambda: os.getenv("META_GRAPH_VERSION", "v21.0"))
    linkedin_version: str = field(default_factory=lambda: os.getenv("LINKEDIN_VERSION", "202410"))

    allow_dev_auth_on_non_local: bool = field(default_factory=lambda: _bool("ALLOW_DEV_AUTH_ON_NON_LOCAL"))


def get_settings() -> Settings:
    return Settings()
