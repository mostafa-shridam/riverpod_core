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
- Never delete/weaken a test without recording in the report which behaviour stopped being true (hard rule 6).
- Golden files live in `test/goldens/` next to the test; update only via `flutter test --update-goldens <file>` for tests your task owns, and say so in the report. Goldens use a fixed test font and `pixelRatio` set in the helper.

## Helpers (`test/helpers/`)
- `pumpApp(tester, widget, {overrides, locale, themeMode, textScale, size})` — wraps in `ProviderScope`, localization, theme.
- `createContainer({overrides})` — `ProviderContainer` that is disposed via `addTearDown`.
- `FakeHttpAdapter` — queue of canned responses/errors for Dio.
- `FakeSecureStorage`, `FakePrefsStorage`, `FakeConnectivity`, `FakeCrashReporter`, `FakeAnalytics` (in-memory fakes, subclassing/overriding the concrete core classes or interfaces where one exists).
- Each fake above is added by the task that creates its interface (C-04 creates only `pumpApp`, `createContainer`, `FakeHttpAdapter`).
- Mocks with `mocktail`: register fallback values in `setUpAll`; verify interactions, not implementation details.

## Commands
```
flutter test                       # all
flutter test test/core/error       # one folder
flutter test --coverage            # CI
flutter test integration_test      # needs a device/emulator; not part of the default gate
```
