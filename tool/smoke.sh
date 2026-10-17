#!/usr/bin/env bash
# Clean-clone smoke run. Copies the committed tree into a temp dir,
# uses only the committed *.env.example files (no real values, no Firebase
# files), then runs codegen, analyze, the unit tests, the debug builds and the
# integration test on an iOS simulator. Exits non-zero on the first failure.
# Never touches the working tree it runs from.
#
# Usage: tool/smoke.sh [simulator-udid]
#   SKIP_ANDROID=1 skips the Android build (no Android SDK on this machine).
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d "${TMPDIR:-/tmp}/riverpod_core_smoke.XXXXXX")"
booted_here=""
udid="${1:-}"

cleanup() {
  if [[ -n "$booted_here" ]]; then
    xcrun simctl shutdown "$booted_here" >/dev/null 2>&1 || true
  fi
  rm -rf "$work"
}
trap cleanup EXIT

step() { printf '\n== %s ==\n' "$1"; }

step "Clean copy of HEAD into $work"
git -C "$repo_root" archive --format=tar HEAD | tar -x -C "$work"
cd "$work"

step "No Firebase or real env files in the copy"
leaked=$(find . \( -name 'google-services.json' -o -name 'GoogleService-Info.plist' \
  -o -name '*.keystore' -o -name '*.jks' -o -name '*.p8' \) -not -path './.git/*')
if [[ -n "$leaked" ]]; then
  echo "Forbidden files in the clean copy:" >&2
  echo "$leaked" >&2
  exit 1
fi

step "Env files from the committed examples only"
for f in env/*.env.example; do cp "$f" "${f%.example}"; done

step "pub get"
flutter pub get

step "Codegen"
dart run build_runner build --delete-conflicting-outputs

step "Format"
dart format --set-exit-if-changed lib test tool integration_test

step "Analyze"
flutter analyze

step "Unit and widget tests"
flutter test

if [[ "${SKIP_ANDROID:-0}" != "1" ]]; then
  step "Android debug build"
  flutter build apk --debug
else
  step "Android debug build skipped (SKIP_ANDROID=1)"
fi

step "iOS debug build (no codesign)"
flutter build ios --no-codesign --debug

step "Simulator for the integration test"
if [[ -z "$udid" ]]; then
  udid="$(xcrun simctl list devices booted | grep -Eo '[0-9A-F-]{36}' | head -1 || true)"
fi
if [[ -z "$udid" ]]; then
  udid="$(xcrun simctl list devices available | grep -E 'iPhone' | grep -Eo '[0-9A-F-]{36}' | head -1)"
  if [[ -z "$udid" ]]; then
    echo "No iOS simulator available" >&2
    exit 1
  fi
  xcrun simctl boot "$udid"
  booted_here="$udid"
fi
echo "Using simulator $udid"

step "Integration test (flow)"
flutter test integration_test/app_flow_test.dart -d "$udid"

step "Smoke run passed"
