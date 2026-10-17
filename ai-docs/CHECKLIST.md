# CHECKLIST — Core template checklist

Status: DONE / PARTIAL / MISSING / DECLINED (deliberately not built, with the DECISION). Task = the task (in TASKS.md) that closed it or will close it; `BL` = backlog, task not yet written.
Final refresh for C-29 on 2026-10-17: every task of the template is merged (C-41, C-44, C-46, C-21, C-30, C-31, C-26, C-47, C-48 included). Every DONE row was checked against `lib/`, `test/`, `integration_test/` or the named report.
Open items (not tasks): see "Known open items" at the end of this file.

## Foundation
| Item | Status | Task | Note |
|---|---|---|---|
| Feature-first structure (data/providers/presentation) | DONE | C-11, C-17, C-18, C-39 | features: auth, home, items, more, onboarding, showcase, videos |
| Riverpod with codegen | DONE | C-01 | `@riverpod` only; `riverpod_lint` not used (D-017) |
| freezed + json_serializable | DONE | C-01 | |
| Flavors dev/staging/prod + startup validation | DONE | C-02, C-08, C-37 | dotenv (D-024): debug=dev, release=prod, staging via `main_staging.dart`; `ConfigErrorApp` lists every problem |
| Strict analysis_options | DONE | C-01 | strict-* plus extra lints |
| Feature scaffolding from `.fttemplates` | DONE | C-25 | `tool/new_feature.dart`, 20 tests |
| App rename script | DONE | C-13 | `tool/rename_app.dart` (name, id, Dart package) |
| Launcher icons, native splash | DONE | C-31 | generic placeholders on the brand seed (`tool/generate_placeholder_icon.dart`); `flutter_launcher_icons` and `flutter_native_splash` configured in `pubspec.yaml`, generated files committed |
| Platform folders | DONE | C-43 | android + ios only (D-022); both build (see C-43 report) |
| Native build health (Gradle, Kotlin, compileSdk, pods) | DONE | C-43 | Gradle 8.14.3, AGP 8.11.1, Kotlin 2.4.0, compileSdk 37, iOS 15.0; AGP 9 upgrade is a future task |
| Legacy code removed | DONE | C-36 | |

## Networking
| Item | Status | Task | Note |
|---|---|---|---|
| Single Dio client (config base URL, timeouts) | DONE | C-07 | `dioProvider`, `refreshDioProvider` |
| Dev-only logging that never prints secrets | DONE | C-07 | logging interceptor only at `LOG_LEVEL=debug`, allow-list redaction |
| Auth header interceptor | DONE | C-07 | `extra['skipAuth']` opt-out |
| Refresh token + request queue | DONE | C-07, C-17 | single-flight; `SessionController` is the refresher |
| Retry with backoff | DONE | C-07 | idempotent calls only, max 3 attempts |
| Idempotency key for writes | DONE | C-07 | |
| Unified AppException + localized messages | DONE | C-03, C-07 | one mapper, `errors.*` keys |
| Pagination helpers (cursor + offset) + infinite scroll | DONE | C-14 | `PaginatedNotifier`, `PaginatedListView` |
| Upload/download with progress + cancel | DONE | C-15 | `.part` file cleanup on cancel/failure |
| Connectivity watcher + offline banner | DONE | C-10 | plugin events only, no DNS probe |

## State & data
| Item | Status | Task | Note |
|---|---|---|---|
| Shared widgets for the 8 data states | DONE | C-10 | `AsyncValueView`, `EmptyState`, `ErrorState`, `Skeleton`, `OfflineBanner` |
| AsyncValue patterns | DONE | C-10, C-40 | previous data kept on reload (STATE_AND_DATA.md) |
| Stale-while-revalidate cache helper | DONE | C-16, C-44 | `CachedRepositoryHelper.load`/`watch`; used by videos, remote config and the feature scaffold |
| Cache-first for every read feature, retention/pruning | DONE | C-44 | presets, ETag, payload no-op, `CachePruner` + scheduler (D-038) |
| Settings storage | DONE | C-06, C-41 | `hive_ce` settings box behind `PrefsStorage` (D-034) |
| Secrets storage (tokens) | DONE | C-06 | `flutter_secure_storage` |
| One local store | DONE | C-41 | `hive_ce` only; `shared_preferences` and Drift removed from `pubspec.yaml` |
| Provider retry policy | DONE | C-40 | no silent retries (D-032) |

## Auth & security
| Item | Status | Task | Note |
|---|---|---|---|
| splash -> onboarding -> auth -> home with route guards | DONE | C-11, C-17, C-18 | pure `appRedirect`, startup sequence |
| Login, register, forgot-password pages | DONE | C-17 | mock source switch `authUseMockSource` |
| Logout clears tokens, cache, providers | DONE | C-17 | one function; session epoch invalidates user-scoped providers; notification hook runs first |
| Biometric lock, screenshot blocking | DONE | C-19 | `local_auth` + own `FLAG_SECURE` / iOS cover channel (D-041) |
| Root/jailbreak check | DECLINED | D-041 | unreliable client-side; apps needing it add a vetted attestation through a DECISION |
| Social sign-in | DECLINED | D-012 | app-specific: extension point only (C-17 report); the packages are kept for the app's own login |

