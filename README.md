# ContactE
This Flutter app uses Al for enhanced contact management and profile creation, with real-time updates from Firebase.
Features include smart contact suggestions, detailed profiles, seamless navigation, and advanced search.

## New in 2026

| Bradi, the social-media agent | Drafts wait for you | Digital business card | Connected accounts |
|---|---|---|---|
| ![Agent](docs/screenshots/agent.jpg) | ![Draft](docs/screenshots/draft.jpg) | ![Card](docs/screenshots/card.jpg) | ![Accounts](docs/screenshots/accounts.jpg) |

- **Bradi** plans and writes posts for Instagram, Facebook, LinkedIn and X, adapts one idea per platform,
  suggests times, reads recent comments and drafts replies — with Claude, through the
  [`agent_backend`](agent_backend/README.md). **Nothing is published until you tap Confirm**; platform
  rules are enforced in code, and every action is audited. Without a connected account, a confirmed
  draft opens the share sheet.
- **Digital business card** — a QR code holding a standard vCard: any phone camera can scan it and save
  your contact, no app needed on the other side.
- **Material 3 redesign** — dark-first design tokens, IBM Plex Sans Arabic, labelled navigation bar.
- **Security** — the AI key and social tokens live on the server only; the app sends its Firebase ID token.

Run the design preview (no Firebase needed) against a local backend:

```bash
cd agent_backend && python run_dev.py          # AUTH_MODE=dev in agent_backend/.env
flutter run -d chrome -t lib/main_preview.dart --dart-define=AGENT_DEV_USER=preview-user
```

![Screenshot 2024-07-07 201952](https://github.com/adel6-ahmed/ContactE/assets/129671904/fdc88821-3133-485b-ae38-f6d78cd71fca)


![Screenshot 2024-07-07 195147](https://github.com/adel6-ahmed/ContactE/assets/129671904/f3bade94-8d1f-4ec7-9fa7-c1367bdd907b)

![Screenshot 2024-07-07 195330](https://github.com/adel6-ahmed/ContactE/assets/129671904/d1b326f9-a6f9-48e1-979c-beb69b9e4d4b)

![Screenshot 2024-07-07 195711](https://github.com/adel6-ahmed/ContactE/assets/129671904/79b3261b-ea9a-4ad9-814e-92fe25c982fd)

![Screenshot 2024-07-07 195753](https://github.com/adel6-ahmed/ContactE/assets/129671904/7f167806-2b0e-431b-b142-fded7fa2e4c6)




