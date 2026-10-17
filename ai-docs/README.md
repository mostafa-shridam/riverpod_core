# ai-docs — index

The knowledge base every AI session must follow. `CLAUDE.md` (repo root) is the law; these files hold the detail.

| File | Read when |
|---|---|
| RULES.md | Always. Process: sessions, tasks, commits, review, done. |
| ARCHITECTURE.md | Always. Target architecture (feature-first, no domain layer), folder tree, rules, Riverpod patterns, error model. |
| CONVENTIONS.md | Always. Naming, imports, formatting, strings, RTL-safe code. |
| TASKS.md | Always. The only task list. Find your one task. |
| DESIGN_SYSTEM.md | Any UI work: tokens, shared widgets, the 8 data states. |
| NETWORKING.md | Anything touching Dio, repositories, API calls, uploads, pagination. |
| STATE_AND_DATA.md | Providers, AsyncValue, caching, storage. |
| NOTIFICATIONS.md | Push and local notifications, Firebase setup for push, payload contract. |
| TESTING.md | Writing or changing any test or helper; integration test and `tool/smoke.sh`. |
| CHECKLIST.md | The Lead: what the template still lacks (status per item). |
| DECISIONS.md | Why things are the way they are. Append-only. Check before proposing alternatives. |
| DEEP_LINKS.md | App links and custom scheme: host/scheme places, assetlinks.json, apple-app-site-association, enabling Universal Links. |
| FIREBASE.md | Optional Crashlytics + Firebase Analytics: what is optional, adding Firebase files, consent, switching vendor, test crash. |
| HOW_TO_START_A_NEW_APP.md | Someone creating an app from this template. |
| reports/C-xx.md | Per-task report written by the worker; the Lead appends "REVIEW (Lead)". |

Skills (step-by-step recipes) live in `.claude/skills/`: new-feature, new-page, new-api-call,
add-translation-keys, review-task, release-check.

Status of docs: all planned template tasks are merged, so ARCHITECTURE, NETWORKING, STATE_AND_DATA, DESIGN_SYSTEM and NOTIFICATIONS describe the code as it is.
If you find a difference, it is a bug in the code or in the doc: CHECKLIST.md lists the known open items; fix it through a task or a DECISION.
