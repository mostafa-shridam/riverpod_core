# CHECKLIST — Core template checklist

Status: DONE / PARTIAL / MISSING / DECLINED (deliberately not built, with the DECISION). Task = the task (in TASKS.md) that closed it or will close it; `BL` = backlog, task not yet written.
Rewritten for C-29 on 2026-10-17 from the merged code on `main` (a3c6976), replacing the 2026-10-16 baseline audit (cf7e43b). Every DONE row was checked against `lib/`, `test/` or the named report.
Open work at this date: C-41 (READY), C-44 (BLOCKED by C-41), C-21 (READY), C-30 (READY), C-31 (READY), C-46 and C-26 (backlog).

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
| Launcher icons, native splash | MISSING | C-31 | `flutter_launcher_icons` is a dev dependency but its config block is still commented out; no splash |
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
| Stale-while-revalidate cache helper | PARTIAL | C-16 | helper merged (Drift table, explicit ttl); cache-first policy, ETag, hash no-op and pruning (D-038) are C-44; no feature uses the helper yet |
| Cache-first for every read feature, retention/pruning | MISSING | C-44 | BLOCKED by C-41 |
| Settings storage | PARTIAL | C-06, C-41 | works on `shared_preferences`; C-41 moves it to `hive_ce` (D-034) |
| Secrets storage (tokens) | DONE | C-06 | `flutter_secure_storage` |
| One local store | PARTIAL | C-06, C-41 | Drift today; D-034 replaces it with `hive_ce` in C-41 |
| Provider retry policy | DONE | C-40 | no silent retries (D-032) |

## Auth & security
| Item | Status | Task | Note |
|---|---|---|---|
| splash -> onboarding -> auth -> home with route guards | DONE | C-11, C-17, C-18 | pure `appRedirect`, startup sequence |
| Login, register, forgot-password pages | DONE | C-17 | mock source switch `authUseMockSource` |
| Logout clears tokens, cache, providers | DONE | C-17 | one function; session epoch invalidates user-scoped providers; notification hook runs first |
| Biometric lock, screenshot blocking | DONE | C-19 | `local_auth` + own `FLAG_SECURE` / iOS cover channel (D-041) |
| Root/jailbreak check | DECLINED | D-041 | unreliable client-side; apps needing it add a vetted attestation through a DECISION |
| Social sign-in | MISSING | BL | extension point only (C-17 report); `google_sign_in`/`firebase_auth` are dependencies but unused |

## Navigation
| Item | Status | Task | Note |
|---|---|---|---|
| GoRouter with typed routes | DONE | C-11 | one router, `routes.dart`, pages own `routeName` (D-036) |
| Nested navigation (bottom nav, separate stacks) | DONE | C-11 | stateful shell: Home, More |
| Notification-tap routing | DONE | C-20 | `NotificationRouter`, queued until sign-in |
| Deep-link mapping (type + id -> typed route) | DONE | C-11, C-20 | `routeForDeepLink` |
| Deep links / universal links, native setup | MISSING | C-31 | no intent filter / associated domains yet |

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
| Rationale dialog wired in bootstrap | MISSING | C-46 | `permissionRationalePresenterProvider` defaults to null (backlog; after C-41, same file) |

## Production
| Item | Status | Task | Note |
|---|---|---|---|
| Global error handlers + crash reporting behind an interface | PARTIAL | C-08, C-30 | interface, no-op and console implementations, handlers DONE; Crashlytics implementation is C-30 (D-042) |
| Analytics behind an interface | PARTIAL | C-08, C-30 | interface + no-op/console DONE; Firebase Analytics is C-30 |
| Force update + maintenance mode + feature flags | MISSING | C-21 | own endpoint (D-040) |
| Leveled logger, silent in prod, masks secrets | DONE | C-08 | |
| Share, external links, in-app review, version/About page | DONE | C-22 | D-041 |

## Media & device
| Item | Status | Task | Note |
|---|---|---|---|
| Image picker + crop + compression | DONE | C-23 | `MediaService` |
| File picker | DONE | C-23 | |
| Permission handling with rationale / open settings | DONE | C-23, C-45 | shared rationale dialog needs C-46 wiring in the app |
| Device info | DONE | C-20 | `deviceInfoProvider` |
| QR scanner | DECLINED | D-043 | optional and app-specific; add through a DECISION |

## Quality
| Item | Status | Task | Note |
|---|---|---|---|
| Unit tests | DONE | every task | about 100 test files mirroring `lib/` |
| Widget tests, golden tests | DONE | C-09..C-39 | about 190 baselines, light/dark x ar/en |
| mocktail + ProviderContainer helpers, fakes | DONE | C-04 and later | `test/helpers/` |
| Guard tests (translations) | DONE | C-04, C-42 | parity, no literal keys |
| Integration test (auth flow + one feature flow) | MISSING | C-26 | no `integration_test/` folder yet |
| GitHub Actions CI | DONE | C-27 | gate, coverage artifact, debug Android and iOS builds |
| Release scripts with untracked signing | DONE | C-28, C-43 | release without `key.properties` is refused |

## Docs
| Item | Status | Task | Note |
|---|---|---|---|
| README | DONE | C-29 | rewritten; its `Status:` notes are removed by the Lead as C-41/C-44/C-46/C-21/C-30/C-31/C-26 become DONE |
| HOW_TO_START_A_NEW_APP.md | DONE | C-29 | steps that depend on C-30/C-31 are marked pending |
| ai-docs + CLAUDE.md control plane | DONE | — | |
| Skill recipes (`.claude/skills`) | DONE | C-29 | `release-check` updated to the dotenv flavor setup (D-024) |
