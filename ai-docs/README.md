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
| TESTING.md | Writing or changing any test or helper. |
| CHECKLIST.md | The Lead: what the template still lacks (status per item). |
| DECISIONS.md | Why things are the way they are. Append-only. Check before proposing alternatives. |
| HOW_TO_START_A_NEW_APP.md | Someone creating an app from this template. |
| reports/C-xx.md | Per-task report written by the worker; the Lead appends "REVIEW (Lead)". |

Skills (step-by-step recipes) live in `.claude/skills/`: new-feature, new-page, new-api-call,
add-translation-keys, review-task, release-check.

Status of docs: ARCHITECTURE, NETWORKING, STATE_AND_DATA, DESIGN_SYSTEM describe the TARGET state.
Where the current code differs, CHECKLIST.md and TASKS.md say which task closes the gap.
