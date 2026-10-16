# Release scripts

Both scripts run from the repo root or anywhere (they `cd` to the root), are `set -euo pipefail`, run the
pre-release gate (`dart format --set-exit-if-changed lib test tool`, `flutter analyze`, `flutter test`),
build with `--release --obfuscate --split-debug-info=build-symbols/<platform>`, and print the artifact path.
They never print passwords. Staging uses `lib/main_staging.dart`, prod uses `lib/main.dart` (D-024).

| Script | Command | Artifact |
|---|---|---|
| `build_android.sh [--flavor staging\|prod]` | `flutter build appbundle` | `build/app/outputs/bundle/release/app-release.aab` |
| `build_ios.sh [--flavor staging\|prod]` | `flutter build ipa --export-options-plist=ios/ExportOptions.plist` | `build/ios/ipa/*.ipa` |

Default flavor is `prod`. Requires `env/<flavor>.env` (copy from `env/<flavor>.env.example`; real files are git-ignored).
Also run the rest of the `release-check` skill (`.claude/skills/release-check/SKILL.md`) before shipping.

## Android signing
1. Create the keystore once and keep it OUTSIDE the repo (a password manager or secure backup too; losing it can lock you out of updates):
   ```
   keytool -genkey -v -keystore ~/keys/upload-keystore.jks -storetype JKS \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. `cp android/key.properties.example android/key.properties` and fill in:
   - `storePassword`, `keyPassword`: the passwords chosen in step 1
   - `keyAlias`: `upload` (or the alias you used)
   - `storeFile`: path to the `.jks`, relative to `android/` or absolute
3. `android/key.properties`, `*.jks`, `*.keystore` are git-ignored. Never commit them.

Behaviour (`android/app/build.gradle.kts`): without `key.properties`, debug builds and `flutter run` work as before;
any release build (`assembleRelease`, `bundleRelease`, `flutter build apk/appbundle --release`) fails with
"Release build requires android/key.properties (not found) ...". The debug key is never used for a release artifact.

## iOS signing and export
1. In Xcode (Runner target > Signing & Capabilities) select your team, or install your distribution certificate and profile.
2. `cp ios/ExportOptions.plist.example ios/ExportOptions.plist` and set `teamID`, `method` (`app-store-connect`, `ad-hoc`, ...),
   and for manual signing `signingStyle` = `manual` plus `provisioningProfiles` (bundle id -> profile name).
3. `ios/ExportOptions.plist` and `*.mobileprovision` are git-ignored. Never commit them.

## Symbols
`build-symbols/` (git-ignored) holds the obfuscation maps. Archive them per release (e.g. upload to your crash reporter)
to de-obfuscate stack traces.
