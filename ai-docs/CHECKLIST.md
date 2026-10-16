# CHECKLIST — Core template checklist

Status: MISSING / PARTIAL / DONE. Task = the task (in TASKS.md) that closes it; `BL` = backlog, task not yet written.
Audit date: 2026-10-16 (baseline commit cf7e43b). `flutter analyze`: 0 issues. `test/`: does not exist.

## Foundation
| Item | Status | Task | Audit note |
|---|---|---|---|
| Feature-first structure (data/providers/presentation) | PARTIAL | C-11, BL | only `features/home/presentation`; `core/` has per-device routers |
| Riverpod with codegen | DONE | C-01 | riverpod_generator added, build_runner works |
| freezed + json_serializable | DONE | C-01 | added |
| Flavors dev/staging/prod (`--dart-define-from-file`) + startup validation | MISSING | C-02 | none; package id `com.example.riverpod_core` |
| Strict analysis_options | DONE | C-01 | strict-* + 10 extra lints, 0 issues |
| Feature scaffolding from `.fttemplates` | MISSING | BL | templates removed in cf7e43b (files were empty except one) |
| App rename script, launcher icons, native splash | PARTIAL | BL | `rename_app` + `flutter_launcher_icons` present but configs commented out; no splash |
| Platform folders | PARTIAL | BL | only `android/`; ios/web/macos/windows/linux absent |

## Networking
| Item | Status | Task | Audit note |
|---|---|---|---|
| Single Dio client (config base URL, timeouts) | PARTIAL | C-07 | `DioClient` exists, URL passed by caller, nothing wires it as a provider |
| Dev-only logging that never prints tokens | MISSING | C-07 | current logger prints headers (tokens leak in debug) |
| Auth header interceptor | MISSING | C-07 | |
| Refresh token + request queue | MISSING | C-07 | |
| Retry with backoff | MISSING | C-07 | comment only |
| Idempotency key for writes | MISSING | C-07 | |
| Unified AppException + localized messages | PARTIAL | C-03, C-07 | 5 exception classes, English hard-coded strings, no validation/forbidden/not-found |
| Pagination helpers (cursor + offset) + infinite scroll | MISSING | BL | |
| Upload/download with progress + cancel | MISSING | BL | |
| Connectivity watcher + offline banner | PARTIAL | C-10 | `NetworkService` exists (singleton, DNS lookup of google.com); no banner |

## State & data
| Item | Status | Task | Audit note |
|---|---|---|---|
| Shared widgets for the 8 data states | MISSING | C-10 | |
| AsyncValue patterns | MISSING | C-10 | |
| Stale-while-revalidate cache | MISSING | BL | |
| shared_preferences (settings) | MISSING | C-06 | transitive only |
| flutter_secure_storage (tokens) | MISSING | C-06 | |
| One local DB | PARTIAL | C-06 | Hive key-value only; D-004 picks Drift |

## Auth & security
| Item | Status | Task | Audit note |
|---|---|---|---|
| splash → onboarding → auth → home with route guards | MISSING | BL | router has `routes: []` |
| Logout clears tokens, cache, providers | MISSING | BL | |
| Biometric lock, screenshot blocking, root/jailbreak check | MISSING | BL | |

## Navigation
| Item | Status | Task | Audit note |
|---|---|---|---|
| GoRouter with typed routes | PARTIAL | C-11 | GoRouter present, empty; two parallel routers |
| Deep links / universal links | PARTIAL | BL | `deep_link_helper.dart` exists, untested, depends on singleton router |
| Notification-tap routing | PARTIAL | BL | handlers exist in `remote_notifications_service.dart` |
| Nested navigation (bottom nav, separate stacks) | MISSING | C-11 | |

## UI
| Item | Status | Task | Audit note |
|---|---|---|---|
| Design tokens, Material 3, light/dark/system | PARTIAL | C-05 | M3 on, but colors are app-specific (black/green), sizes hard-coded, no tokens |
| Shared button/field/card/dialog/sheet/snackbar | PARTIAL | C-09 | `app_button`, `custom_button` (two buttons!), `my_text_filed`, `alert_utils` (421 lines) |
| Skeleton loaders, cached image, avatar, badge, chips, empty/error states | MISSING | C-10, BL | `skeletonizer` dependency only |
| Responsive breakpoints | PARTIAL | C-05 | `responsive_framework` with a fixed 450 scaled box |
| RTL-correct layouts | PARTIAL | C-09 | needs audit of left/right usage |
| Text scaling | BROKEN | C-05 | `main.dart` forces `TextScaler.linear(1)` |

## Localization
| Item | Status | Task | Audit note |
|---|---|---|---|
| ar + en | PARTIAL | C-03, C-12 | 11 keys |
| Runtime switch without restart | PARTIAL | C-12 | helper exists, unverified |
| Plurals, locale-aware numbers/dates | MISSING | C-12 | |
| Key-parity test | MISSING | C-04 | |

## Notifications
| Item | Status | Task | Audit note |
|---|---|---|---|
| FCM permission/token/foreground/background/terminated/tap | PARTIAL | BL | service exists; `Firebase.initializeApp` is never called; no token → server |
| Local notifications + scheduling | PARTIAL | BL | exact alarms done in last commit; singleton, untested |

## Production
| Item | Status | Task | Audit note |
|---|---|---|---|
| Crash reporting behind interface + global error handlers | MISSING | C-08 | handlers only `log()` |
| Analytics behind interface | MISSING | C-08 | |
| Force update + maintenance mode (remote config) | MISSING | BL | |
| In-app review, share, external links, version screen | PARTIAL | BL | `url_launcher` mixin, `info_service` |
| Leveled logger silent in prod | MISSING | C-08 | `dart:developer log` everywhere |

## Media & device
| Item | Status | Task | Audit note |
|---|---|---|---|
| Image picker + crop + compression | PARTIAL | BL | picker + `flutter_image_compress` mixin, no crop |
| File picker | MISSING | BL | |
| Permission handling with rationale/open settings | PARTIAL | BL | `permission_handler` present |
| QR scanner (optional) | MISSING | BL | |

## Quality
| Item | Status | Task | Audit note |
|---|---|---|---|
| Unit tests | MISSING | C-03, C-04, … | no `test/` |
| Widget tests, golden tests | MISSING | C-09, C-10 | |
| Integration test (auth flow) | MISSING | BL | |
| mocktail + ProviderContainer helpers | MISSING | C-04 | |
| GitHub Actions CI | MISSING | BL | |
| Release scripts with untracked signing | MISSING | BL | Android release signs with debug keys |

## Docs
| Item | Status | Task | Audit note |
|---|---|---|---|
| README | MISSING | BL | default Flutter text |
| HOW_TO_START_A_NEW_APP.md | PARTIAL | BL | skeleton written, steps depend on rename/flavors tasks |
| ai-docs + CLAUDE.md control plane | DONE | — | created 2026-10-16 (Phase 1) |
