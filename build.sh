#!/usr/bin/env bash
# Regenerates translations + codegen (riverpod, freezed, json). Run from the repo root.
set -euo pipefail
dart run easy_localization:generate --source-dir assets/translations
dart run easy_localization:generate -S assets/translations -f keys -o locale_keys.g.dart
dart run build_runner build --delete-conflicting-outputs
