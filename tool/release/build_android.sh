#!/usr/bin/env bash
# Android release build (App Bundle). Run from anywhere; usage: tool/release/build_android.sh [--flavor staging|prod]
# Signing comes from the untracked android/key.properties (see tool/release/README.md). No secrets are printed.
set -euo pipefail

cd "$(dirname "$0")/../.."

flavor="prod"
while [ $# -gt 0 ]; do
  case "$1" in
    --flavor)
      [ $# -ge 2 ] || { echo "error: --flavor needs a value (staging|prod)" >&2; exit 2; }
      flavor="$2"
      shift 2
      ;;
    -h|--help)
      echo "usage: $0 [--flavor staging|prod]"
      exit 0
      ;;
    *)
      echo "error: unknown argument '$1'" >&2
      exit 2
      ;;
  esac
done

case "$flavor" in
  prod) target="lib/main.dart" ;;
  staging) target="lib/main_staging.dart" ;;
  *) echo "error: flavor must be 'staging' or 'prod' (got '$flavor')" >&2; exit 2 ;;
esac

[ -f "env/${flavor}.env" ] || { echo "error: env/${flavor}.env is missing. Copy env/${flavor}.env.example to env/${flavor}.env and fill it in." >&2; exit 1; }
[ -f "android/key.properties" ] || { echo "error: android/key.properties is missing. Copy android/key.properties.example and fill it in (see tool/release/README.md)." >&2; exit 1; }

echo "==> Pre-release gate (release-check skill, step 1)"
dart format --set-exit-if-changed lib test tool
flutter analyze
flutter test

echo "==> Building Android App Bundle (${flavor}, target ${target})"
flutter build appbundle --release --target "$target" \
  --obfuscate --split-debug-info=build-symbols/android

artifact="build/app/outputs/bundle/release/app-release.aab"
[ -f "$artifact" ] || { echo "error: expected artifact not found: $artifact" >&2; exit 1; }
echo "==> Done: $artifact"
echo "Archive build-symbols/android with this release (needed to de-obfuscate crash traces)."
