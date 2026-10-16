# RULES — process

Complements the hard rules in `CLAUDE.md` (those win on any conflict).

## Roles
- **Owner**: product/taste decisions, accounts, paid services, pushes to the remote.
- **Lead**: owns plan, docs, rules, review, merges into local `main`. Does not implement tasks that are assigned to a worker.
- **Worker** (a separate Claude session, or a Lead subagent): implements exactly one task at a time.

## Sessions
- Each worker has its own worktree and branch: `../riverpod_core-a` on `worker-a`, etc.
  Create: `git worktree add ../riverpod_core-a -b worker-a main`.
- Start every session by reading in the order given in CLAUDE.md, then state role, task ID, paths.
- A session never edits a file outside its task's `Files:` list. Need another file → stop, ask the Lead.
- Two in-progress tasks never share a file. The Lead enforces this when assigning.

## Tasks
- Source: `ai-docs/TASKS.md` only. Format and statuses are defined there.
- Lifecycle: `READY → IN_PROGRESS·<worker> → REVIEW → CHANGES | DONE`. `BLOCKED` while a dependency is open.
- The worker moves READY→IN_PROGRESS and →REVIEW. Only the Lead sets CHANGES and DONE.
- Scope creep: write the idea into the report under "Suggested follow-ups"; do not implement it.

## Commits
- Message: `C-xx: <what>`, imperative, English. Lead merge commits: `Merge C-xx: <title>`.
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

## Report (ai-docs/reports/C-xx.md)
Sections: What changed · Files · Tests added/changed · Decisions made or needed · Gate output summary · Suggested follow-ups.

## Review (Lead)
See `.claude/skills/review-task/SKILL.md`. Never mark DONE on a worker's word.
Pass → merge into local main with `--no-ff`, mark DONE, append "REVIEW (Lead)" to the report.
Fail → CHANGES with exact, numbered fixes.

## Decisions
Safe technical choices: the Lead decides and records in DECISIONS.md (D-xxx, append-only).
Taste/product/paid/account choices: ask the owner.

## Done
A task is done only when the Definition of Done in CLAUDE.md is green on a clean checkout AND the Lead's review passed.
