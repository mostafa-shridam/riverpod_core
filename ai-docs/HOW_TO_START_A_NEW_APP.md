# HOW TO START A NEW APP FROM THIS TEMPLATE

Status: complete for everything merged on 2026-10-17 (C-29). Steps or notes marked **(pending C-xx)** depend on a task that is not DONE yet;
the Lead removes the marker when the task is DONE. The overview is in the root `README.md`.

The template holds no project data (D-042): you bring your own app name and id, env values, brand, optional Firebase files and signing keys.

## 0. Prerequisites
Flutter 3.47.0 stable (CI pins this), JDK 17+ (21 works), Android SDK (platform 37), Xcode + CocoaPods for iOS. Android and iOS only (D-022).

## 1. Copy the template
Clone or copy the repo, delete `.git`, `git init`, first commit "Initial commit from riverpod_core".

## 2. Rename
From the project root:
```
dart run tool/rename_app.dart --name "My App" --id com.company.myapp
```
- Add `--package my_app` to override the Dart package name (default: derived from `--name`), `--host links.company.com` for the deep-link domain (default: keep `example.com`); `--dry-run` only prints the changes; invalid input writes nothing.
- It updates: `pubspec.yaml` (name, description), every `package:riverpod_core/` import in `lib/`, `test/`, `integration_test/`, Android `namespace` + `applicationId` + `MainActivity` package/folder + manifest label,
  iOS `CFBundleDisplayName`/`CFBundleName` + `PRODUCT_BUNDLE_IDENTIFIER` (and `<id>.RunnerTests`), the first `# ` title of `README.md`, and `APP_NAME` in `env/*.env` and `env/*.env.example`.
- Then run what the script prints: `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs` (or `./build.sh`), `dart format .`, `flutter analyze`.
- Write your own `README.md` afterwards (only its first title line is renamed).
- Deep links: the custom scheme becomes the package name with `_` as `-`; `--host` rewrites the https host (manifest, `deep_link.dart`, and `applinks:` if you enabled it). See `ai-docs/DEEP_LINKS.md`.

## 3. Environments
```
for f in env/*.env.example; do cp "$f" "${f%.example}"; done
```
Fill `env/dev.env`, `env/staging.env`, `env/prod.env` (keys: `APP_NAME`, `API_BASE_URL`, `CONNECT_TIMEOUT_MS`, `RECEIVE_TIMEOUT_MS`, optional `LOG_LEVEL`, `ENABLE_CRASH_REPORTING`, `ENABLE_ANALYTICS`, `CRASH_DSN`).
- `flutter run` = dev (debug), `flutter run --release` = prod, `flutter run -t lib/main_staging.dart` = staging (D-024). Staging and prod require an `https` base URL.
- The app refuses to start with a clear on-screen list of problems if a required key is missing or invalid.
- The real `env/*.env` files are git-ignored. Never put real secrets in them: the values are bundled in the app.
- Set `authUseMockSource` to `false` in `lib/core/auth/auth_endpoints.dart` and set the real endpoints there once your backend exists (the mock source lets the app run without a backend).

## 4. Firebase (optional)
Skip it and the app still runs: push is off with one log line, everything else works.
- **Push (merged):** create the Firebase project, add `google-services.json` to `android/app/` and `GoogleService-Info.plist` to `ios/Runner/` locally (git-ignored, never commit), apply the Google Services Gradle plugin in
  `android/app/build.gradle.kts`, upload an APNs auth key, enable Push Notifications + Background Modes (Remote notifications). Full checklist and testing: `ai-docs/NOTIFICATIONS.md`.
  Implement `PushTokenRegistrar` for your API and override `pushTokenRegistrarProvider`. Add your notification `type` values to `routeForDeepLink` in `core/router/routes.dart`.
- **Crashlytics and Firebase Analytics (pending C-30):** will need no extra steps beyond the same two Firebase files; collection is off in debug and on in release with a consent switch (D-042).
  Until C-30 is merged, crash reporting and analytics are the no-op/console implementations behind `CrashReporter` / `AnalyticsService`.
- **Native flavors (optional, D-043):** the template ships none, so `flutter run` needs no `--flavor`. If your app needs different bundle ids per environment, add Android `productFlavors` in
  `android/app/build.gradle.kts` and iOS schemes/configurations in Xcode yourself, then run with `--flavor <name> -t lib/main_staging.dart` (staging) and keep `Flavor.current` for the rest.
  Keep one `google-services.json` per flavor directory if you use Firebase. Record the change as a DECISION in your app. Give each flavor its own deep-link scheme (manifest placeholders on Android, per-configuration `CFBundleURLSchemes` on iOS) and keep `deepLinkScheme` in step.

