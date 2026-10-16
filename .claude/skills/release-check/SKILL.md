---
name: release-check
description: Pre-release gate for an app built from this template: quality gate, config, secrets, signing, version, store readiness.
---

# release-check

Run on a clean checkout of the release commit. Report each line PASS/FAIL; any FAIL blocks the release.

1. Gate (CLAUDE.md): pub get · build_runner · `dart format --set-exit-if-changed lib test` · `flutter analyze` (0) · `flutter test` (all green) · goldens unchanged.
2. Integration test (auth flow) passes on an emulator/device.
3. Config: `env/prod.json` exists locally, `apiBaseUrl` is https, crash reporting and analytics enabled, log level is silent/error-only. Build with `--dart-define-from-file=env/prod.json`.
4. Secrets: `git ls-files | grep -E "google-services.json$|GoogleService-Info.plist$|\.jks$|\.keystore$|\.env$|key\.properties$"` returns nothing; no tokens in logs (grep for `Authorization` in log code).
5. Signing: Android release uses `key.properties` (untracked), never the debug key; iOS uses the team's distribution profile.
6. Version: `pubspec.yaml` `version:` bumped (name+build); version screen shows it; changelog updated.
7. Native: app id/bundle id is the app's own (not `com.example.*`), launcher icon and splash are the app's, permissions in manifests match what the code actually uses, iOS usage descriptions present.
8. Checklist: `ai-docs/CHECKLIST.md` has no MISSING item the app depends on; deep links/notification routing verified by hand on a real device.
9. Build artifacts: `flutter build appbundle --release --dart-define-from-file=env/prod.json` and `flutter build ipa …` succeed; size reasonable; obfuscation flags (`--obfuscate --split-debug-info=…`) used and symbols archived.
10. Smoke on the release build: cold start, login, logout, offline banner, language switch ar↔en, dark mode, text scale 1.5×.
