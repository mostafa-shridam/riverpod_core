# C-29 (docs half) — README, CHECKLIST, HOW_TO_START_A_NEW_APP

Worker S8, branch `worker-z` (from main a3c6976).

## What changed
- `README.md`: full rewrite. Template purpose (zero project data, D-042), feature list grouped like the checklist, architecture tree with layering rules and reasons,
  package table (every dependency and dev dependency with exact locked version, use in this repo, why/rejected, licence), environment setup, run/install, Firebase optionality,
  new-app and feature scaffold, localization workflow, design system tour and showcase, cache-first data layer, testing guide, CI, release, troubleshooting, links to every ai-docs file,
  and one line per decision D-001..D-043.
- `ai-docs/CHECKLIST.md`: rewritten to the current truth (DONE/PARTIAL/MISSING/DECLINED with the closing task).
- `ai-docs/HOW_TO_START_A_NEW_APP.md`: all real steps completed; pending ones marked `(pending C-xx)`.

## Status notes the Lead removes when the task is DONE
README and HOW_TO carry `Status:` / `(pending C-xx)` notes for: C-41 (hive_ce storage), C-44 (cache-first policy), C-46 (rationale wiring), C-21 (remote config), C-30 (Crashlytics/Analytics),
C-31 (icons, splash, deep links), C-26 (integration tests). Search for `Status:` and `pending C-` to find them. The package table must be refreshed from `pubspec.lock` after C-41 and C-30.

## Verification method
Facts were checked against `lib/`, `pubspec.yaml`/`pubspec.lock`, `tool/`, `.github/workflows`, `android/`, `ios/`, `test/` and the task reports. Licences were read from each package's LICENSE file in the pub cache.

## Claims not verified against the code or by running
- That a fresh clone builds and runs: not run here (no device builds); relies on C-43 and C-27 reports.
- `tool/release/*.sh` behaviour: taken from `tool/release/README.md` and the C-28 report; the scripts were not executed (they need real signing keys).
- Android platform 37 as an SDK prerequisite: inferred from `compileSdk = 37`.
- "About 100 test files / 190+ goldens": counted with `find` (100 `*_test.dart`, 194 `*.png`); test pass count not re-run here.
- `json_annotation` role ("runtime for generated code"): inferred; no direct import in `lib/`.
- `image_picker` licence reads as Apache-2.0 from its LICENSE file (pub.dev may list a different SPDX); `hive_ce` licence is not in the table because it is not in the repo yet (D-034 wording applies).
- Native flavors paragraph in HOW_TO (productFlavors / schemes) is generic Flutter guidance, not template code (D-043 says the doc explains it).

## Observations for the Lead (not changed, outside my files)
- `.claude/skills/release-check/SKILL.md` still refers to `env/prod.json` and `--dart-define-from-file` (superseded by D-024).
- `cloud_firestore`, `firebase_auth`, `google_sign_in` are dependencies (D-012) but nothing under `lib/` imports them.
- `DECISIONS.md` D-013 says exact versions are recorded in README (done now); D-015, D-016 and D-019 still name superseded paths (`lib/design_system`, `app/router`) by design (append-only).
- `ai-docs/ARCHITECTURE.md` still lists `core/remote_config/`, `integration_test/` (target state, pending C-21 and C-26).
