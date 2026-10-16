# HOW TO START A NEW APP FROM THIS TEMPLATE

Status: skeleton. Steps marked (pending C-xx) depend on a task that is not DONE yet; this file is completed by C-29.

1. **Copy the template**: clone/copy the repo, delete `.git`, `git init`, first commit "Initial commit from riverpod_core".
2. **Rename** (pending C-13): run the rename script with the new package id (`com.company.app`) and display name. Until then: `dart run rename_app:main all="My App Name"` and change `applicationId`/`namespace` in `android/app/build.gradle.kts` and the Kotlin package folder by hand.
3. **Environments** (pending C-37, C-08): copy `env/dev.env.example` → `env/dev.env` (same for staging/prod), fill values. Then just `flutter run` (debug = dev, release = prod; staging: `flutter run -t lib/main_staging.dart`). The app refuses to start with a clear error if a required key is missing. Never put real secrets in env files: they are bundled in the app.
4. **Firebase** (only if you use notifications/crash): add your own `google-services.json` and `GoogleService-Info.plist` locally. They are git-ignored; never commit them.
5. **Branding**: edit ONLY `lib/core/design_system/tokens/brand_config.dart` (seed color, font) (pending C-05); replace `assets/images/appLogo.png`, then `dart run flutter_launcher_icons` and the splash command (pending C-13).
6. **Translations**: edit `assets/translations/{ar,en}.json`, run the generation commands in `build.sh`; the parity test must stay green.
7. **First feature**: follow `.claude/skills/new-feature/SKILL.md` (scaffold from `.fttemplates`, register the route, write tests).
8. **Gate before every commit**: the Definition of Done commands in `CLAUDE.md`.
9. **Release** (pending C-28): `.claude/skills/release-check/SKILL.md`, signing files stay untracked.
