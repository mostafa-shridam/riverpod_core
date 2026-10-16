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

## D-020 — Broad widget library + live showcase page
- Context: owner wants a rich set of custom widgets covering what apps typically need, good-looking by default, and one page to try them all quickly.
- Decision: the design_system catalog is expanded and split into disjoint folders/tasks (C-09, C-32, C-33, C-34, C-10); `lib/features/showcase/` hosts the gallery (C-35), registered only in dev/staging. A barrel `design_system/widgets/widgets.dart` is owned by C-35 only (tasks never edit the barrel; they import by file path).
- Why: parallelizable without file conflicts; features get one import and one look.
- Rejected: one giant widgets task; third-party UI kits (inconsistent look, lock-in).

## D-021 — cached_network_image for AppImage
- Decision: add `cached_network_image` (MIT; latest stable resolved in C-34) behind `AppImage`; features never use it directly.
- Why: disk + memory cache, placeholders, error handling; writing our own disk cache is far more than 30 lines.
- Rejected: `Image.network` (no disk cache), own implementation.

## D-022 — Platforms: Android and iOS only
- Decision: the template is a mobile app: `android/` and `ios/` are tracked (ios generated with `flutter create --platforms=ios`, org `com.example`, renamed by `tool/rename_app` / C-13). Web, macOS, Windows, Linux are not part of the template.
- Why: every checklist item (FCM, permissions, biometrics, deep links, store releases) is mobile; fewer native folders to maintain.
- Rejected: all six platforms.

## D-023 — Strings in design_system widgets (avoids shared generated files)
- Context: C-09, C-32, C-33, C-34 all need a few localized labels (close, cancel, confirm, show password…) and would all edit `assets/translations/*.json` and the generated `lib/generated/*.g.dart`.
- Decision: every widget family keeps its key constants in its own `*_strings.dart` (e.g. `overlays_strings.dart`: `const closeKey = 'ds_overlays.close';`) and resolves them with `.tr()`; widgets also accept an optional override parameter for each label. Each task adds its keys to BOTH `ar.json` and `en.json` under ONE distinct top-level object (`ds_buttons`, `ds_inputs`, `ds_selection`, `ds_overlays`, `ds_feedback`, `ds_display`, `ds_layout`) appended at the end of the file. These tasks do NOT regenerate or commit `lib/generated/*.g.dart`; the Lead regenerates them once after merging (conflicts in the JSON tails are trivially resolved by the Lead).
- Why: no two in-progress tasks edit the same generated file; a merge conflict can only occur in the JSON tail.
- Rejected: one central strings task blocking all widgets.

## D-024 — dotenv config and automatic debug/release flavor (supersedes D-006 and D-018)
- Context: owner finds `--dart-define-from-file` + three entrypoints too heavy; wants plain `flutter run` and a clear debug/release split.
- Decision: use `flutter_dotenv` (MIT; latest stable resolved in C-37). Files `env/dev.env`, `env/staging.env`, `env/prod.env` are real (git-ignored, bundled as assets) and `env/*.env.example` are committed; first setup step is copying the examples. The flavor is chosen in code in ONE place (`Flavor.current`): `kReleaseMode ? Flavor.prod : Flavor.dev`. Staging is the only explicit case: `lib/main_staging.dart` calls `bootstrap(Flavor.staging)`. `lib/main.dart` calls `bootstrap(Flavor.current)`. `bootstrap` loads `env/<flavor>.env` via dotenv and passes the map to `AppConfig.fromMap` (validation unchanged). The `FLAVOR` key disappears from env files; `AppConfig.ensureFlavor` is removed. Only `core/config` may touch `dotenv`/`fromEnvironment`.
- Why: simplest developer experience; debug builds can never accidentally use prod config and release builds can never use dev config.
- Trade-off recorded: dotenv values are bundled in the app, so they must never be real secrets (a client app cannot keep secrets anyway: API keys that must stay private belong on the server). Real secrets are still never committed (hard rule 5: real env files are git-ignored).
- Rejected: keeping dart-define (friction); committing real env files (rule 5).

## D-025 — Component size tokens and OTP direction exception
- Decision: component sizes (button heights 40/48/56, icon sizes, min target 48 dp, OTP box size) live in `design_system/tokens/app_sizes.dart` (`AppSizes`, a field of `AppTokens`); `searchDebounce` (300 ms) lives in `AppDurations`. Validators in `core/utils` return a `ValidationError` enum; the design_system maps it to localized text. `AppOtpField` is the ONLY place allowed a hard-coded `TextDirection.ltr` (digit order must stay left-to-right in RTL), with an explanatory comment.
- Why: no numeric sizes outside tokens; `core/` must not depend on UI or localization of widgets.

## D-026 — design_system lives inside core (supersedes the top-level folder of D-019/D-015)
- Decision (owner instruction): everything is under `lib/core/`; `design_system/` moved to `lib/core/design_system/` (tokens, theme, responsive, widgets). Import path `package:riverpod_core/core/design_system/...`. Rule: non-UI core folders never import `core/design_system/`.
- Why: owner wants one `core` root and no extra top-level folders.
- Rejected: top-level `lib/design_system/`.

## D-027 — video_player for AppVideoPlayer
- Decision (owner request: a video controller playing a video): add `video_player` (official flutter.dev plugin, BSD-3; latest stable resolved in C-38) behind `AppVideoPlayer` in `core/design_system/widgets/media/`. Features never use `video_player` directly. Custom controls (not Chewie): play/pause, seek bar, elapsed/total time, mute, speed, fullscreen toggle, buffering/error states, auto-hide.
- Why: official, maintained, covers Android/iOS; controls are ~300 lines of our own and match the design system.
- Rejected: `chewie` (extra dependency with its own look), `better_player` (unmaintained).

## D-028 — Reference (demo) features
- Decision: two generic demo features ship with the template and double as the source for the `.fttemplates/feature` scaffold (C-25): `features/showcase` (C-35, the component gallery) and `features/videos` (C-39, a complete feature: model, mock remote source, repository, providers, list page + player page, all 8 data states, tests). Both are registered only in dev/staging flavors, contain no app-specific names, and can be deleted without touching anything else (nothing imports them).
- Why: a complete working example is the best documentation of ARCHITECTURE.md; the mock source lets every data state be demonstrated without a backend.
- Rejected: documentation-only examples (drift from code).
