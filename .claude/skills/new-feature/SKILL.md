---
name: new-feature
description: Scaffold a new feature (data/providers/presentation) from .fttemplates, register its typed route, and add tests. Use when a task says "add feature X".
---

# new-feature

Read ARCHITECTURE.md and CONVENTIONS.md first. Status: `.fttemplates/feature` is created by C-25; until then create the files by hand as below (or run `tool/new_feature.dart <name>` once it exists).

1. Name in `snake_case`. Folder `lib/features/<name>/`:
   - `data/models/<model>.dart` (freezed + json_serializable)
   - `data/sources/<name>_remote_source.dart` (Dio via `dioProvider`) and, if needed, `<name>_local_source.dart`
   - `data/<name>_repository.dart` (concrete class + `@Riverpod(keepAlive: true)` provider; returns models or throws `AppException`)
   - `providers/<name>_controller.dart` (`@riverpod` notifier: state + actions)
   - `presentation/pages/<name>_page.dart`, `presentation/widgets/`
2. New endpoint -> `new-api-call` skill. New page -> `new-page` skill. Strings -> `add-translation-keys` skill.
3. Register the typed route in `lib/app/router/routes.dart` (+ guard if protected). Edit no other feature.
4. Tests mirror paths under `test/features/<name>/`: repository (success + each mapped exception), controller (initial/success/failure/refresh), pages (8 states, goldens).
5. Codegen under the lock: `mkdir /tmp/riverpod_core.lock` -> `dart run build_runner build --delete-conflicting-outputs` -> `rmdir /tmp/riverpod_core.lock`.
6. Run the gate; write the report; set REVIEW.

Never: import another feature's internals; put shared widgets in a feature; use raw Material buttons/fields; add a domain layer.
