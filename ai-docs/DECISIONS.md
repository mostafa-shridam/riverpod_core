# DECISIONS (append-only)

Format: context · decision · why · alternatives rejected. Never edit an old entry; supersede it with a new one.
Package versions below are "to verify": the implementing task must check pub.dev for the latest stable version and license
at implementation time and record them in its report.

## D-001 — ai-docs and CLAUDE.md are the binding source of truth
- Context: several AI sessions will work on the template in parallel.
- Decision: CLAUDE.md + ai-docs/ define all rules; nothing outside may be invented; the Lead controls them.
- Why: prevents drift and contradictory patterns between sessions.
- Rejected: per-session conventions; rules scattered in code comments.

## D-002 — Codegen toolchain
- Context: pubspec has `riverpod_annotation` and a generated `local_storage.g.dart`, but no `riverpod_generator`, `freezed`, `json_serializable`; `build_runner` cannot regenerate today.
- Decision: add dev deps `riverpod_generator`, `freezed` (+ `freezed_annotation`), `json_serializable` (+ `json_annotation`), `custom_lint` + `riverpod_lint`. Versions: latest stable compatible with `flutter_riverpod ^3`, verified in C-01.
- Why: required by the Foundation checklist; lints enforce our Riverpod rules automatically.
- Rejected: hand-written providers (legacy, error-prone); `built_value` (heavier); `dart_mappable` (smaller ecosystem).

## D-003 — Generated files sit next to their source
- Context: `build.yaml` redirects outputs to `generated/` sub-folders for four hard-coded directories, and breaks for any new folder.
- Decision: remove the `build_extensions` redirect; use the default `x.g.dart` / `x.freezed.dart` beside the source.
- Why: works for every folder, including `.fttemplates`-generated features; zero custom config.
- Rejected: keeping per-folder redirects (needs a build.yaml edit for each new feature).

## D-004 — Local database: Drift
- Context: checklist requires one local DB; current code uses Hive (`hive_flutter 1.1.0`, effectively unmaintained).
- Decision: Drift (SQLite) for structured data and the HTTP/SWR cache; `shared_preferences` for settings; `flutter_secure_storage` for secrets. Hive is removed in C-06.
- Why: actively maintained, typed queries, migrations, streams that fit Riverpod, works on all platforms.
- Rejected: Isar (maintenance uncertain), Hive (unmaintained, no migrations/relations), sqflite raw (no typing).

## D-005 — One router, responsive instead of per-device routers
- Context: code has `mobile/`, `ipad/`, `web/` router classes plus a stray `services/app_router.dart` — two parallel routers, all with empty routes.
- Decision: a single GoRouter exposed through a Riverpod provider (`routerProvider`), typed routes, guards driven by `SessionController`; screens adapt with breakpoints.
- Why: routes must not diverge by device; deep links and notification taps need one source of truth.
- Rejected: separate routers per device class.

## D-006 — Flavors via `--dart-define-from-file`
- Decision: `env/dev.json`, `env/staging.json`, `env/prod.json` (git-ignored) with committed `env/*.example.json`; `AppConfig.fromEnvironment()` validates required keys at startup and shows/throws a clear error. Native flavor wiring (Android flavors / iOS schemes) is added by its own task.
- Why: no extra package, works with `flutter run/build --dart-define-from-file=env/dev.json`.
- Rejected: `flutter_flavorizr` (heavy, rewrites native files), `.env` asset (ships secrets in the bundle).

## D-007 — Keep `easy_localization`
- Context: already integrated with code-generated keys (`LocaleKeys`) and ar/en.
- Decision: keep it; add runtime locale switch, plural keys, parity test. Re-evaluate against `gen_l10n` only if a blocker appears.
- Why: runtime switch without restart and plurals are supported; replacing it costs a migration with no user benefit.
- Rejected: `flutter gen_l10n` (needs custom runtime-switch plumbing).

## D-008 — Repositories throw `AppException`; no `ApiResult` wrapper
- Context: current `ApiService` returns `ApiResult<T>` with `Exception` payloads and English hard-coded messages.
- Decision: sealed `AppException` hierarchy thrown by repositories, held in `AsyncError` by notifiers; `ApiResult`, `ApiService`, `ErrorHandler`, `FailureMessages` are deleted by C-07 after migration.
- Why: matches `AsyncValue` idiom; one error type end-to-end; localized messages from keys.
- Rejected: `Either`/`Result` types (extra dependency, double handling next to `AsyncValue`).

