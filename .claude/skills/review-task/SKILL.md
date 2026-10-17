---
name: review-task
description: Recipe to review a change: clean checkout, full gate, diff vs ai-docs, merge or send back numbered fixes.
---

# review-task

Never accept a change on the author's word.

1. Get the branch or commit sha to review.
2. Clean worktree at that sha:
   `git worktree add ../riverpod_core-review <sha> --detach` (remove an old one first with `git worktree remove`).
3. Scope check: `git diff --name-only main...<sha>`: every path belongs to the change's concern; no secrets (`google-services.json`, `.env`, keystores); no `git add -A` noise (`.DS_Store`, build output).
4. Run the full gate yourself inside the review worktree, holding the lock (`mkdir /tmp/riverpod_core.lock` … `rmdir`):
   `flutter pub get` · `dart run build_runner build --delete-conflicting-outputs` (if codegen) · `dart format --set-exit-if-changed lib test tool integration_test` · `flutter analyze` · `flutter test`. Also `git status` must be clean after build_runner (generated files committed).
5. Read the whole diff against ai-docs: ARCHITECTURE (layers, Riverpod patterns), CONVENTIONS (naming, imports, strings, logical properties), the docs of the touched area.
   Check: tests really test the new behaviour; no deleted/weakened tests without a note; no new package without a DECISION; no hard-coded strings/colors; commits are by path.
6. Fail: send a numbered list: `1. <file>:<line> — <what is wrong> — <exact fix>`. Re-review from step 2 after the new commit.
7. Pass: merge into `main` with `git merge --no-ff <branch>`, update the docs the change affects, remove the review worktree.
