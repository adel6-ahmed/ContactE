"""Per-platform publishing rules, enforced in code before anything is proposed or published.

The model is told these limits, but the code decides: a draft that breaks a rule is rejected
with a reason the model can act on.
"""
from dataclasses import dataclass
from datetime import datetime, timezone
import re

PLATFORMS = ("instagram", "facebook", "linkedin", "x")


@dataclass(frozen=True)
class PlatformRules:
    name: str
    max_chars: int
    max_hashtags: int | None
    requires_media: bool
    supports_replies: bool


RULES: dict[str, PlatformRules] = {
    "instagram": PlatformRules("Instagram", 2200, 30, True, True),
    "facebook": PlatformRules("Facebook Page", 63206, None, False, True),
    "linkedin": PlatformRules("LinkedIn", 3000, None, False, False),
    "x": PlatformRules("X", 280, None, False, True),
}

HASHTAG = re.compile(r"(?<!\w)#\w+", re.UNICODE)


class RuleViolation(ValueError):
    """A draft that the platform would reject; the message explains how to fix it."""


def validate_post(platform: str, text: str, media_url: str | None = None,
                  scheduled_for: datetime | None = None, now: datetime | None = None) -> None:
    if platform not in RULES:
        raise RuleViolation(f"unknown platform '{platform}'; use one of {', '.join(PLATFORMS)}")
    rules = RULES[platform]
    text = (text or "").strip()
    if not text:
        raise RuleViolation("the post text is empty")
    if len(text) > rules.max_chars:
        raise RuleViolation(f"{rules.name} allows {rules.max_chars} characters; this draft has {len(text)}")
    if rules.max_hashtags is not None:
        tags = len(HASHTAG.findall(text))
        if tags > rules.max_hashtags:
            raise RuleViolation(f"{rules.name} allows {rules.max_hashtags} hashtags; this draft has {tags}")
    if rules.requires_media and not media_url:
        raise RuleViolation(f"{rules.name} posts need an image or video URL (media_url)")
    if media_url and not media_url.startswith("https://"):
        raise RuleViolation("media_url must be a public https:// URL")
    if scheduled_for is not None:
        now = now or datetime.now(timezone.utc)
        if scheduled_for.tzinfo is None:
            raise RuleViolation("scheduled_for must include a timezone, e.g. 2026-11-01T09:00:00+00:00")
        if scheduled_for <= now:
            raise RuleViolation("scheduled_for is in the past")


def validate_reply(platform: str, text: str, target_id: str) -> None:
    if platform not in RULES:
        raise RuleViolation(f"unknown platform '{platform}'")
    rules = RULES[platform]
    if not rules.supports_replies:
        raise RuleViolation(f"replying to comments is not supported on {rules.name} through its API")
    if not (target_id or "").strip():
        raise RuleViolation("target_id (the comment or post to reply to) is required")
    text = (text or "").strip()
    if not text:
        raise RuleViolation("the reply text is empty")
    limit = min(rules.max_chars, 2200)
    if len(text) > limit:
        raise RuleViolation(f"replies on {rules.name} are limited to {limit} characters")


def rules_summary() -> str:
    lines = []
    for key, r in RULES.items():
        extra = []
        if r.requires_media:
            extra.append("needs an image/video URL")
        if r.max_hashtags:
            extra.append(f"max {r.max_hashtags} hashtags")
        if not r.supports_replies:
            extra.append("no comment replies")
        lines.append(f"- {key}: max {r.max_chars} characters" + (f"; {'; '.join(extra)}" if extra else ""))
    return "\n".join(lines)