## D-009 — Template dependency hygiene
- Context: pubspec contains app-specific or unused packages (`cloud_firestore`, `firebase_auth`, `google_sign_in`, `googleapis_auth`, `android_intent_plus`, `hive_flutter`), and `rename_app` sits in `dependencies`.
- Decision: C-01 removes anything that is unused or app-specific (rule 10) and moves `rename_app` to `dev_dependencies`. Firebase Core + Messaging stay (notifications are in the checklist). Social sign-in is an optional recipe, not core.
- Why: a template must not force Firestore/Google sign-in onto every app; fewer dependencies = faster builds, fewer upgrades.
- Rejected: keeping them "in case".

## D-010 — Repository singletons → providers
- Context: `LocalStorage.instance`, `NetworkService.instance`, `Routes.instance`, `LocalNotificationsService.instance`, etc. hold state globally.
- Decision: new and migrated code wraps services in Riverpod providers (ARCHITECTURE.md "Forbidden"). Existing singletons are migrated by the task that owns their area (storage C-06, connectivity C-10, router C-11, notifications later).
- Why: testability and overrides; no hidden global state.
- Rejected: big-bang refactor in one task.

## D-011 — Decision authority (owner standing instruction, 2026-10-16)
- Context: the owner does not want to approve every technical choice.
- Decision: the Lead decides all technical choices (packages, patterns, structure, versions) and records them here. The owner is asked only about taste/product (brand, names), paid services and accounts. The owner has granted the Lead and its agents full tool permissions in this repo.
- Why: speed; the decision log keeps everything reviewable and reversible.
- Rejected: asking before each decision.

## D-012 — Keep Firebase auth stack in the template (supersedes part of D-009)
- Decision: keep `cloud_firestore`, `firebase_auth`, `google_sign_in` (owner: apps need sign-in). Remove `googleapis_auth` and `android_intent_plus` (unused). `rename_app` becomes a dev dependency.
- Why: owner's apps use login; unused ones add build weight.

## D-013 — Latest stable packages
- Decision: upgrade every dependency to the latest stable version that resolves together (`flutter pub upgrade --major-versions`), fixing resulting breakage inside C-01. Exact versions are recorded in README.md (packages table) from pubspec.lock.
- Why: owner request; a template should start current.

## D-014 — Work mode without workers
- Decision: with no worker sessions open, the Lead implements tasks directly on `main`, one task per commit `C-xx: …` by explicit path, running the full gate before each commit.
- Why: owner asked for all tasks to be executed; worktree/branch rules (RULES.md) apply when workers exist.

## D-015 — Target architecture: no domain layer (supersedes the layered tree first written in ARCHITECTURE.md)
- Context: owner specified the final architecture (see ARCHITECTURE.md). First draft had domain/entities/abstract repositories.
- Decision: feature-first; flow `page → provider → repository → data source`; repositories are concrete classes with a keepAlive provider; freezed+json models are used directly; no entities, use cases or repository interfaces. UI primitives live only in `lib/design_system/`; infrastructure in `lib/core/`; cross-feature models in `lib/shared/`.
- Why: interfaces/entities add ceremony without value for a template; tests override providers instead.
- Rejected: Clean Architecture with domain layer.

## D-016 — Typed routes with go_router_builder (supersedes routing details of D-005)
- Decision: add dev dependency `go_router_builder` (BSD-3, latest stable resolved in C-11); all route paths in `lib/app/router/routes.dart`; `appRouterProvider` in `app_router.dart`; guards in `app/router/guards/`. Single router, responsive pages.
- Why: compile-time-safe navigation; deep links and notification taps resolve through the same routes.
- Rejected: string paths scattered in widgets; `auto_route` (second routing ecosystem).

## D-017 — No riverpod_lint / custom_lint
- Context: tried in C-01; `riverpod_lint`/`custom_lint` cannot resolve with the current riverpod 3 / freezed 4 / uuid 4 stack.
- Decision: not used. Our Riverpod rules are enforced by review + the checks in review-task. Revisit when versions align.
- Rejected: pinning old versions of uuid/freezed just for the linter.

## D-018 — Flavor entrypoints (adjusts D-006)
- Decision: `lib/main_dev.dart`, `main_staging.dart`, `main_prod.dart` each call `bootstrap(Flavor.x)`. `AppConfig` is still loaded from `--dart-define-from-file=env/<flavor>.json`; the flavor passed by the entrypoint must match the file's `FLAVOR` value, otherwise startup fails with a clear error.
- Why: IDE run configs and native flavors can target an entrypoint; mismatch protection avoids running prod config in a dev build.

## D-019 — design_system/ replaces core/widgets and core/themes
- Decision: tokens, theme, responsive helpers and all shared widgets move to `lib/design_system/` (C-05, C-09, C-10). `core/` has no UI.
- Why: one obvious home for every UI primitive (hard rule 8).
