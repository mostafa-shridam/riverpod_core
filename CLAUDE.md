# CLAUDE.md — the law of `riverpod_core`

`riverpod_core` is a Flutter + Riverpod starter TEMPLATE. Every new app starts from this repo.
It must contain the foundations every production app needs, done once and done right.
This file is BINDING for every AI session. Nothing outside CLAUDE.md and `ai-docs/` may be invented.

## Read in order (every session, before anything else)
1. `CLAUDE.md` (this file)
2. `ai-docs/RULES.md`
3. `ai-docs/ARCHITECTURE.md`
4. `ai-docs/CONVENTIONS.md`
5. The docs your change touches (`DESIGN_SYSTEM.md`, `NETWORKING.md`, `STATE_AND_DATA.md`, `TESTING.md`, `NOTIFICATIONS.md`, `FIREBASE.md`, `DEEP_LINKS.md`, …)

Index of all docs: `ai-docs/README.md`. Binding decisions: `ai-docs/DECISIONS.md`.

## Hard rules
1. Never invent a rule, API, package or pattern. If ai-docs does not answer it: ask the owner.
2. No "while I'm here" changes: one concern per change.
3. Work on a small branch off `main`, never directly on `main`.
4. Never push. Never amend, rebase, force, reset --hard, `git add -A` or `commit -a`. Commit by explicit path, small and green. The owner pushes.
5. Never commit secrets: no API keys, real google-services.json / GoogleService-Info.plist, keystores, .env. Commit *.example files only; real ones are git-ignored.
6. Never delete or weaken a test without writing which behaviour stopped being true.
7. Every page: light/dark, ar (RTL) + en (LTR), text scaling, phone + tablet, the 8 data states (loading, empty, error, offline, stale, partial, refreshing, success). No hard-coded user text.
8. One shared implementation per UI primitive (in core/design_system/); features compose it, never re-implement it.
9. Heavy commands (full flutter test, build_runner, builds) run one session at a time: `mkdir /tmp/riverpod_core.lock` before, `rmdir` after; wait if it exists.
10. The template stays generic: no app-specific names, colors, endpoints or logic. Everything app-specific comes from config/flavors/theme in one place.
11. New package = a DECISION (why, alternatives, latest stable version, license). Prefer 30 lines of our own code over a heavy dependency.

## When to stop and ask the owner
- ai-docs is silent, ambiguous, or contradicts the code or itself.
- The change needs a new package, a secret, an account, a paid service, or a product/taste choice.
- The gate fails for a reason you cannot fix inside your change.
- You are about to break a hard rule to finish.

**If unsure: ask the owner, never guess.**

## When code and docs disagree
The docs say what should be true. Fix the code, or change the doc through a DECISION in
`ai-docs/DECISIONS.md`. Never silently pick one.

## How to work on this template after v1
1. Work on a small branch off `main`; one concern per branch.
2. Read the doc that owns the area you touch before editing.
3. Run the gate (below) before every commit.
4. If behaviour changes, update the doc that owns the rule in the same commit.
5. A new package or an exception to a layer rule needs a DECISION in `ai-docs/DECISIONS.md` first.

## Definition of done (all green on a clean checkout)
```
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # only if the change touches codegen
dart format --set-exit-if-changed lib test tool integration_test
flutter analyze            # 0 issues
flutter test               # all green
```

## Language
Everything in the repo (code, comments, docs, commit messages) is English.
