# ARCHITECTURE (target state — binding)

Style: feature-first, pragmatic layering, Riverpod (codegen) for DI + state.
**No domain layer**: no entities, no use cases, no abstract repository interfaces (D-015).
Flow: `page → provider → repository → data source`. A feature never imports another feature's internals.
Shared things live in `core/`, `core/design_system/` or `shared/`. Current code differs in places; CHECKLIST.md/TASKS.md name the task that closes each gap.

## Folder tree
```
lib/
├── main.dart / main_staging.dart   # thin: bootstrap(Flavor.current) / bootstrap(Flavor.staging) (D-024)
├── bootstrap.dart              # zones, error handlers, config load+validate, ProviderScope, runApp
├── app/
│   ├── app.dart                # MaterialApp.router: theme, locale, router, builders
│   ├── router/
│   │   ├── app_router.dart     # GoRouter provider; redirect = guards
│   │   ├── routes.dart         # typed routes (go_router_builder): all paths in one place
│   │   └── guards/             # auth, onboarding, maintenance/force-update
│   └── startup/                # splash + startup sequence (config, session restore, remote flags)
├── core/                       # app-agnostic infrastructure + the design system (UI primitives live ONLY in core/design_system)
│   ├── config/                 # AppConfig (from env/<flavor>.env via flutter_dotenv), Flavor.current (kReleaseMode ? prod : dev), validation
│   ├── network/
│   │   ├── dio_client.dart     # one Dio provider
│   │   ├── interceptors/       # auth, refresh_token (queued), retry_backoff, idempotency, logging (dev)
│   │   ├── pagination/         # Page<T>, cursor + offset helpers, paginated notifier base
│   │   └── transfer/           # upload/download with progress + cancel
│   ├── errors/
│   │   ├── app_exception.dart  # sealed: Network, Timeout, Unauthorized, Forbidden, NotFound,
│   │   │                       #   Validation(fieldErrors), Server, Cancelled, Unknown
│   │   ├── error_mapper.dart   # DioException/platform errors → AppException (one place only)
│   │   └── error_messages.dart # AppException → localized message key
│   ├── storage/
│   │   ├── secure_storage.dart # tokens only
│   │   ├── prefs_storage.dart  # settings only
│   │   └── database/           # the one local DB (Drift, D-004)
│   ├── auth/                   # session state, token store, logout-clears-everything
│   ├── connectivity/           # online/offline stream provider
│   ├── notifications/          # FCM + local notifications; tap → route
│   ├── analytics/              # AnalyticsService interface + no-op + impl
│   ├── crash/                  # CrashReporter interface + impl
│   ├── remote_config/          # force update, maintenance, feature flags
│   ├── logger/                 # leveled, silent in prod, never logs secrets
│   ├── permissions/            # request + rationale + open settings
│   ├── media/                  # image/file picking, crop, compress
│   ├── design_system/              # the ONLY place UI primitives are implemented (D-026)
│   │   ├── tokens/                 # colors, typography, spacing, radius, elevation, durations
│   │   ├── theme/                  # light/dark ThemeData from tokens, ThemeExtensions
│   │   ├── responsive/             # breakpoints, ResponsiveLayout, adaptive padding
│   │   └── widgets/                # AppButton, AppTextField, AppCard, AppDialog, AppBottomSheet,
│   │                               # AppSnackbar, AppImage, AppAvatar, AppBadge, AppChip, Skeleton,
│   │                               # EmptyState, ErrorState, OfflineBanner,
│   │                               # AsyncValueView (renders the 8 data states)
│   └── utils/                  # pure helpers (dates, formatters, validators, debouncer)
├── l10n/                       # locale controller + formatters (JSON lives in assets/translations)
├── shared/                     # cross-feature models (e.g. User) and shared DTOs
└── features/
    └── <feature>/              # scaffolded by .fttemplates/feature
        ├── data/
        │   ├── models/         # freezed + json_serializable; used directly by the app
        │   ├── sources/        # remote (Dio) + local (DB/prefs) data sources
        │   └── <feature>_repository.dart   # concrete class + its @riverpod provider
        ├── providers/          # Riverpod notifiers/providers (state + actions), no widgets
        └── presentation/
            ├── pages/          # one page per route; composes widgets; handles the 8 states
            └── widgets/        # feature-only widgets built from design_system primitives
assets/translations/{ar,en}.json   assets/images/   assets/fonts/
test/              mirrors lib/ exactly (+ test/helpers: pumpApp, ProviderContainer factory, fakes)
integration_test/  auth flow + one feature flow
tool/              scripts: rename_app, new_feature, check_l10n_keys, release builds
env/               *.env.example (real *.env files git-ignored)
.fttemplates/      feature scaffold
```

