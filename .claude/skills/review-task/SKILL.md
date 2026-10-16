---
name: review-task
description: The Lead's recipe to review a worker's task: clean worktree, full gate, diff vs ai-docs, merge or send back numbered fixes.
---

# review-task (Lead only)

Never mark DONE on a worker's word.

1. Get the task ID and commit sha from the worker's message. Confirm the task row says REVIEW and `ai-docs/reports/C-xx.md` exists.
2. Clean worktree at that sha:
   `git worktree add ../riverpod_core-review <sha> --detach` (remove an old one first with `git worktree remove`).
3. Scope check: `git diff --name-only main...<sha>` — every path must be inside the task's `Files:` list; no secrets (`google-services.json`, `.env`, keystores); no `git add -A` noise (`.DS_Store`, build output).
4. Run the full gate yourself inside the review worktree, holding the lock (`mkdir /tmp/riverpod_core.lock` … `rmdir`):
   `flutter pub get` · `dart run build_runner build --delete-conflicting-outputs` (if codegen) · `dart format --set-exit-if-changed lib test` · `flutter analyze` · `flutter test`. Also `git status` must be clean after build_runner (generated files committed).
5. Read the whole diff against ai-docs: ARCHITECTURE (layers, Riverpod patterns), CONVENTIONS (naming, imports, strings, logical properties), the task's own docs.
   Check: tests really test the "Done when" items; no deleted/weakened tests without a note; no new package without a DECISION; no hard-coded strings/colors; commits are by path with `C-xx:` messages.
6. Fail → set the task to CHANGES and send a numbered list: `1. <file>:<line> — <what is wrong> — <exact fix>`. Re-review from step 2 after the worker's new commit.
7. Pass → in the main worktree: `git merge --no-ff worker-<x> -m "Merge C-xx: <title>"`, set the task row to DONE, append to the report:
   `## REVIEW (Lead)` with date, sha, gate results, notes. Update CHECKLIST.md statuses the task closed. Remove the review worktree.
8. Tell the owner (Egyptian Arabic) only at reporting points; tell the worker the result immediately.
