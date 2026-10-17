# RULES — process

Complements the hard rules in `CLAUDE.md` (those win on any conflict).

## Roles
- **Owner**: product/taste decisions, accounts, paid services, pushes to the remote.
- **Engineer / AI session**: implements a change inside the rules of `CLAUDE.md` and `ai-docs/`, and asks the owner when the docs are silent.

## Sessions
- Start every session by reading in the order given in CLAUDE.md.
- Work on a small branch off `main`; one concern per branch. No unrelated "while I'm here" edits.
- Need a file or area the docs do not cover: stop and ask the owner.

## Commits
- Message: short, imperative, English.
- Commit by explicit path (`git add path1 path2`), never `git add -A`, never `commit -a`.
- Small and green: every commit passes format + analyze + tests.
- Never amend, rebase, force-push, `reset --hard`. Fix forward with a new commit.
- Never push. The owner pushes.
- Commit attribution trailer is added when the environment requests it.

## Heavy commands
Full `flutter test`, `build_runner`, builds, `flutter pub get` on shared caches:
```
while ! mkdir /tmp/riverpod_core.lock 2>/dev/null; do sleep 15; done
... run the command ...
rmdir /tmp/riverpod_core.lock
```
Always `rmdir` even if the command fails.

## Review
See `.claude/skills/review-task/SKILL.md`. Never accept a change on the author's word: run the gate and read the diff against ai-docs.

## Decisions
Safe technical choices are recorded in DECISIONS.md (D-xxx, append-only).
Taste/product/paid/account choices: ask the owner.

## Done
A change is done only when the Definition of Done in CLAUDE.md is green on a clean checkout.
