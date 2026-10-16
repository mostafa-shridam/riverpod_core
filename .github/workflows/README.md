# CI workflows

`ci.yml` runs on every push and pull request. It needs no secrets.

## Jobs
1. `test` (ubuntu): pub get, create `env/*.env` from the committed `env/*.env.example`, generate translations
   (same two commands as `build.sh`), `build_runner`, `dart format lib/generated` + `git diff --exit-code` (fails when tracked generated code is stale; the format step is needed because the l10n generators emit unformatted Dart),
   `dart format --set-exit-if-changed lib test tool`, `flutter analyze`, `flutter test --coverage`,
   uploads `coverage/lcov.info` as artifact `coverage-lcov`.
2. `build-android` (ubuntu, `needs: test`): `flutter build apk --debug` (JDK 17).
3. `build-ios` (macos, `needs: test`): `flutter build ios --no-codesign --debug`.

Superseded runs of the same ref are cancelled (`concurrency`). Token permissions: `contents: read`.

## Flutter version
Stable channel, pinned to `FLUTTER_VERSION` (top of `ci.yml`, currently 3.47.0, the version used locally),
cached by `subosito/flutter-action` (`cache: true`). Bump it deliberately when the template upgrades Flutter.

## Action versions (major tags; verified 2026-10-16 on each repo's GitHub "latest release" page)
| Action | Used | Latest seen | Verified at |
|---|---|---|---|
| actions/checkout | v7 | v7.0.1 | https://github.com/actions/checkout/releases/latest |
| subosito/flutter-action | v2 | v2.23.0 | https://github.com/subosito/flutter-action/releases/latest |
| actions/upload-artifact | v7 | v7.0.2 | https://github.com/actions/upload-artifact/releases/latest |
| actions/setup-java | v6 | v6.1.0 | https://github.com/actions/setup-java/releases/latest |

`actions/cache` is not used: `flutter-action` caches the SDK and pub cache itself.
Pinned to major tags (not commit SHAs); to pin to a SHA, resolve the tag with `git ls-remote https://github.com/<owner>/<repo> <tag>`.

## Secrets
None are required. If a future job needs one: repo Settings > Secrets and variables > Actions > New repository secret,
then reference it as `${{ secrets.NAME }}` in the single step that needs it. Never write a value in a workflow file.
Env files in CI come from the `*.env.example` files (bundled values are never real secrets, D-024).
