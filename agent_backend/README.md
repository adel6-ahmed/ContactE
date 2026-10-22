# ContactE agent backend

A small FastAPI service that runs **Bradi**, the social-media agent inside ContactE, with Claude.

**The model drafts, code decides, the user confirms.**

- The agent's tools only read data or create *pending* drafts. No tool publishes.
- Platform rules (X 280 characters, Instagram needs media and ≤ 30 hashtags, LinkedIn 3,000, …)
  are enforced in code before a draft is stored and again before it is sent.
- Publishing happens only through `POST /proposals/{id}/confirm`, which the app calls when the
  user taps **Confirm**. Every step is written to an audit log.
- The Claude API key and the users' social-media tokens stay on the server (tokens encrypted at
  rest). The app only sends the user's Firebase ID token.

## Run locally

```bash
cd agent_backend
pip install -r requirements.txt
cp .env.example .env          # set ANTHROPIC_API_KEY, TOKEN_ENCRYPTION_KEY; AUTH_MODE=dev for local
uvicorn app.main:app --port 8090
pytest                        # 14 tests, no network, no API key
```

## API

| Method | Path | Purpose |
|---|---|---|
| GET | `/accounts` | Platforms and whether each publishes directly (`api`) or via share sheet (`drafts`) |
| POST / DELETE | `/accounts/{platform}` | Connect / disconnect an account (`instagram`, `facebook`, `linkedin`, `x`) |
| POST | `/agent/chat` | `{message, history}` → `{reply, proposals}` |
| GET | `/proposals?status=pending` | Drafts waiting for confirmation |
| PATCH | `/proposals/{id}` | Edit a pending draft (re-validated) |
| POST | `/proposals/{id}/confirm` | Publish now, or mark *scheduled* if it has a future time |
| POST | `/proposals/{id}/reject` | Discard a draft |
| POST | `/scheduler/run-due` | Cron job (header `X-Cron-Secret`) publishes due scheduled posts |
| GET | `/audit` | The user's own audit log |

## Connecting real accounts

Without a connected account every platform works in **drafts** mode: confirming returns text the
app opens in the native share sheet. Direct publishing needs a developer app per platform and the
user's token:

| Platform | What you need | Notes |
|---|---|---|
| Instagram | Meta app, Instagram Business/Creator account linked to a Facebook Page, `ig_user_id`, token with `instagram_content_publish` | Posts need a public image/video URL |
| Facebook | Page access token with `pages_manage_posts`, `page_id` | |
| LinkedIn | App with "Share on LinkedIn" (`w_member_social`), `author_urn` (`urn:li:person:…`) | Comment reading not supported |
| X | Developer app (paid tier for posting), user-context OAuth 2.0 token with `tweet.write` | |

The `POST /accounts/{platform}` endpoint accepts a token directly, which is enough for testing.
For production, add each platform's OAuth redirect flow so users never handle tokens themselves.