## Navigation
| Item | Status | Task | Note |
|---|---|---|---|
| GoRouter with typed routes | DONE | C-11 | one router, `routes.dart`, pages own `routeName` (D-036) |
| Nested navigation (bottom nav, separate stacks) | DONE | C-11 | stateful shell: Home, More |
| Notification-tap routing | DONE | C-20, C-47 | `NotificationRouter`, queued until sign-in |
| Deep-link mapping (type + id -> typed route) | DONE | C-11, C-20 | `routeForDeepLink` |
| Deep links / universal links, native setup | DONE | C-31 | https App Link filter + custom scheme `riverpod-core`; iOS Universal Links are opt-in (needs a paid Apple team), see `ai-docs/DEEP_LINKS.md`; real-device verification pending |

## UI
| Item | Status | Task | Note |
|---|---|---|---|
| Design tokens, Material 3, light/dark/system | DONE | C-05 | one brand file (`brand_config.dart`) |
| Buttons and text inputs | DONE | C-09 | |
| Selection and form controls | DONE | C-32 | |
| Bottom sheets, dialogs, snackbar/toast/banner/progress/tooltip | DONE | C-33 | |
| Display and layout widgets (card, tile, avatar, badge, chip, image, accordion, scaffold, tabs, stepper) | DONE | C-34 | |
| Skeleton loaders, empty/error states | DONE | C-10 | |
| Component gallery | DONE | C-35 | `/showcase`, dev/staging only |
| Video player widget | DONE | C-38 | `AppVideoPlayer` |
| Responsive breakpoints | DONE | C-05 | phone / tablet / desktop, max content width 720 |
| RTL-correct layouts | DONE | C-09..C-35 | directional APIs only; ar goldens |
| Text scaling | DONE | C-05 | system scale honored, clamped 0.8x-2.0x |

## Localization
| Item | Status | Task | Note |
|---|---|---|---|
| ar + en | DONE | C-03, C-12 | |
| Runtime switch without restart | DONE | C-12, C-40 | `easy_localization` only (D-035) |
| Plurals, locale-aware numbers/dates | DONE | C-12 | `core/utils/formatting`; Latin digits default (D-030) |
| Key-parity test | DONE | C-04 | |
| LocaleKeys only + guard test | DONE | C-42 | D-037 |

## Notifications
| Item | Status | Task | Note |
|---|---|---|---|
| FCM permission/token/foreground/background/terminated/tap | DONE | C-20 | optional Firebase: push off with one log line |
| Local notifications + scheduling | DONE | C-20 | exact when allowed, inexact fallback |
| Permission flow through the shared PermissionService | DONE | C-45 | |
| Token registration to the app backend | DONE | C-20 | `PushTokenRegistrar` (no-op default, Dio example disabled) |
| Rationale dialog wired in bootstrap | DONE | C-46 | `permissionRationalePresenterProvider` overridden with `showPermissionRationale` in bootstrap |

## Production
| Item | Status | Task | Note |
|---|---|---|---|
| Global error handlers + crash reporting behind an interface | DONE | C-08, C-30 | Crashlytics implementation optional: used only with the flag on AND Firebase files present, else no-op (D-042); consent switch |
| Analytics behind an interface | DONE | C-08, C-30 | Firebase Analytics implementation, same optional rule; route observer |
| Force update + maintenance mode + feature flags | DONE | C-21 | own endpoint (D-040), gate pages, soft-update banner, `flagProvider` |
| Leveled logger, silent in prod, masks secrets | DONE | C-08 | |
| Share, external links, in-app review, version/About page | DONE | C-22 | D-041 |

## Media & device
| Item | Status | Task | Note |
|---|---|---|---|
| Image picker + crop + compression | DONE | C-23 | `MediaService` |
| File picker | DONE | C-23 | |
| Permission handling with rationale / open settings | DONE | C-23, C-45, C-46 | shared rationale dialog wired in bootstrap |
| Device info | DONE | C-20 | `deviceInfoProvider` |
| QR scanner | DECLINED | D-043 | optional and app-specific; add through a DECISION |

## Quality
| Item | Status | Task | Note |
|---|---|---|---|
| Unit tests | DONE | every task | about 100 test files mirroring `lib/` |
| Widget tests, golden tests | DONE | C-09..C-39 | about 190 baselines, light/dark x ar/en |
| mocktail + ProviderContainer helpers, fakes | DONE | C-04 and later | `test/helpers/` |
| Guard tests (translations) | DONE | C-04, C-42 | parity, no literal keys |
| Integration test (real app flow) + clean-clone smoke script | DONE | C-26, C-48 | `integration_test/app_flow_test.dart`, `tool/smoke.sh`; the More -> About -> logout test is skipped (known open item) |
| GitHub Actions CI | DONE | C-27 | gate, coverage artifact, debug Android and iOS builds |
| Release scripts with untracked signing | DONE | C-28, C-43 | release without `key.properties` is refused |

## Docs
| Item | Status | Task | Note |
|---|---|---|---|
| README | DONE | C-29 | final |
| HOW_TO_START_A_NEW_APP.md | DONE | C-29 | |
| ai-docs + CLAUDE.md control plane | DONE | — | |
| Skill recipes (`.claude/skills`) | DONE | C-29 | `release-check` updated to the dotenv flavor setup (D-024) |

## Known open items
| Item | Note |
|---|---|
| Bottom-nav tap absorbed ~2-3 s after popping a detail page (simulator) | route transition window, not permanent (C-26 report); the More -> About -> logout integration steps stay skipped until measured on a real device |
| QR scanner, root/jailbreak detection | DECLINED (D-043, D-041) |
| Real-device verification | pending for biometrics, `FLAG_SECURE` and the iOS cover view, FCM/APNs delivery, Crashlytics delivery, https link verification |
| Social sign-in | extension point only; `google_sign_in`, `firebase_auth`, `cloud_firestore` are kept on purpose for each app's login/data and are not imported by template code (D-012) |
