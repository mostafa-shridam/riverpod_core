# TESTING

`test/` mirrors `lib/`. Packages: `flutter_test`, `mocktail`, `integration_test` (sdk). Anything else = DECISION.

## What must be tested
| Code | Test type | Minimum |
|---|---|---|
| Repositories | unit | success, each mapped `AppException`, JSON→model mapping |
| Notifiers/controllers | unit with `ProviderContainer` | initial state, success, failure, refresh keeps previous data |
| Interceptors / refresh queue / retry | unit | single-flight refresh, queue replay, no retry on 4xx, backoff count |
| Error mapper | unit | every row in the NETWORKING.md table |
| Config/flavors | unit | missing/invalid define → clear error |
| Shared widgets (`core/widgets`) | widget | each variant, disabled, loading, RTL, text scale 2.0 |
| Pages | widget + golden | the 8 data states where applicable; light/dark × ar/en; phone + tablet |
| Translations | unit | key parity ar/en; no empty values; placeholders match |
| Auth flow | integration (1 test) | splash → onboarding → login → home → logout |

## Rules
- A bug fix starts with a failing test.
- Tests are deterministic: no real network, no real clock (inject `Clock`/use `fakeAsync`), no sleeping.
- Never delete/weaken a test without recording (commit message or PR text) which behaviour stopped being true (hard rule 6).
- Golden files live in `test/goldens/` next to the test; update only via `flutter test --update-goldens <file>` for tests your change owns, and say so in the commit message. Goldens use a fixed test font and `pixelRatio` set in the helper.

## Helpers (`test/helpers/`)
- `pumpApp(tester, widget, {overrides, locale, themeMode, textScale, size})` — wraps in `ProviderScope`, localization, theme.
- `createContainer({overrides})` — `ProviderContainer` that is disposed via `addTearDown`.
- `FakeHttpAdapter` — queue of canned responses/errors for Dio.
- `FakeSecureStorage`, `FakePrefsStorage`, `FakeConnectivity`, `FakeCrashReporter`, `FakeAnalytics` (in-memory fakes, subclassing/overriding the concrete core classes or interfaces where one exists).
- Each fake is added together with the interface it fakes.
- Mocks with `mocktail`: register fallback values in `setUpAll`; verify interactions, not implementation details.

## Commands
```
flutter test                       # all
flutter test test/core/error       # one folder
flutter test --coverage            # CI
flutter test integration_test      # needs a device/emulator; not part of the default gate
```

## Integration tests
- Location: `integration_test/`. `app_flow_test.dart` drives the real app through `bootstrap` on a device: onboarding, sign-in (wrong and right credentials), videos, favorite, About, logout.
- Seams, not mocks of the app: `helpers/flow_setup.dart` gives the mock remote config, a fake video player (`videoBackendFactoryProvider`), in-memory secure storage, fresh settings and cache on each run, and an env with no real values and no network.
- No real timers are needed in the test code. The app's own mock auth delay (400 ms) and splash minimum (800 ms) are the only waits; `pumpUntilFound` polls for the screen, it never uses `pumpAndSettle` (spinners never settle).
- `screens_test.dart` walks the screens for the owner's screenshots. Screenshots are written only under `flutter drive` with `--dart-define=CAPTURE_SCREENS=true` and `SCREENS_DIR` set (driver: `integration_test/screens_driver.dart`).
- Run on a simulator: `flutter test integration_test/app_flow_test.dart -d <udid>` (boot one with `xcrun simctl boot <udid>`).
- Clean-clone smoke: `tool/smoke.sh [udid]` copies `HEAD` into a temp dir, uses only `env/*.env.example`, refuses Firebase or keystore files, and runs pub get, codegen, format, analyze, `flutter test`, the Android and iOS debug builds, and the flow test. It exits non-zero on the first failure and never touches the working tree. It tests committed code only, so commit first.
- CI: the `integration-ios` job runs on `workflow_dispatch` and nightly. It is not in the required PR checks.
