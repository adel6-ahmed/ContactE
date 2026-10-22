"""The social-media agent: Claude with tool calling over the user's own accounts.

Design rule: the model drafts, code decides, the user confirms.
- Every tool here is read-only or creates a *pending* proposal. No tool publishes.
- Proposals are validated against platform rules in code before they are stored.
- Publishing happens only through POST /proposals/{id}/confirm, which the app calls
  when the user taps Confirm (see main.py).
"""
from __future__ import annotations

import json
from datetime import datetime
from typing import Any, Protocol

from .connectors import ApiConnector, ConnectorError, DraftsConnector
from .platforms import PLATFORMS, RULES, RuleViolation, rules_summary, validate_post, validate_reply
from .store import Store

SYSTEM_PROMPT = """You are Bradi (برادي), the assistant inside ContactE, a contact and networking app.
You help the signed-in user manage their own social media accounts: plan content, write posts,
adapt one idea for several platforms, schedule posts, read recent comments and draft replies.

How you work:
- You never publish or send anything yourself. propose_post and propose_reply only create drafts
  that wait in the user's "Pending" list; the user reviews, edits and confirms each one in the app.
  Never say a post is published or scheduled — say it is ready for their confirmation.
- Platform limits are enforced in code. If a tool returns an error, fix the draft and try again.
- Check list_accounts before planning: a platform that is not connected still gets drafts, which the
  user shares from the app themselves.
- Reply in the user's language (Arabic, French, English or Turkish). Keep answers short and concrete.
- Write plain text for a phone chat bubble: no Markdown (no **, #, tables); use "•" for short lists.
- Do not invent statistics, follower counts or comments. Use get_recent_comments for real comments.
- Do not write content that impersonates someone else, misleads, or targets a private person.

Platform rules:
{rules}
"""

TOOLS: list[dict] = [
    {
        "name": "list_accounts",
        "description": "List the user's social platforms and whether each is connected for direct publishing "
                       "(mode 'api') or will be shared manually from drafts (mode 'drafts').",
        "input_schema": {"type": "object", "properties": {}, "additionalProperties": False},
    },
    {
        "name": "get_recent_comments",
        "description": "Read recent comments on the user's latest posts on a connected Instagram or Facebook "
                       "account. Returns an empty list when the platform is not connected or not supported.",
        "input_schema": {"type": "object", "properties": {
            "platform": {"type": "string", "enum": list(PLATFORMS)},
            "limit": {"type": "integer", "minimum": 1, "maximum": 20}},
            "required": ["platform"], "additionalProperties": False},
    },
    {
        "name": "propose_post",
        "description": "Create a draft post for one platform. It is NOT published: it waits for the user's "
                       "confirmation. Call once per platform. Use scheduled_for (ISO 8601 with timezone) to "
                       "suggest a publishing time.",
        "input_schema": {"type": "object", "properties": {
            "platform": {"type": "string", "enum": list(PLATFORMS)},
            "text": {"type": "string"},
            "media_url": {"type": "string", "description": "Public https URL of an image or video, if any."},
            "scheduled_for": {"type": "string", "description": "e.g. 2026-11-01T09:00:00+03:00"}},
            "required": ["platform", "text"], "additionalProperties": False},
    },
    {
        "name": "propose_reply",
        "description": "Create a draft reply to a comment (target_id from get_recent_comments). It is NOT sent "
                       "until the user confirms.",
        "input_schema": {"type": "object", "properties": {
            "platform": {"type": "string", "enum": list(PLATFORMS)},
            "target_id": {"type": "string"},
            "text": {"type": "string"}},
            "required": ["platform", "target_id", "text"], "additionalProperties": False},
    },
    {
        "name": "list_pending",
        "description": "List drafts that are still waiting for the user's confirmation.",
        "input_schema": {"type": "object", "properties": {}, "additionalProperties": False},
    },
]


class LLM(Protocol):
    def create(self, *, system: str, messages: list[dict], tools: list[dict]) -> Any: ...


class ClaudeLLM:
    """Claude through the official SDK. Thinking is adaptive (always on for this model);
    effort is set explicitly; refused requests fall back server-side by refusal category."""

    def __init__(self, model: str, effort: str):
        import anthropic  # imported lazily so tests do not need the SDK

        self.client = anthropic.Anthropic(timeout=60.0, max_retries=2)
        self.model, self.effort = model, effort

    def create(self, *, system: str, messages: list[dict], tools: list[dict]) -> Any:
        return self.client.beta.messages.create(
            model=self.model,
            max_tokens=16000,
            system=system,
            messages=messages,
            tools=tools,
            output_config={"effort": self.effort},
            betas=["server-side-fallback-2026-07-01"],
            fallbacks="default",
        )


