---
name: new-feature
description: Scaffold a new feature (data/providers/presentation) from .fttemplates, register its typed route, and add tests. Use when adding feature X.
---

# new-feature

Read ARCHITECTURE.md and CONVENTIONS.md first. The skeleton comes from `.fttemplates/feature`, rendered by `tool/new_feature.dart`; never copy another feature by hand.

1. Name in `snake_case` (e.g. `product_orders`). Preview, then create, from the project root:
   ```
   dart run tool/new_feature.dart --name product_orders --dry-run
   dart run tool/new_feature.dart --name product_orders
   ```
   It refuses an invalid name or an existing feature, and writes `lib/features/<name>/` (freezed model, Dio remote source, repository with ONE `fetchItems` read, `@riverpod` controller, page with `static const routeName` + `AsyncValueView`, item tile) plus the matching `test/features/<name>/` (repository, controller, page, test support). It adds a `<nameCamel>` key group (`title`, `emptyTitle`, `emptyMessage`) to BOTH translation files and prints the typed route; it never edits `routes.dart`.
2. Replace the model fields, the endpoint (`<nameCamel>Endpoint`) and the texts. Translate `<nameCamel>.title` in `ar.json` (it holds the English title). New endpoint -> `new-api-call` skill. New page -> `new-page` skill. Strings -> `add-translation-keys` skill.
3. Paste the printed typed route into `lib/core/router/routes.dart` (+ guard if protected). Edit no other feature.
4. Extend the generated tests to your behaviour: repository (success + each mapped exception), controller (initial/success/failure/refresh), pages (8 states, goldens).
5. Generation under the lock (`mkdir /tmp/riverpod_core.lock` ... `rmdir /tmp/riverpod_core.lock`): the two `easy_localization:generate` commands and `dart run build_runner build --delete-conflicting-outputs` from `build.sh`, then `dart format lib test`. Commit `lib/generated/*` with the change (D-037).
6. Run the gate (CLAUDE.md, Definition of done).

Never: import another feature's internals; put shared widgets in a feature; use raw Material buttons/fields; add a domain layer.