## Dependency direction
- `features/x/presentation` → `features/x/providers` → `features/x/data` → `core/`, `shared/`.
- `core/design_system/` imports only Flutter, `core/utils`, `core/errors`, `core/connectivity` and `l10n/` (D-031). It never imports `features/`, `app/` or providers of a feature.
- `core/` never imports `features/` or `app/`. Non-UI core folders (network, storage, errors…) never import `core/design_system/`.
- A feature never imports another feature's `data/`, `providers/` or `presentation/`. Shared need → `core/`, `shared/` or `core/design_system/`.
- `app/` may import everything.

## Architecture rules
- Providers: riverpod_generator only (`@riverpod`). Repositories/services = keepAlive providers; page state = autoDispose notifiers. No global singletons, no service locators, no `setState` for business logic. Override providers in tests; never mock statics.
- A repository returns models or throws `AppException`, never `DioException` or raw JSON. Pages and providers never call Dio or a data source directly, only the repository.
- Business logic lives in the feature's providers (notifiers). Logic shared by two features goes to a repository method or a `core/` service, never to a "use case" class.
- Errors are mapped ONCE (`core/errors/error_mapper.dart`). The UI never inspects HTTP codes.
- Every async page uses `AsyncValueView` (loading/empty/error/offline/stale/partial/refreshing/success).
- Features use `core/design_system` widgets only, never raw `ElevatedButton`/`TextField`.
- No hard-coded user text, colors, sizes or durations in features: l10n keys + tokens only.
- Directional (RTL-safe) APIs only: `EdgeInsetsDirectional`, `AlignmentDirectional`, start/end.
- Navigation only through typed routes; deep links and notification taps resolve to the same routes.
- Config only through `AppConfig`; no `dotenv`/`String.fromEnvironment` outside `core/config`. Debug builds use `Flavor.dev`, release builds `Flavor.prod`, staging only via `main_staging.dart`.
- Logout = one function that clears tokens, DB, caches, analytics user and invalidates providers.
- A new folder or a layer exception requires a DECISION. A file that does not fit the tree is in the wrong place.

## Riverpod patterns
Allowed: `@riverpod` functions and classes (Notifier/AsyncNotifier/StreamNotifier); `ref.watch` in `build`, `ref.read` only in callbacks, `ref.listen` for side effects;
auto-dispose by default, `@Riverpod(keepAlive: true)` for repositories/services/session/config/DB; family parameters for per-id state; `ProviderContainer(overrides)` in tests.
Forbidden: hand-written legacy providers (`Provider`, `StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider`); `ref.read` in `build`; `BuildContext`/`Navigator`/`ScaffoldMessenger` in providers or repositories;
`X.instance` singletons holding state; creating providers inside functions/widgets; Dio/DB calls from widgets or notifiers.

## Error model
Sealed `AppException` (`core/errors/app_exception.dart`): `NetworkException`, `RequestTimeoutException`, `UnauthorizedException`, `ForbiddenException`, `NotFoundException`,
`ValidationException(fieldErrors)`, `ServerException(statusCode)`, `CancelledException`, `UnknownException`. Notifiers expose `AsyncValue`; the error is always an `AppException`.
UI text comes from `error_messages.dart` (key → `.tr()`), never `e.toString()`. Unexpected exceptions go to `CrashReporter` and surface as `UnknownException`.

## Startup (bootstrap)
`main.dart` / `main_staging.dart` → `bootstrap(flavor)`: ensureInitialized → load `env/<flavor>.env` + validate `AppConfig` (clear error screen on failure) → global error handlers (logger + crash) →
storage/localization → `runApp(ProviderScope(...App()))`. Optional services (analytics, notifications) must not block startup; config failure must.
