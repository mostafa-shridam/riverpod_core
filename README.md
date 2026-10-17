# riverpod_core

A production-grade **Flutter + Riverpod starter template** for Android and iOS. Every new app starts from this repo.

The template contains **zero project data**: no Firebase files, no API keys, no real endpoints, no brand. Every service a
production app needs is already built, tested and wired behind a small interface. A new app only drops in its own
configuration (env files, one brand file, optional Firebase files, signing keys) and starts building features.
A fresh clone builds and runs with `flutter run` after copying `env/*.env.example` (D-042).

> Everything below is merged and was checked against the code in this repository. Open items are listed in [Known open items](#known-open-items).

- [Who this is for and how to read the docs](#who-this-is-for-and-how-to-read-the-docs)
- [What is in the box](#what-is-in-the-box)
- [Architecture](#architecture)
- [Packages](#packages)
- [Environment setup](#environment-setup)
- [Run and install](#run-and-install)
- [Remote config, app lock and deep links](#remote-config-app-lock-and-deep-links)
- [Firebase, Crashlytics and push stay optional](#firebase-crashlytics-and-push-stay-optional)
- [Start a new app](#start-a-new-app)
- [Daily workflow](#daily-workflow)
- [Localization](#localization)
- [Design system tour](#design-system-tour)
- [Data layer: cache-first](#data-layer-cache-first)
- [Testing](#testing)
- [Integration test and smoke script](#integration-test-and-smoke-script)
- [CI](#ci)
- [Release](#release)
- [Troubleshooting](#troubleshooting)
- [Known open items](#known-open-items)
- [Documentation index](#documentation-index)
- [Decisions at a glance](#decisions-at-a-glance)

## Who this is for and how to read the docs

The audience is the template owner and engineers who start apps from it (humans and AI sessions).

- `CLAUDE.md` is the law: hard rules, definition of done. It wins over everything.
- `ai-docs/` holds the detail (rules, architecture, conventions, design system, networking, state/data, testing,
  notifications, decisions). Nothing outside `CLAUDE.md` and `ai-docs/` may be invented (D-001).
- `ai-docs/DECISIONS.md` is append-only: check it before proposing an alternative to anything below.
- If code and docs disagree, the docs say what should be true: fix the code in a task, or change the doc through a new
  DECISION. Never silently pick one.

## What is in the box

Grouped by area.

### Foundation
- Feature-first structure (`data/ providers/ presentation/`), no domain layer (D-015).
- Riverpod 3 with code generation (`@riverpod` only), `freezed` + `json_serializable`, generated files beside their source (D-003).
- Strict `analysis_options.yaml` (strict casts/inference/raw types plus extra lints, `always_use_package_imports`, ordered directives).
- Config from `env/<flavor>.env` via `flutter_dotenv`, validated at startup with a clear error screen (D-024).
  Debug builds are `dev`, release builds are `prod`, `staging` only through `lib/main_staging.dart`.
- `bootstrap()`: guarded zone, global error handlers (logger + crash reporter), config load, storage warm-up, notifications init, formatting init, `runApp`.
- Native build health: Gradle 8.14.3, AGP 8.11.1, Kotlin 2.4.0, `compileSdk` 37, `minSdk` 24, iOS 15.0 + CocoaPods.
- Scripts: `tool/rename_app.dart` (rename name/id/package), `tool/new_feature.dart` (scaffold a feature), `tool/release/*` (signed release builds).

### Networking
- ONE `Dio` (`dioProvider`) with interceptors in a fixed order: idempotency key, auth header, single-flight refresh-token with request queue, retry with exponential backoff (idempotent calls only), dev-only logging that never prints secrets, error mapping (always last).
- Sealed `AppException` (network, timeout, unauthorized, forbidden, not found, validation with field errors, server, cancelled, unknown) mapped in ONE place; localized messages from `errors.*` keys.
- Repositories return models or throw `AppException` (no result wrapper, D-008).
- Pagination helpers (cursor + offset), `PaginatedNotifier` and `PaginatedListView` with infinite scroll and per-page errors that keep the loaded items.
- Upload/download with progress and cancel (`UploadService`, `DownloadService`, `TransferController`).
- Connectivity provider (plugin events only, no DNS probing) and an offline banner.

### State and data
- `AsyncValueView` renders the 8 data states: loading, empty, error, offline, stale, partial, refreshing, success.
- Settings in prefs (`PrefsStorage`), secrets in `flutter_secure_storage` (`SecureStorage`), structured/offline data in `hive_ce` boxes (D-034). Settings and cache boxes are opened in `bootstrap`; a storage failure is fatal and reported.
- Cache-first data layer (`CachedRepositoryHelper.load`/`watch`, `CachePolicy` presets, ETag revalidation, payload no-op, pruning; D-038). See [Data layer](#data-layer-cache-first).
- Logout is ONE function (`SessionController.logout`): notifications hook, best-effort remote logout, wipe of secure storage, cache and user-scoped prefs, analytics reset, session epoch bump that invalidates user-scoped providers.
- Provider auto-retry is disabled on purpose (D-032): errors surface, retry is explicit.

### Auth and security
- Session (`SessionController`, keepAlive): restore at startup, sign in/out, refresh through the single-flight refresher, expiry handling.
- Login, register and forgot-password pages on design-system widgets only; endpoints in ONE file (`auth_endpoints.dart`); an in-memory mock source (`authUseMockSource = true`) lets the app run with no backend.
- Splash -> onboarding -> auth -> home with pure redirect rules (`appRedirect`) and a startup sequence.
- Biometric app lock (`local_auth`), screenshot blocking and app-switcher cover (own `MethodChannel`: Android `FLAG_SECURE`, iOS cover view), a security settings page (D-041).
- No root/jailbreak detection on purpose: client-side checks give false confidence (D-041).
- Social sign-in is an extension point only. `google_sign_in`, `firebase_auth` and `cloud_firestore` are kept on purpose for each app's own login and data (owner rule, D-012); template code does not import them.

### Navigation
- ONE `GoRouter` (`appRouterProvider`), typed routes (`go_router_builder`) in `core/router/routes.dart`, a stateful shell with separate stacks (Home, More).
- Forced-update and maintenance gate pages (`/force-update`, `/maintenance`) driven by remote config; a soft-update banner in the shell.
- Deep links: an https app link and the custom scheme `riverpod-core` resolve to the same typed routes (`ai-docs/DEEP_LINKS.md`).
- Every page declares `static const routeName`; there is no central paths class (D-036).
- `routeForDeepLink(type, id)` is the single mapping used by notification taps and deep links.
- Dev-only routes (`/showcase`, `/videos`) redirect home in prod.

### UI
- Material 3 design tokens as `ThemeExtension`s (`context.tokens`): color (from one seed + success/warning/info), type, spacing, radius, elevation, motion, component sizes. Light, dark and system modes.
- Responsive helpers (phone < 600, tablet 600-1023, desktop >= 1024; content max width 720), the system text scale is honored and only clamped to 0.8x-2.0x (never replaced by a fixed value).
- A broad widget library in `core/design_system/widgets/` (buttons, inputs, selection, sheets, dialogs, snackbars/toasts/banners/progress/tooltips, cards/list tiles/avatars/badges/chips/images/accordion, scaffold/app bars/tabs/bottom nav/stepper, async states, paginated list, video player, permission rationale, app lock screen).
- A live component gallery at `/showcase` (dev and staging only).
- RTL-correct layouts (directional APIs only) and `Semantics`/touch-target rules.

### Localization
- `easy_localization` with `ar` (RTL) and `en` (LTR), runtime switch without restart, saved locale, plurals.
- Generated `LocaleKeys` only (D-037), guarded by a test; ar/en key parity test.
- Locale-aware formatters (`context.formatters`, `pluralText`, `relativeTime`) with Latin digits by default (D-030).

### Notifications
- FCM push and local notifications behind `*Backend` interfaces (no singletons): channels, groups, iOS categories, scheduling (exact when allowed, inexact fallback), badge, topics, foreground/background/terminated handling, deduplication.
- Taps resolve to typed routes (`NotificationRouter`), queued until sign-in; permission flow through the shared `PermissionService`; per-channel user settings; token registration to YOUR backend through `PushTokenRegistrar`. Details: `ai-docs/NOTIFICATIONS.md`.
- Push is off, with one log line, when Firebase is not configured.

### Production services
- Leveled logger that is silent in prod and masks secrets (`core/logger`).
- `CrashReporter` and `AnalyticsService` interfaces (`core/crash`, `core/analytics`) with no-op, console and Firebase (Crashlytics, Analytics) implementations. The Firebase ones are used only when the config flag is on AND Firebase is configured; otherwise no-op (D-042, `ai-docs/FIREBASE.md`). A persisted consent switch applies to both; only an opaque user id is sent.
- Remote config from your own endpoint (D-040): force update, maintenance mode, feature flags (`flagProvider(name)`), cached through the cache-first helper and never blocking startup.
- Launcher icon and native splash (generic placeholders on the brand seed, regenerated with `flutter_launcher_icons` / `flutter_native_splash`).
- Share (`ShareService`), external links with a scheme allow-list (`ExternalLinks`), in-app review throttled to once per 90 days (`ReviewService`), app info + About page with licenses.
- Image picking, cropping and compression, file picking (`MediaService`); permissions with rationale and open-settings (`PermissionService`).

### Quality
- About 110 test files mirroring `lib/`, fakes for every native seam (`test/helpers/`), 200+ golden baselines (light/dark, ar/en, tablet, 2.0x text), translation parity and no-literal-keys guard tests, tool tests.
- GitHub Actions CI: gate + coverage artifact + debug Android and iOS builds (no secrets), plus an optional nightly/on-demand iOS integration job.
- Integration test of the real app flow and a clean-clone smoke script (`tool/smoke.sh`).
- Release scripts with untracked signing; a release build without `android/key.properties` is refused.

## Architecture

Style: feature-first, pragmatic layering, Riverpod (codegen) for DI and state. No domain layer: no entities, use cases or abstract repositories (D-015).
Flow: `page -> provider -> repository -> data source`.

```
lib/
├── main.dart / main_staging.dart   # thin: bootstrap(Flavor.current) / bootstrap(Flavor.staging)
├── core/                           # app-agnostic infrastructure + the design system
│   ├── bootstrap/                  # zones, error handlers, config load + validate, ProviderScope, runApp
│   ├── app/                        # MaterialApp.router, theme, locale, text scale
│   ├── router/                     # appRouterProvider, typed routes.dart, guards/app_redirect.dart, shell
│   ├── startup/                    # splash page + startup sequence
│   ├── config/                     # AppConfig, Flavor, EnvLoader (the ONLY dotenv user), validation
│   ├── network/                    # dio_client.dart, interceptors/, pagination/, transfer/
│   ├── errors/                     # AppException, error_mapper.dart, error_messages.dart
│   ├── storage/                    # secure_storage, prefs_storage, hive_boxes, clear_user_data, cache/ (store, policy, helper, pruner)
│   ├── auth/                       # SessionController, tokens, auth_endpoints.dart, session epoch
│   ├── connectivity/               # online/offline stream
│   ├── notifications/              # push + local notifications, routing, settings
│   ├── analytics/  crash/  firebase/   # interfaces + no-op/console/Firebase impls; optional Firebase init + consent
│   ├── remote_config/              # model, app gate (version compare), source, repository, flags
│   ├── localization/               # supported locales, translations path
│   ├── logger/  permissions/  device/  media/  security/
│   ├── sharing/  links/  review/  app_info/
│   ├── design_system/              # the ONLY place UI primitives are implemented
│   │   ├── tokens/  theme/  responsive/
│   │   └── widgets/                # buttons inputs selection bottom_sheets dialogs feedback display layout async lists media permissions security
│   └── utils/                      # validators, formatting/ (numbers, dates, plurals, relative time)
├── shared/models/                  # cross-feature models (AuthUser)
├── features/<feature>/             # app_gate, auth, home, items, more, onboarding, showcase, videos
│   ├── data/                       # models/ (freezed + json), sources/ (remote, mock), <feature>_repository.dart
│   ├── providers/                  # notifiers, no widgets
│   └── presentation/               # pages/ (one page per file) and widgets/
└── generated/                      # LocaleKeys + codegen loader (committed)
assets/translations/{ar,en}.json    env/*.env.example    tool/ (rename_app, new_feature, smoke.sh, release/)
test/    integration_test/    .fttemplates/feature
```

### Layering rules and why

| Rule | Reason |
|---|---|
| `presentation -> providers -> data -> core/shared`; a feature never imports another feature's internals | features stay deletable and parallelizable; shared need goes to `core/`, `shared/` or the design system |
| `core/design_system` imports only Flutter, `core/utils`, `core/errors`, `core/connectivity` and generated keys (D-031) | the UI kit stays reusable and cannot depend on app logic |
| Non-UI `core/` folders never import the design system; `core/` never imports `features/` except router/bootstrap/app wiring | keeps infrastructure testable without UI |
| UI primitives exist only in `core/design_system/` (hard rule 8) | one look, one implementation to fix |
| Repositories return models or throw `AppException`; pages and providers never touch Dio | errors are mapped once; the UI never inspects HTTP codes |
| `@riverpod` only; repositories/services/session/config are keepAlive, page state is autoDispose; no singletons, no service locators | testable by provider overrides; no hidden global state |
| No hard-coded text, colors, sizes, durations in features | tokens and `LocaleKeys` make rebranding and translation one-place changes |
| Directional APIs only (`EdgeInsetsDirectional`, `AlignmentDirectional`) | RTL for free |
| Config only through `AppConfig`; `dotenv` only in `core/config` | one place to validate and audit |
| One page per file with `static const routeName`; navigation only through typed routes | deep links and notification taps share the same routes |
| A new folder or layer exception needs a DECISION | the tree stays honest |

Error model, Riverpod patterns and startup order: `ai-docs/ARCHITECTURE.md`. Naming and imports: `ai-docs/CONVENTIONS.md`.

## Packages

Versions are the exact entries in `pubspec.lock`. Licences are read from each package's `LICENSE` file in the pub cache
(or recorded in DECISIONS where noted). "Chosen/rejected" cites a decision when one exists; an empty cell means the
choice has no recorded alternative (it is the standard package for that job).

### Dependencies

| Package | Locked | Used for in this repo | Why / rejected | Licence |
|---|---|---|---|---|
| flutter, flutter_localizations | SDK | framework; Material/Cupertino localization delegates | | BSD-3 |
| flutter_riverpod | 3.4.3 | DI and state | one state tool; rejected hand-written legacy providers (D-002) | MIT |
| riverpod_annotation | 4.0.7 | `@riverpod` annotations | with `riverpod_generator` | MIT |
| go_router | 18.1.0 | the single router, redirects, stateful shell | rejected separate routers per device (D-005) | BSD-3 |
| dio | 5.11.1 | the one HTTP client and interceptors | rejected `http_mock_adapter` for tests (hand-written fake adapter, NETWORKING.md) | MIT |
| flutter_dotenv | 6.0.1 | parses `env/<flavor>.env` (only in `core/config/env_loader.dart`) | rejected `--dart-define-from-file` (friction) and committed env files (D-024) | MIT |
| freezed_annotation | 3.1.0 | immutable models/state, `fromJson` hooks | rejected `built_value`, `dart_mappable` (D-002) | MIT |
| json_annotation | 4.12.0 | runtime for `json_serializable` output (generated `*.g.dart`; no direct import in `lib/`) | | BSD-3 |
| easy_localization | 3.0.8 | ar/en, runtime switch, plurals, `LocaleKeys` generation | rejected `gen_l10n` (D-007); no own locale controller (D-035) | MIT |
| intl | 0.20.3 | date/number formatting behind `AppFormatters` | | BSD-3 |
| flutter_secure_storage | 11.2.0 | tokens only (`SecureStorage`) | never prefs/DB/logs for secrets | BSD-3 |
| hive_ce, hive_ce_flutter | 2.22.0, 2.5.0 | the only local store: settings box and cache box (`PrefsStorage`, `CacheStore`) | owner choice (D-034): one simple store; replaced `shared_preferences` and Drift; no SQL or migrations | BSD-3 + Apache-2.0 (both texts in its LICENSE) |
| path_provider | 2.1.6 | transfer and image-processing directories | | BSD-3 |
| connectivity_plus | 7.3.2 | online/offline events (`ConnectivityService`) | plugin events, never a DNS lookup | BSD-3 |
| cached_network_image | 4.0.4 | behind `AppImage` only | disk+memory cache; rejected `Image.network`, own cache (D-021) | MIT |
| skeletonizer | 3.0.0 | behind `Skeleton` (loading state) | | MIT |
| video_player | 2.14.1 | behind `AppVideoPlayer` | official; rejected `chewie`, `better_player` (D-027) | BSD-3 |
| uuid | 4.6.0 | idempotency keys | | MIT |
| image_picker | 1.2.4 | camera/gallery via `MediaService` | | Apache-2.0 (as shipped) |
| image_cropper | 13.0.0 | crop via `MediaService` | rejected `crop_your_image` (D-033) | BSD-3 |
| file_picker | 13.1.0 | file picking via `MediaService` | own picking rejected (D-033) | MIT |
| flutter_image_compress | 2.5.1 | JPEG re-encode in the media pipeline | | MIT |
| permission_handler | 13.0.2 | behind `PermissionService` | | MIT |
| firebase_core | 5.0.0 | `Firebase.initializeApp()` once through `FirebaseBootstrap`; failure = push, Crashlytics and Analytics off | optional Firebase (D-042) | BSD-3 |
| firebase_crashlytics | 6.0.0 | `CrashlyticsBackend` behind `CrashReporter` | owner choice (D-042); Sentry stays an alternative behind the same interface | BSD-3 |
| firebase_analytics | 13.0.0 | `AnalyticsBackend` behind `AnalyticsService` | D-042 | BSD-3 |
| firebase_messaging | 17.0.0 | FCM in `firebase_push_backend.dart` only | deprecated token calls kept on purpose (D-039) | BSD-3 |
| flutter_local_notifications | 22.3.2 | local notifications backend | | BSD-3 |
| timezone, flutter_native_timezone_latest | 0.11.2, 1.0.0 | scheduled notifications in the device time zone (UTC fallback) | | BSD-2, MIT |
| device_info_plus | 13.3.0 | `DeviceInfo` (platform, model, OS; no hardware ids) | | BSD-3 |
| local_auth | 3.0.2 | biometric app lock (`BiometricService`) | D-041 | BSD-3 |
| share_plus | 13.3.1 | `ShareService` | D-041 | BSD-3 |
| in_app_review | 2.0.12 | `ReviewService` | D-041 | MIT |
| package_info_plus | 10.2.2 | `AppInfo`, About page | D-041 | BSD-3 |
| url_launcher | 6.3.3 | `ExternalLinks` (scheme allow-list) | | BSD-3 |
| cloud_firestore, firebase_auth, google_sign_in | 7.0.0, 7.0.0, 7.2.0 | kept on purpose for the app's login and data; **not imported by any template code** | owner rule (D-012); the template never writes to Firestore | BSD-3 |

### Dev dependencies

| Package | Locked | Used for | Licence |
|---|---|---|---|
| build_runner | 2.16.2 | runs all code generators | BSD |
| riverpod_generator | 4.0.9 | `@riverpod` providers (`*.g.dart`) | MIT |
| freezed | 4.0.2 | immutable classes and unions | MIT |
| json_serializable | 6.14.1 | `fromJson`/`toJson` | BSD |
| go_router_builder | 4.5.0 | typed routes (`routes.g.dart`, D-016) | BSD |
| mocktail | 1.0.5 | mocks in tests | MIT |
| flutter_test | SDK | unit/widget/golden tests | BSD-3 |
| flutter_lints | 6.0.0 | base lint set | BSD |
| flutter_launcher_icons | 0.14.4 | launcher icons from `assets/images/app_icon*.png` (config block in `pubspec.yaml`) | MIT |
| flutter_native_splash | 2.4.8 | native splash (light/dark, Android 12) from the `pubspec.yaml` block | MIT |
| integration_test | SDK | `integration_test/` flow test | BSD-3 |
| rename_app | 1.6.6 | listed in pubspec; the supported rename path is our own `tool/rename_app.dart` | MIT |

Removed on the way: `shared_preferences`, `drift`, `drift_flutter`, `drift_dev` (D-034). (`shared_preferences` remains in the lock file only as a transitive dependency of `easy_localization`.)
`riverpod_lint`/`custom_lint` are NOT used: they cannot resolve with the current riverpod 3 / freezed 4 / uuid 4 stack (D-017).
Any new package is a DECISION with reason, alternatives, latest stable version and licence (hard rule 11).

## Environment setup

Config lives in `env/<flavor>.env`. The three `*.env.example` files are committed; the real `*.env` files are git-ignored and bundled
as assets (the whole `env/` folder is an asset, so a missing real file is reported by the app rather than breaking the build).

```bash
for f in env/*.env.example; do cp "$f" "${f%.example}"; done   # same loop CI uses
```

| Key | Meaning |
|---|---|
| `APP_NAME` | display name (required) |
| `API_BASE_URL` | absolute backend URL (required; `https` for staging and prod) |
| `CONNECT_TIMEOUT_MS`, `RECEIVE_TIMEOUT_MS` | positive milliseconds (required) |
| `LOG_LEVEL` | `debug`, `info`, `warning`, `error`, `off` (optional; per-flavor default) |
| `ENABLE_CRASH_REPORTING`, `ENABLE_ANALYTICS` | `true`/`false` (optional) |
| `CRASH_DSN` | optional crash-vendor DSN (unused by the Firebase implementation) |
| `APP_VERSION` | optional override of the installed version, to test the update gate; blank = real version; `x.y.z` when set |
| `REMOTE_CONFIG_PATH` | remote-config endpoint path, default `/app/config`, must start with `/` |
| `REMOTE_CONFIG_MOCK` | `true` serves a mock remote config (default `false`) |

- Flavor selection is automatic and lives in ONE place (`Flavor.current`): debug and profile builds use `dev`, release builds use `prod`.
  Staging is explicit: `flutter run -t lib/main_staging.dart`.
- Startup validates every key and lists every problem on a plain error screen (`ConfigErrorApp`) instead of crashing.
- The values are **bundled in the app**: never put real secrets in env files. Secrets that must stay private belong on the server.
- No native Android flavors / iOS schemes ship by default, so plain `flutter run` needs no `--flavor` (D-043). If an app needs different
  bundle ids per environment it adds native flavors itself; see "Start a new app from this template" above.

## Run and install

Prerequisites (verified): Flutter 3.47.0 stable (CI pins this version; Dart `^3.10.1` per `pubspec.yaml`), JDK 17+ (21 works),
Android SDK with platform 37, Xcode and CocoaPods for iOS (`pod install` runs on the first iOS build). Platforms: Android and iOS only (D-022).

```bash
git clone <your repo> && cd <your repo>
for f in env/*.env.example; do cp "$f" "${f%.example}"; done
flutter pub get
flutter run                                  # dev flavor on the connected device or emulator
flutter run -t lib/main_staging.dart         # staging
flutter run --release                        # prod flavor; needs android/key.properties on Android (see Release)
```

Generated code (`*.g.dart`, `*.freezed.dart`, `lib/generated/*`) is committed, so a fresh clone does not need code generation.
Regenerate after changing annotated classes, routes or translation JSON:

```bash
./build.sh                  # easy_localization (2 commands) + build_runner build --delete-conflicting-outputs
dart format lib/generated   # the l10n generators emit unformatted Dart; CI checks this
```

`build.sh` is the single source of the generation commands: `dart run easy_localization:generate --source-dir assets/translations`,
`dart run easy_localization:generate -S assets/translations -f keys -o locale_keys.g.dart`, then `dart run build_runner build --delete-conflicting-outputs`.

Android: debug builds need nothing else. iOS: open `ios/Runner.xcworkspace` once to pick your signing team for device builds; the
simulator needs no signing. The default `dev` backend URL (`http://10.0.2.2:8080`) is the Android emulator's host loopback; change it
in `env/dev.env`. With `authUseMockSource = true` (default in `lib/core/auth/auth_endpoints.dart`) the login flow works with no backend,
and the demo `videos` feature uses a mock source (dev/staging only).

## Remote config, app lock and deep links

- **Remote config (D-040):** one JSON endpoint (`REMOTE_CONFIG_PATH`, default `/app/config`) read through Dio and the cache-first helper (`short` preset), so the app starts offline with the cached copy or defaults.
  Fields: `minVersion`, `latestVersion`, `storeUrl`, `maintenance {enabled, message}`, `flags`. `gateStatusFor` gives `ok`, `updateAvailable`, `updateRequired` or `maintenance` (maintenance wins; an unreadable version never blocks).
  The router sends maintenance and forced update to `/maintenance` and `/force-update` ahead of sign-in; a dismissible soft-update banner sits above the tab bar. Startup waits at most 3 s for it and never fails because of it.
  Feature flags: `ref.watch(flagProvider('name'))` (false by default). Set `REMOTE_CONFIG_MOCK=true` or `APP_VERSION` to try the gate locally.
- **App lock (D-041):** biometric lock (`local_auth`) that locks at cold start and when the app returns after a timeout (`appLockTimeoutProvider`, default 30 s), covers the app in the app switcher,
  and holds screenshot blocking while enabled. The user switches it on in More -> Security (`/security-settings`). Own `MethodChannel` for Android `FLAG_SECURE` and the iOS cover view.
- **Deep links (`ai-docs/DEEP_LINKS.md`):** the custom scheme `riverpod-core://videos/abc` works with no server; the https app link `https://example.com/videos/abc` needs a domain you own
  (`assetlinks.json`, `apple-app-site-association`). Both are rewritten into the same typed routes (`routeForAppLink`, `routeForDeepLink`; mapped types: `items`, `myEvents`, `videos`) and a link that arrives before sign-in is replayed after it.
  iOS Universal Links are opt-in: the template does not ship the Associated Domains entitlement because a free Apple team cannot sign it (steps in DEEP_LINKS.md).
  Host and scheme are placeholders (`example.com`, `riverpod-core`) kept in agreement across Dart, manifest, Info.plist and entitlements; `tool/rename_app.dart --host links.company.com` rewrites them.

## Firebase, Crashlytics and push stay optional

The rule (D-042): the template must run with zero project data. Nothing may require `google-services.json` or `GoogleService-Info.plist`.

- **Init:** `FirebaseBootstrap.ensureInitialized()` runs `Firebase.initializeApp()` once for push, Crashlytics and Analytics. It never throws; without the native files it logs one line
  ("Firebase not configured: crash/analytics disabled"), and push logs "Push is disabled". `pushAvailableProvider` is false, topic/token calls are no-ops, and everything else keeps working.
- **Crashlytics and Analytics (D-042):** `crashReporterProvider` / `analyticsServiceProvider` return the Firebase implementation only when the config flag is on
  (`ENABLE_CRASH_REPORTING` / `ENABLE_ANALYTICS`; defaults: on for prod and staging, off for dev) AND Firebase started; otherwise the no-op. Global error handlers send fatal and non-fatal errors through `CrashReporter`.
  A persisted consent switch (`collectionConsentProvider`, default ON; flip `defaultCollectionConsent` for opt-in regions) applies to both. Only an opaque user id is sent; it is cleared on logout.
- **Native builds without Firebase files:** the Google Services and Crashlytics Gradle plugins apply only when `android/app/google-services.json` exists, and the iOS Crashlytics symbol-upload phase skips without `GoogleService-Info.plist`.
  Both files are ignored by version control. How to add Firebase, verify a test crash and switch vendor: `ai-docs/FIREBASE.md`.
- The template never writes to Firestore or any Firebase database; device and token go to YOUR backend through `PushTokenRegistrar` (default `NoopPushTokenRegistrar`).
- To enable push in an app: create the Firebase project, put `google-services.json` in `android/app/` and `GoogleService-Info.plist` in `ios/Runner/` (both git-ignored,
  never commit them), (the Gradle plugins switch on by themselves once the json exists), upload an APNs auth key
  and enable the Push Notifications and Background Modes capabilities. Full checklist, payload contract, console testing and troubleshooting: `ai-docs/NOTIFICATIONS.md`.
  Test pushes on a real iPhone, not the simulator.
- Server-side payload keys (`type` + `id`, `url`, `channel`) and how taps map to typed routes: `ai-docs/NOTIFICATIONS.md`; add your own types in `routeForDeepLink`.

## Start a new app from this template

The template holds no project data (D-042): you bring your own app name and id, env values, brand, optional Firebase files and signing keys.

1. **Prerequisites.** Flutter 3.47.0 stable (CI pins this), JDK 17+ (21 works), Android SDK (platform 37), Xcode + CocoaPods for iOS. Android and iOS only (D-022).
2. **Copy.** Clone or copy the repo, delete the `.git` folder, run `git init`, first commit "Initial commit from riverpod_core".
3. **Rename.** `dart run tool/rename_app.dart --name "My App" --id com.company.myapp`
   - Options: `--package my_app` (Dart package name, default derived from `--name`), `--host links.company.com` (deep-link https host, default `example.com`), `--dry-run` (print only; invalid input writes nothing).
   - It updates `pubspec.yaml` (name, description), every `package:riverpod_core/` import in `lib/`, `test/`, `integration_test/`, Android `namespace`/`applicationId`/`MainActivity` package and folder/manifest label,
     iOS `CFBundleDisplayName`/`CFBundleName` and `PRODUCT_BUNDLE_IDENTIFIER` (and `<id>.RunnerTests`), the first `# ` title of `README.md`, `APP_NAME` in `env/*.env*`, and the deep-link scheme (the package name with `-` for `_`).
   - Then run what it prints: `flutter pub get`, `./build.sh` (or `dart run build_runner build --delete-conflicting-outputs`), `dart format .`, `flutter analyze`. Write your own `README.md` afterwards (only its title is renamed).
4. **Environments.** `for f in env/*.env.example; do cp "$f" "${f%.example}"; done`, then fill `env/dev.env`, `env/staging.env`, `env/prod.env`
   (keys: `APP_NAME`, `API_BASE_URL`, `CONNECT_TIMEOUT_MS`, `RECEIVE_TIMEOUT_MS`, optional `LOG_LEVEL`, `ENABLE_CRASH_REPORTING`, `ENABLE_ANALYTICS`, `CRASH_DSN`, `REMOTE_CONFIG_PATH`).
   - `flutter run` = dev (debug), `flutter run --release` = prod, `flutter run -t lib/main_staging.dart` = staging (D-024). Staging and prod need an `https` base URL.
   - The app refuses to start, with an on-screen list of problems, if a required key is missing or invalid. The real `env/*.env` files are git-ignored and bundled in the app: never put real secrets in them.
   - Set `authUseMockSource` to `false` in `lib/core/auth/auth_endpoints.dart` and set your real endpoints there once your backend exists.
5. **Firebase (optional).** Skip it and the app still runs: push is off with one log line, everything else works.
   - Push: create the Firebase project, add `google-services.json` to `android/app/` and `GoogleService-Info.plist` to `ios/Runner/` locally (git-ignored, never commit; the Gradle plugins and the iOS symbol-upload phase switch on by themselves once the files exist),
     upload an APNs auth key, enable Push Notifications + Background Modes (Remote notifications). Implement `PushTokenRegistrar` for your API and override `pushTokenRegistrarProvider`; add your notification `type` values to `routeForDeepLink` in `core/router/routes.dart`. Checklist and testing: `ai-docs/NOTIFICATIONS.md`.
   - Crashlytics and Analytics (D-042): same two files, then `ENABLE_CRASH_REPORTING=true` / `ENABLE_ANALYTICS=true` in the env files you want. Details, test crash, vendor switch: `ai-docs/FIREBASE.md`.
   - Native flavors are optional (D-043): the template ships none. If you need different bundle ids per environment, add Android `productFlavors` and iOS schemes yourself, run with `--flavor <name> -t lib/main_staging.dart`, keep `Flavor.current`, one `google-services.json` per flavor directory, and a deep-link scheme per flavor.
6. **Branding, icons, splash.**
   - Edit ONLY `lib/core/design_system/tokens/brand_config.dart` (`brandSeedColor`, `brandFontFamily`). Replace the Android notification icon `android/app/src/main/res/drawable/ic_notification.xml`.
   - Icon: replace `assets/images/app_icon.png` (1024 px) and `assets/images/app_icon_foreground.png` (1024 px, transparent, artwork inside the central 66%) (placeholders come from `dart run tool/generate_placeholder_icon.dart`),
     set `adaptive_icon_background` in the `flutter_launcher_icons` block of `pubspec.yaml`, run `dart run flutter_launcher_icons`, commit the generated files. If it rewrites `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS` in `ios/Runner.xcodeproj/project.pbxproj` to `AppIcon`, revert that line to `YES`.
   - Native splash: set colors and image in the `flutter_native_splash` block of `pubspec.yaml` (same color as the seed), run `dart run flutter_native_splash:create`, commit. If it re-indents `ios/Runner/Info.plist`, keep only the real changes.
7. **Deep links.** The custom scheme works at once; https links need your domain (`--host`, `assetlinks.json`, `apple-app-site-association`); iOS Universal Links need a paid Apple team and are opt-in. Full guide: `ai-docs/DEEP_LINKS.md`.
8. **Translations.** Edit `assets/translations/{ar,en}.json` (both files, same commit), then `./build.sh` and `dart format lib/generated`, and commit the regenerated `lib/generated/*`.
   Use ONLY `LocaleKeys.group_key.tr()` in code (D-037); the parity and no-literal-keys tests must stay green. Recipe: `.claude/skills/add-translation-keys/SKILL.md`.
9. **First feature.** `dart run tool/new_feature.dart --name product_orders` (`--dry-run` previews). Replace the model fields and endpoint, paste the printed route into `routes.dart`, run the printed generation commands. Read features are cache-first through `CachedRepositoryHelper.load` with a `CachePolicy` preset (D-038); never hand-roll expiry.
10. **Demo features.** `features/showcase` (`/showcase`) and `features/videos` exist only in dev and staging builds. Delete them when you ship: remove the two feature folders, their routes in `routes.dart` and the two dev-only tiles in `features/home/presentation/pages/home_page.dart`, then regenerate and fix tests (including `integration_test/app_flow_test.dart`). Nothing else imports them (D-028).
11. **Storage.** `hive_ce` behind `PrefsStorage` (settings) and `CacheStore` (cache); secrets in `flutter_secure_storage` behind `SecureStorage`. Use those three only (D-034). Logout clears secrets, cache and user-scoped settings in `SessionController.logout`; user-scoped keys use the `user.` prefix (settings) or `user/<id>/` (cache).
12. **Remote config and app lock.** Remote config (D-040): serve one JSON endpoint at `REMOTE_CONFIG_PATH` (default `/app/config`) with `minVersion`, `latestVersion`, `storeUrl`, `maintenance {enabled, message}` and `flags`; it drives the forced-update and maintenance pages, the soft-update banner and `flagProvider(name)`.
    `REMOTE_CONFIG_MOCK=true` serves a mock; `APP_VERSION` overrides the installed version to test the gate. App lock needs no configuration (More -> Security; override `appLockTimeoutProvider` for another timeout).
13. **Gate before every commit.** The Definition of Done in `CLAUDE.md` (see "Daily workflow"). CI (`.github/workflows/ci.yml`) runs the same plus a stale-generated-code check and debug builds for Android and iOS.
14. **Release.** Android: `cp android/key.properties.example android/key.properties`, fill it, keep the keystore outside the repo. iOS: pick your team in Xcode, `cp ios/ExportOptions.plist.example ios/ExportOptions.plist`.
    Build with `tool/release/build_android.sh` and `tool/release/build_ios.sh` (`[--flavor staging|prod]`; they run the gate, then obfuscated release builds; see `tool/release/README.md`). Before shipping run `.claude/skills/release-check/SKILL.md`. Signing files and `build-symbols/` stay untracked.
15. **Integration and smoke.** `flutter test integration_test/app_flow_test.dart -d <simulator-udid>` drives the real app (not in the default gate); `tool/smoke.sh [udid]` proves a clean clone works (commit first). See "Integration test and smoke script".
16. **Not verified in the template; check on real devices in your app:** biometric app lock, Android `FLAG_SECURE` and the iOS cover view, FCM/APNs delivery, Crashlytics delivery, https link verification.
    Verified toolchain: Gradle 8.14.3, AGP 8.11.1, Kotlin 2.4.0, `compileSdk` 37, `minSdk` 24, iOS 15.0.

### Scaffold a feature

`dart run tool/new_feature.dart --name product_orders` creates `lib/features/product_orders/` (freezed model, Dio remote source with the endpoint in one constant,
repository with one read method, `AsyncNotifier` controller, page with `routeName` and `AsyncValueView`) and `test/features/product_orders/`
(repository, controller, page tests including light/dark x ar/en x tablet x 2.0x text), and adds a translation group to BOTH JSON files. It never edits
`routes.dart`: it prints the typed-route snippet to paste, then the generation commands. It refuses invalid names and anything that already exists.
Templates live in `.fttemplates/feature` (`*.tmpl`, so they are never analyzed as code). The recipe is `.claude/skills/new-feature/SKILL.md`.

## Daily workflow

The gate (definition of done, `CLAUDE.md`) on every change:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # only if codegen is touched
dart format --set-exit-if-changed lib test
flutter analyze                                           # 0 issues
flutter test                                              # all green
```

Repo process for AI sessions: small branch, commits by explicit path, never push or amend, update the doc that owns a rule when behaviour changes (see `CLAUDE.md`). Skills (step-by-step recipes) are in `.claude/skills/`:
`new-feature`, `new-page`, `new-api-call`, `add-translation-keys`, `review-task`, `release-check`.

## Localization

- Languages: `ar` (RTL) and `en` (LTR), files `assets/translations/{ar,en}.json`. The locale is saved and switched by `easy_localization`
  (`context.locale`, `context.setLocale`); there is no own locale controller (D-035).
- User text is ALWAYS `LocaleKeys.group_key.tr()` (or `.plural`) from `lib/generated/locale_keys.g.dart`. Never `'group.key'.tr()` with a literal and never
  hand-written key-constant files (D-037). `test/translations/no_literal_keys_test.dart` fails with `file:line` for any literal call under `lib/`.
- Workflow: add the key to BOTH JSON files in the same commit -> `./build.sh` -> `dart format lib/generated` -> commit the regenerated files with your change.
  `test/translations/translation_parity_test.dart` checks ar/en key parity, empty values and placeholders. Recipe: `.claude/skills/add-translation-keys/SKILL.md`.
- Keys: `feature.screen.element` lowerCamelCase segments; errors under `errors.*`, shared copy under `common.*`.
- Numbers, dates, plurals and relative times: `context.formatters`, `pluralText`, `relativeTime` (`core/utils/formatting`). Latin digits by default (D-030).

## Design system tour

Everything UI lives in `lib/core/design_system/`. Details and the widget catalog: `ai-docs/DESIGN_SYSTEM.md`.

- **Rebrand in one file:** `tokens/brand_config.dart` (seed color, font). The theme (`theme/app_theme.dart`) builds light and dark from it. The template ships a neutral seed.
- **Tokens:** `context.tokens` gives spacing (4-pt scale), radius, elevation, motion and component sizes; no raw hex, font sizes, paddings or durations in features.
- **Widgets:** one folder per family, one file per widget; `widgets/widgets.dart` is the barrel. Features compose these and never use raw `ElevatedButton`/`TextField`.
- **The 8 data states:** `AsyncValueView<T>` takes an `AsyncValue<T>` plus `isEmpty`, `isStale`, `hasPartialError` and renders loading skeleton, `EmptyState`,
  `ErrorState` (with an offline variant and retry), stale/offline banner, partial-error row with retry, refresh indicator without layout jump, and content.
- **Showcase page:** in a dev or staging build open **Home -> Component gallery** (`/showcase`). It shows every widget live, with a light/dark toggle, an ar/en toggle and a
  text-scale slider from 0.8x to 2.0x. In prod the route redirects home.
- **Reference feature:** `features/videos` (Home -> Videos, dev/staging) is a complete feature on a mock source with a "simulate" menu that triggers every data state
  (success, empty, error, offline, slow, partial). It is also the model for the feature scaffold.

## Data layer: cache-first

The rule (D-038, owner): every feature that reads data is cache-first through ONE helper in `core/storage/cache/`:
emit the cached value at once (flagged stale when older than its ttl), revalidate in the background, keep the cache when the server data is unchanged,
write and emit only when it changed, keep serving the cache (stale/offline states) when the network fails, error only when there is no cache.
User-scoped keys include the user id, logout clears everything, features pick a `CachePolicy` preset and never hand-roll expiry.

**How it works (`CachedRepositoryHelper`, `CachePolicy`, `CacheStore`, `CachePruner`):**
- Repositories make one call: `load<T>(key, fetch, decode, encode, policy, fresh)`. The cached value returns at once (flagged stale when older than `policy.ttl`) and the revalidation finishes in the background.
  `watch<T>` is the stream form. `fresh: true` (pull-to-refresh, reload) waits for the network and raises its error even when a cached copy exists.
- Revalidation sends the stored ETag as `If-None-Match`; a 304 or an identical payload only moves the retention fields. A changed payload is written and emitted once. On failure the cache keeps serving, flagged stale with the mapped error; with no cache the call errors.
- Presets: `short` 5 min fresh / 1 day kept, `medium` 1 h / 7 days (default), `long` 1 day / 30 days, `static` 7 days / 90 days. Features pick a preset and never hand-roll expiry.
- Retention: entries record `savedAt`, `lastAccessedAt`, `etag`, `ttl`, `maxAge`. `CachePruner` removes entries past their `maxAge`, then least-recently-accessed entries above 500; `CachePruneScheduler` runs it after the first frame and on resume when the last prune is over 24 h old.
- Keys are `shared/<key>` or `user/<id>/<key>`; logout clears the whole cache.
- Used today by the `videos` feed, remote config, and the feature scaffold (`tool/new_feature.dart` generates `fetchItems({fresh})` on this helper).

## Testing

`test/` mirrors `lib/`. Packages: `flutter_test`, `mocktail`. Rules and minimums per code type: `ai-docs/TESTING.md`.

```bash
flutter test                              # everything
flutter test test/core/errors             # one folder
flutter test --coverage                   # what CI runs
flutter test --update-goldens <file>      # only for goldens your change owns, and say so in the report
```

- **Helpers** (`test/helpers/`, import `helpers.dart`): `pumpApp` (ProviderScope + localization + theme, with locale/theme/text scale/size), `createContainer`, `FakeHttpAdapter`
  (hand-written Dio adapter), in-memory fakes for secure storage, prefs, connectivity, crash reporter, analytics, native backends and notification backends. No test needs a platform channel.
- **Determinism:** no real network, no real clock (inject a clock or use `fakeAsync`), no sleeping. A bug fix starts with a failing test.
- **Goldens:** live in `test/goldens/<area>/`, use a fixed test font and pixel ratio from the helper, cover light/dark x ar/en (and tablet / 2.0x text where the page needs it).
  Never regenerate goldens blindly: a changed baseline is a visual change that needs review.
- **Translation tests:** `test/translations/translation_parity_test.dart` (ar/en keys, no empty values, matching placeholders).
- **Guard tests:** `test/translations/no_literal_keys_test.dart` (no `.tr()`/`.plural()` on a string literal under `lib/`); `test/tool/*` cover the rename and feature scripts.
- **Never delete or weaken a test** without writing in the report which behaviour stopped being true (hard rule 6).

## Integration test and smoke script

- `integration_test/app_flow_test.dart` drives the real app through `bootstrap` on a device or simulator: onboarding, wrong then right credentials, videos, first video, favorite, back to home.
  It uses seams, not mocks of the app (mock remote config, fake video player backend, in-memory secure storage, fresh settings and cache, an env with no real values). The More -> About -> logout test is skipped (see Known open items).
  Run: `flutter test integration_test/app_flow_test.dart -d <simulator-udid>`.
- `integration_test/screens_test.dart` + `screens_driver.dart` walk the screens for screenshots; they write PNGs only under `flutter drive` with `--dart-define=CAPTURE_SCREENS=true` and `SCREENS_DIR` set.
  Real screenshots from the iPhone 17 Pro simulator (onboarding, login, home, videos, video detail, More, and the component gallery in English/Arabic, light/dark) are committed in [docs/screenshots](docs/screenshots/README.md).
- `tool/smoke.sh [simulator-udid]` is the clean-clone proof: it copies `HEAD` into a temp dir, refuses Firebase and keystore files, uses only `env/*.env.example`, then runs pub get, codegen, format, analyze, `flutter test`, the Android and iOS debug builds and the flow test, exiting non-zero on the first failure
  (`SKIP_ANDROID=1` skips the Android build). It never touches your working tree and tests committed code only, so commit first.

## CI

`.github/workflows/ci.yml` runs on every push and pull request, needs no secrets, and cancels superseded runs:
1. `test`: pub get, env files from the examples, regenerate translations, `build_runner`, fail if tracked generated code is stale, `dart format --set-exit-if-changed lib test tool`,
   `flutter analyze`, `flutter test --coverage`, upload `coverage/lcov.info`.
2. `build-android`: `flutter build apk --debug` (JDK 17).
3. `build-ios`: `flutter build ios --no-codesign --debug` (macOS runner).
4. `integration-ios` (optional, nightly and on demand, not a required PR check): boots an iPhone simulator and runs the flow test.

Flutter is pinned to 3.47.0 (`FLUTTER_VERSION` in the workflow); bump it deliberately. Details and verified action versions: `.github/workflows/README.md`.

## Release

Scripts in `tool/release/` (run from anywhere; they run format, analyze and test first, then build with `--obfuscate --split-debug-info=build-symbols/<platform>`):

```bash
tool/release/build_android.sh [--flavor staging|prod]   # -> build/app/outputs/bundle/release/app-release.aab
tool/release/build_ios.sh     [--flavor staging|prod]   # -> build/ios/ipa/*.ipa
```

Signing material is never committed:
- **Android:** `cp android/key.properties.example android/key.properties` and fill in `storePassword`, `keyPassword`, `keyAlias`, `storeFile` (keystore kept OUTSIDE the repo).
  Without that file a release build fails with "Release build requires android/key.properties"; the debug key is never used for a release artifact.
- **iOS:** pick your team in Xcode, then `cp ios/ExportOptions.plist.example ios/ExportOptions.plist` and set `teamID`/`method`.
- `build-symbols/` is git-ignored: archive the maps per release to de-obfuscate crash stack traces.

Release checklist (the `release-check` skill expands it): gate green and goldens unchanged; `env/prod.env` real values with an `https` URL, crash reporting on, quiet log level;
`authUseMockSource` set to `false` and endpoints real; no secrets tracked (`git ls-files | grep -E "google-services.json|GoogleService-Info.plist|\.jks|\.keystore|\.env$|key\.properties"` is empty);
signed with your own key; `version:` in `pubspec.yaml` bumped; app id is yours (not `com.example.*`); launcher icon, splash and `ic_notification` are yours; permissions in the manifests match the code;
deep links verified on a real device; smoke test the release build (cold start, login, logout, offline banner, ar/en, dark mode, text scale 1.5x).
Details: `tool/release/README.md`, `.claude/skills/release-check/SKILL.md`.

## Troubleshooting

| Symptom | Cause and fix |
|---|---|
| App shows "Invalid app configuration" | an env file is missing/empty or a key is invalid: copy `env/<flavor>.env.example` to `env/<flavor>.env`, fix the listed problems, restart (hot reload does not reload assets) |
| `flutter test` fails with a missing env or asset error | create the `env/*.env` files from the examples (CI does the same) |
| Gradle: "Your project's Gradle version is lower than Flutter's minimum" | wrapper must be >= 8.14 (template: 8.14.3 in `android/gradle/wrapper/gradle-wrapper.properties`) |
| Kotlin: "Module was compiled with an incompatible version of Kotlin" | plugins ship Kotlin 2.4 metadata; the Kotlin Gradle plugin in `android/settings.gradle.kts` must be >= 2.4.0 |
| `compileSdk` error from `permission_handler_android` | `compileSdk = 37` in `android/app/build.gradle.kts` |
| Kotlin DSL error about `kotlinOptions { jvmTarget }` | removed in Kotlin 2.4: use `kotlin { compilerOptions { jvmTarget.set(JvmTarget.JVM_17) } }` (already done) |
| Flutter warns that Gradle < 9.1 / AGP < 9.0.1 will be dropped | known; plan the upgrade as its own task once Firebase and other plugins support AGP 9 |
| iOS build fails in CocoaPods | `cd ios && pod install --repo-update`; deployment target must be 15.0; the Podfile sets the `permission_handler` macros (camera, photos, microphone, notifications) |
| iOS notifications never arrive | real device, APNs key uploaded, Push capability on (see `ai-docs/NOTIFICATIONS.md`) |
| "Release build requires android/key.properties" | expected without signing material: create `android/key.properties` (see Release) |
| Stale lock / version solving fails | `flutter pub get`; then `flutter pub upgrade <package>` for one package; as a last resort `flutter clean` and `flutter pub get`. Do not hand-edit `pubspec.lock` |
| CI says generated code is stale | run `./build.sh` and `dart format lib/generated`, commit the result |
| `build_runner` conflicts | `dart run build_runner build --delete-conflicting-outputs` |
| Push is disabled on a device | Firebase files missing or Google Services plugin not applied (one log line says so) |
| Channel names show keys | channels are created by `NotificationLabelSync` after translations load and on every language change; check that widget is mounted (it sits in `App`'s `MaterialApp.builder`) |

## Known open items

1. After popping a detail page, a tap on the bottom navigation is absorbed for about 2-3 s on the simulator (a route transition window, not permanent; not the toast, no infinite animation). The two More-tab integration steps stay skipped until it is measured on a real device.
2. QR scanning and root/jailbreak detection are declined on purpose (D-043, D-041); an app that needs them adds a package or attestation service through a DECISION.
3. Real-device verification is still pending for biometrics (app lock), `FLAG_SECURE` and the iOS cover view, FCM/APNs delivery, Crashlytics delivery, and https link verification (domain and signing). Tests cover the logic behind seams only.

## Documentation index

| File | Content |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | the law: hard rules, definition of done |
| [`ai-docs/README.md`](ai-docs/README.md) | index of the knowledge base |
| [`ai-docs/RULES.md`](ai-docs/RULES.md) | process: commits, heavy commands, decisions, done |
| [`ai-docs/ARCHITECTURE.md`](ai-docs/ARCHITECTURE.md) | target architecture, folder tree, dependency direction, Riverpod patterns, error model, startup |
| [`ai-docs/CONVENTIONS.md`](ai-docs/CONVENTIONS.md) | naming, pages and routes, imports, formatting, strings, RTL-safe layout |
| [`ai-docs/DESIGN_SYSTEM.md`](ai-docs/DESIGN_SYSTEM.md) | tokens, breakpoints, widget catalog, the 8 data states |
| [`ai-docs/NETWORKING.md`](ai-docs/NETWORKING.md) | Dio client, interceptors, errors, repositories, pagination, transfers |
| [`ai-docs/STATE_AND_DATA.md`](ai-docs/STATE_AND_DATA.md) | Riverpod, AsyncValue, cache-first, storage, session lifecycle |
| [`ai-docs/NOTIFICATIONS.md`](ai-docs/NOTIFICATIONS.md) | push and local notifications, Firebase setup, payload contract, troubleshooting |
| [`ai-docs/DEEP_LINKS.md`](ai-docs/DEEP_LINKS.md) | app links and custom scheme, `assetlinks.json`, `apple-app-site-association`, Universal Links opt-in |
| [`ai-docs/FIREBASE.md`](ai-docs/FIREBASE.md) | optional Crashlytics and Analytics, adding Firebase files, consent, vendor switch, test crash |
| [`ai-docs/TESTING.md`](ai-docs/TESTING.md) | what to test, helpers, commands |
| [`ai-docs/DECISIONS.md`](ai-docs/DECISIONS.md) | append-only decision log |
| [`tool/release/README.md`](tool/release/README.md) | release scripts and signing |
| [`.github/workflows/README.md`](.github/workflows/README.md) | CI jobs and action versions |

## Decisions at a glance

Full text and rejected alternatives: `ai-docs/DECISIONS.md`. "Superseded" entries are kept for history.

| ID | One line |
|---|---|
| D-001 | `CLAUDE.md` + `ai-docs/` are the only source of truth; nothing is invented outside them |
| D-002 | Codegen toolchain: riverpod_generator, freezed, json_serializable (the lint part was dropped, see D-017) |
| D-003 | Generated files sit next to their source (no `generated/` redirects) |
| D-004 | Drift for the local DB (superseded by D-034) |
| D-005 | One router, responsive screens instead of per-device routers |
| D-006 | Flavors via `--dart-define-from-file` (superseded by D-024) |
| D-007 | Keep `easy_localization` |
| D-008 | Repositories throw `AppException`; no `ApiResult` wrapper |
| D-009 | Dependency hygiene: no unused or app-specific packages (partly superseded by D-012) |
| D-010 | Singletons become providers |
| D-011 | Safe technical choices are decided and recorded; the owner decides taste, accounts and paid services |
| D-012 | Keep `cloud_firestore`, `firebase_auth`, `google_sign_in` for apps with sign-in |
| D-013 | Latest stable packages, versions recorded from `pubspec.lock` |
| D-014 | Work mode without workers (superseded by D-044) |
| D-015 | No domain layer: page -> provider -> repository -> data source |
| D-016 | Typed routes with `go_router_builder` |
| D-017 | No `riverpod_lint` / `custom_lint` (cannot resolve with the current stack) |
| D-018 | Flavor entrypoints (superseded by D-024) |
| D-019 | `design_system/` replaces `core/widgets` and `core/themes` (location moved by D-026) |
| D-020 | Broad widget library plus a live showcase page |
| D-021 | `cached_network_image` behind `AppImage` |
| D-022 | Android and iOS only |
| D-023 | Per-family string constants in the design system (superseded by D-037) |
| D-024 | dotenv config; automatic dev/prod flavor, staging via `main_staging.dart` |
| D-025 | Component size tokens; `AppOtpField` is the only hard-coded `TextDirection.ltr` |
| D-026 | `design_system` lives inside `core` |
| D-027 | `video_player` behind `AppVideoPlayer`, own controls |
| D-028 | Two generic reference features: `showcase` and `videos` (dev/staging only) |
| D-029 | Sample videos are direct MP4/HLS URLs in one file; YouTube links are out of scope |
| D-030 | Latin digits by default; Arabic-Indic digits are an opt-in flag |
| D-031 | `core/design_system` may import `core/connectivity` and `core/errors`; `copyWithPrevious` is never called |
| D-032 | No silent provider retries; retries only in the Dio interceptor or by explicit user action |
| D-033 | `image_cropper` and `file_picker` behind `MediaService` |
| D-034 | `hive_ce` is the only local store (replaces `shared_preferences` and Drift); secrets stay in secure storage |
| D-035 | Localization is `easy_localization` only; no own locale controller or `lib/l10n/` |
| D-036 | Everything under `core`; no `app/` folder; pages own their `routeName` |
| D-037 | Translations use only generated `LocaleKeys`; a guard test enforces it |
| D-038 | Cache-first for every read feature, with retention and pruning |
| D-039 | Accepted notification deviations (deprecated token calls, channel switch storage, presenter provider, logout hook order) |
| D-040 | Remote config is our own endpoint, not `firebase_remote_config` |
| D-041 | `share_plus`, `in_app_review`, `package_info_plus`, `local_auth`; own screen-security channel; no root/jailbreak check |
| D-042 | Crashlytics + Firebase Analytics, strictly optional; the template runs with zero project data |
| D-043 | No native flavors by default; mobile only; no QR scanner |
| D-044 | Process docs retired; `ai-docs/` keeps only binding docs, new-app steps live in the README |
