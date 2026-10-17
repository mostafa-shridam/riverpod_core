# ai-docs — index

The knowledge base every AI session and engineer must follow. `CLAUDE.md` (repo root) is the law; these files hold the detail.

| File | What it is for |
|---|---|
| RULES.md | Process: sessions, commits, heavy-command lock, review, decisions, done. |
| ARCHITECTURE.md | Feature-first architecture (no domain layer), folder tree, dependency rules, Riverpod patterns, error model. |
| CONVENTIONS.md | Naming, imports, formatting, strings, RTL-safe code. |
| DESIGN_SYSTEM.md | Tokens, shared widgets, the 8 data states. Read for any UI work. |
| NETWORKING.md | Dio, interceptors, repositories, API calls, uploads, pagination. |
| STATE_AND_DATA.md | Providers, AsyncValue, caching, storage, session lifecycle. |
| TESTING.md | What to test, helpers, goldens, integration test and `tool/smoke.sh`. |
| NOTIFICATIONS.md | Push and local notifications, Firebase setup for push, payload contract. |
| FIREBASE.md | Optional Crashlytics and Firebase Analytics: adding Firebase files, consent, vendor switch, test crash. |
| DEEP_LINKS.md | App links and custom scheme: host/scheme places, `assetlinks.json`, `apple-app-site-association`, Universal Links. |
| DECISIONS.md | Binding decisions (D-xxx), append-only. Check before proposing an alternative. |

Skills (step-by-step recipes) live in `.claude/skills/`: new-feature, new-page, new-api-call,
add-translation-keys, review-task, release-check.

Starting an app from the template: see "Start a new app from this template" in the root `README.md`.

If docs and code disagree, it is a bug in one of them: fix the code, or change the doc through a DECISION (`CLAUDE.md`).