class Agent:
    def __init__(self, store: Store, llm: LLM, api: ApiConnector, max_steps: int = 8):
        self.store, self.llm, self.api, self.max_steps = store, llm, api, max_steps
        self.drafts = DraftsConnector()

    # ------------------------------------------------------------------ tools
    def _run_tool(self, user_id: str, name: str, args: dict, created: list[dict]) -> tuple[str, bool]:
        try:
            if name == "list_accounts":
                connected = {a["platform"]: a for a in self.store.accounts(user_id)}
                return json.dumps([{"platform": p, "name": RULES[p].name,
                                    "mode": "api" if p in connected else "drafts",
                                    "handle": connected[p]["handle"] if p in connected else None}
                                   for p in PLATFORMS], ensure_ascii=False), False
            if name == "get_recent_comments":
                account = self.store.account_with_token(user_id, args["platform"])
                if not account:
                    return json.dumps({"comments": [], "note": "platform not connected"}), False
                comments = self.api.recent_comments(args["platform"], account, int(args.get("limit", 10)))
                return json.dumps({"comments": comments}, ensure_ascii=False), False
            if name == "propose_post":
                when = _parse_time(args.get("scheduled_for"))
                validate_post(args["platform"], args["text"], args.get("media_url"), when)
                p = self.store.create_proposal(user_id, "post", args["platform"], args["text"].strip(),
                                               media_url=args.get("media_url"),
                                               scheduled_for=when.isoformat() if when else None)
                created.append(p)
                return json.dumps({"proposal_id": p["id"], "status": "pending_user_confirmation"}), False
            if name == "propose_reply":
                validate_reply(args["platform"], args["text"], args["target_id"])
                p = self.store.create_proposal(user_id, "reply", args["platform"], args["text"].strip(),
                                               target_id=args["target_id"])
                created.append(p)
                return json.dumps({"proposal_id": p["id"], "status": "pending_user_confirmation"}), False
            if name == "list_pending":
                return json.dumps([{"id": p["id"], "platform": p["platform"], "kind": p["kind"], "text": p["text"][:120]}
                                   for p in self.store.proposals(user_id, "pending")], ensure_ascii=False), False
            return f"Error: unknown tool {name}", True
        except (RuleViolation, ValueError, KeyError) as e:
            return f"Error: {e}", True
        except ConnectorError as e:
            return f"Error: {e}", True

    # ------------------------------------------------------------------- loop
    def chat(self, user_id: str, message: str, history: list[dict] | None = None) -> dict:
        system = SYSTEM_PROMPT.format(rules=rules_summary())
        messages = [m for m in (history or []) if m.get("role") in ("user", "assistant") and m.get("content")]
        messages.append({"role": "user", "content": message})
        created: list[dict] = []
        self.store.audit(user_id, "agent_chat", chars=len(message))

        for _ in range(self.max_steps):
            response = self.llm.create(system=system, messages=messages, tools=TOOLS)
            stop = getattr(response, "stop_reason", None)
            if stop == "refusal":
                return {"reply": "I can't help with that request.", "proposals": created, "stop": "refusal"}
            tool_uses = [b for b in response.content if getattr(b, "type", None) == "tool_use"]
            if stop != "tool_use" or not tool_uses:
                text = "\n".join(b.text for b in response.content if getattr(b, "type", None) == "text").strip()
                if stop == "max_tokens" and not text:
                    text = "My answer was cut off. Please ask again with a narrower request."
                return {"reply": text, "proposals": created, "stop": stop}
            messages.append({"role": "assistant", "content": response.content})
            results = []
            for block in tool_uses:
                out, is_error = self._run_tool(user_id, block.name, dict(block.input or {}), created)
                results.append({"type": "tool_result", "tool_use_id": block.id, "content": out, "is_error": is_error})
            messages.append({"role": "user", "content": results})

        return {"reply": "I stopped after several steps. Your drafts so far are in the Pending list.",
                "proposals": created, "stop": "max_steps"}

    # ------------------------------------------------------- confirmed actions
    def execute(self, user_id: str, proposal: dict) -> dict:
        """Publish or send a proposal the user confirmed. Re-validates first."""
        account = self.store.account_with_token(user_id, proposal["platform"])
        connector = self.api if account else self.drafts
        if proposal["kind"] == "post":
            validate_post(proposal["platform"], proposal["text"], proposal["media_url"])
            result = connector.publish_post(proposal["platform"], account, proposal["text"], proposal["media_url"])
        else:
            validate_reply(proposal["platform"], proposal["text"], proposal["target_id"])
            result = connector.reply(proposal["platform"], account, proposal["target_id"], proposal["text"])
        return result


def _parse_time(value: str | None) -> datetime | None:
    if not value:
        return None
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError as e:
        raise RuleViolation(f"scheduled_for is not a valid ISO 8601 time: {value}") from e
