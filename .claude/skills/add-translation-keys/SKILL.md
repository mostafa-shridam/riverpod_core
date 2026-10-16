---
name: add-translation-keys
description: Add or change localization keys in both Arabic and English, regenerate code, keep the parity test green.
---

# add-translation-keys

1. Choose keys per CONVENTIONS.md: `feature.screen.element` (lowerCamelCase segments); errors in `errors.*`; shared in `common.*`.
2. Edit BOTH `assets/translations/en.json` and `assets/translations/ar.json` in the same change, same key order. Nested objects are allowed.
   - Placeholders: same names in both languages (`{name}`), never concatenate translated fragments.
   - Plurals: use the plural form object (`zero/one/two/few/many/other`) in both languages; Arabic needs all six where meaningful.
   - Arabic text must be natural (not literal word-for-word); avoid mixing Latin digits unless the number policy says so.
3. Regenerate under the lock (`mkdir /tmp/riverpod_core.lock` … `rmdir`):
   ```
   dart run easy_localization:generate --source-dir assets/translations
   dart run easy_localization:generate -S assets/translations -f keys -o locale_keys.g.dart
   ```
   (the repo's `build.sh` wraps these). Run `dart format lib/generated`, then commit the regenerated `lib/generated/*.g.dart` together with the JSON (if a merge conflicts in generated files, regenerate; never hand-edit).
4. Use keys only through `LocaleKeys.<path>.tr()` / `.plural()` — NEVER a string literal like `'a.b'.tr()` and never a hand-written key-constant file (D-037).
5. Run `flutter test test/translations` (parity test: same keys, no empty values, same placeholders) and the full gate.
6. Never delete a key still referenced: `grep -rn "LocaleKeys.<key>" lib` first.