## 5. Branding
- Edit ONLY `lib/core/design_system/tokens/brand_config.dart` (`brandSeedColor`, `brandFontFamily`). Light and dark schemes derive from the seed; nothing else holds a hex value.
- Replace the Android notification icon `android/app/src/main/res/drawable/ic_notification.xml`.
- **Icon**: replace `assets/images/app_icon.png` (1024 px, full icon) and `assets/images/app_icon_foreground.png` (1024 px, transparent, artwork inside the central 66%) with your own art (the placeholders come from `dart run tool/generate_placeholder_icon.dart`, which uses the seed color). Set `adaptive_icon_background` in the `flutter_launcher_icons` block of `pubspec.yaml`, then run `dart run flutter_launcher_icons` and commit the generated files. If it rewrites `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS` in `ios/Runner.xcodeproj/project.pbxproj` to `AppIcon`, revert that line to `YES`.
- **Native splash**: set colors and image in the `flutter_native_splash` block of `pubspec.yaml` (same color as the seed), run `dart run flutter_native_splash:create`, commit. If it re-indents `ios/Runner/Info.plist`, keep only the real changes.
- **Deep links**: `ai-docs/DEEP_LINKS.md` (host, scheme, `assetlinks.json`, `apple-app-site-association`, enabling Universal Links with a paid Apple team).

## 6. Translations
Edit `assets/translations/{ar,en}.json` (both files, same commit), then `./build.sh` and `dart format lib/generated`, and commit the regenerated `lib/generated/*`.
Use ONLY `LocaleKeys.group_key.tr()` in code (D-037). The parity and no-literal-keys tests must stay green. Recipe: `.claude/skills/add-translation-keys/SKILL.md`.

## 7. First feature
```
dart run tool/new_feature.dart --name product_orders     # add --dry-run to preview
```
It scaffolds `lib/features/product_orders/` and `test/features/product_orders/` from `.fttemplates/feature`, adds a translation group to both JSON files and prints the typed route to paste into
`lib/core/router/routes.dart`. Then run the printed generation commands, replace the model fields and endpoint, and follow `.claude/skills/new-feature/SKILL.md`.
Pages: `.claude/skills/new-page/SKILL.md`; API calls: `.claude/skills/new-api-call/SKILL.md`.
Read features are meant to be cache-first through the shared helper (D-038): **(pending C-44)** the full policy (presets, ETag, pruning) lands there; the scaffold's repository has the single read method where the helper plugs in.

## 8. Demo features
`features/showcase` (component gallery, `/showcase`) and `features/videos` (reference feature on a mock source) exist only in dev and staging builds. Keep them while learning the patterns; delete them when you ship:
remove the two feature folders, their routes in `routes.dart` and the two dev-only tiles in `features/home/presentation/pages/home_page.dart`, then regenerate and fix tests. Nothing else imports them (D-028).

## 9. Storage
**(pending C-41)** Local storage moves to `hive_ce` (D-034) and replaces `shared_preferences` and Drift. Until C-41 is merged, settings use `shared_preferences` and the cache helper uses a Drift table. Start your features against `PrefsStorage`,
`SecureStorage` and the cache helper only (never the packages directly) and they will not change when the store does.

## 10. Gate before every commit
The Definition of Done commands in `CLAUDE.md`:
```
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # if codegen is touched
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```
CI (`.github/workflows/ci.yml`) runs the same plus a stale-generated-code check and debug builds for Android and iOS.

## 11. Release
- Android: `cp android/key.properties.example android/key.properties`, fill it, keep the keystore outside the repo. iOS: pick your team in Xcode, `cp ios/ExportOptions.plist.example ios/ExportOptions.plist`.
- Build: `tool/release/build_android.sh [--flavor staging|prod]` and `tool/release/build_ios.sh [--flavor staging|prod]` (they run the gate first, then obfuscated release builds). Details: `tool/release/README.md`.
- Before shipping run the checklist in `.claude/skills/release-check/SKILL.md`.
- Signing files (`key.properties`, `*.jks`, `*.keystore`, `ExportOptions.plist`, `*.mobileprovision`) and `build-symbols/` stay untracked.

## 12. Integration tests
**(pending C-26)** Auth flow + one feature flow under `integration_test/`; run with `flutter test integration_test` on a device or emulator. Not part of the default gate.

## Toolchain requirements (C-43)
Verified versions: Flutter 3.47 (Dart per `pubspec.yaml`), JDK 17+ (21 works), Gradle wrapper 8.14.3, Android Gradle Plugin 8.11.1, Kotlin Gradle plugin 2.4.0 (plugins ship Kotlin 2.4 metadata, so the project plugin must be >= 2.4),
`compileSdk` 37 (required by `permission_handler_android`), `minSdk` 24, Java/Kotlin target 17, NDK from Flutter (28.2), iOS deployment target 15.0 with CocoaPods (`pod install` runs on the first iOS build).
Create `env/{dev,staging,prod}.env` from the examples before the first build. Release builds need `android/key.properties` (see `tool/release/README.md`).
Flutter warns that Gradle < 9.1 and AGP < 9.0.1 will be dropped soon; plan that upgrade as its own task once the Firebase and other plugins support AGP 9.
