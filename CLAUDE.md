# CLAUDE.md — the law of `riverpod_core`

`riverpod_core` is a Flutter + Riverpod starter TEMPLATE. Every new app starts from this repo.
It must contain the foundations every production app needs, done once and done right.
This file is BINDING for every AI session. Nothing outside CLAUDE.md and `ai-docs/` may be invented.

## Read in order (every session, before anything else)
1. `CLAUDE.md` (this file)
2. `ai-docs/RULES.md`
3. `ai-docs/ARCHITECTURE.md`
4. `ai-docs/CONVENTIONS.md`
5. `ai-docs/TASKS.md` — find YOUR one task only
6. The docs your task names (`DESIGN_SYSTEM.md`, `NETWORKING.md`, `STATE_AND_DATA.md`, `TESTING.md`, …)

Index of all docs: `ai-docs/README.md`.

## Before your first edit
State in one line: **your role, your task ID, the paths you will touch.**
Example: `Worker A · C-03 · lib/core/error/**, test/core/error/**, assets/translations/*.json`

## Hard rules
1. Never invent a rule, API, package or pattern. If ai-docs does not answer it: ask the Lead.
2. One task at a time per session, from ai-docs/TASKS.md only. No "while I'm here" changes.
3. Workers work only in their own git worktree and branch (worker-a, worker-b…), never on main.
4. Never push. Never amend, rebase, force, reset --hard, `git add -A` or `commit -a`. Commit by explicit path, small and green, message "C-xx: <what>". The owner pushes.
5. Never commit secrets: no API keys, real google-services.json / GoogleService-Info.plist, keystores, .env. Commit *.example files only; real ones are git-ignored.
6. Never delete or weaken a test without writing which behaviour stopped being true.
7. Every page: light/dark, ar (RTL) + en (LTR), text scaling, phone + tablet, the 8 data states (loading, empty, error, offline, stale, partial, refreshing, success). No hard-coded user text.
8. One shared implementation per UI primitive (in core/design_system/); features compose it, never re-implement it.
9. Heavy commands (full flutter test, build_runner, builds) run one session at a time: `mkdir /tmp/riverpod_core.lock` before, `rmdir` after; wait if it exists.
10. The template stays generic: no app-specific names, colors, endpoints or logic. Everything app-specific comes from config/flavors/theme in one place.
11. New package = a DECISION (why, alternatives, latest stable version, license). Prefer 30 lines of our own code over a heavy dependency.

## Stop conditions (stop and message the Lead; do not continue)
- ai-docs is silent, ambiguous, or contradicts the code or itself.
- The task needs a file that another in-progress task owns, or a file not listed in your task.
- The task needs a new package, a secret, an account, a paid service, or a product/taste choice.
- The gate fails for a reason outside your task's files.
- You are about to break a hard rule to finish.

**If unsure: ask the Lead, never guess.**

## When code and docs disagree
The docs say what should be true. Fix the code in a task, or change the doc through a DECISION in
`ai-docs/DECISIONS.md`. Never silently pick one.

## Definition of done (all green on a clean checkout)
```
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # only if the task touches codegen
dart format --set-exit-if-changed lib test
flutter analyze            # 0 issues
flutter test               # all green
```
Plus: report `ai-docs/reports/C-xx.md` (what, tests, decisions), task status cell set to REVIEW,
then message the Lead with the commit sha and 2 lines.

## Language
Owner talks to the Lead in Egyptian Arabic; the Lead answers the owner in Egyptian Arabic.
Everything in the repo and every message to workers is English.
