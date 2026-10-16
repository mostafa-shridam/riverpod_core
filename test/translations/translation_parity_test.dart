import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _translationsDir = 'assets/translations';

/// Flattens nested JSON to dotted keys, e.g. `errors.network` -> value.
Map<String, String> _flatten(Map<String, dynamic> json, [String prefix = '']) {
  final out = <String, String>{};
  json.forEach((key, value) {
    final path = prefix.isEmpty ? key : '$prefix.$key';
    if (value is Map<String, dynamic>) {
      out.addAll(_flatten(value, path));
    } else {
      out[path] = value.toString();
    }
  });
  return out;
}

Map<String, String> _load(String locale) {
  final file = File('$_translationsDir/$locale.json');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return _flatten(json);
}

/// `{}` and `{name}` placeholders, sorted so order does not matter.
List<String> _placeholders(String value) {
  return RegExp(
    r'\{[^{}]*\}',
  ).allMatches(value).map((m) => m.group(0)!).toList()..sort();
}

void main() {
  final en = _load('en');
  final ar = _load('ar');

  test('ar and en have the same keys', () {
    expect(
      ar.keys.toSet(),
      en.keys.toSet(),
      reason:
          'only in en: ${en.keys.toSet().difference(ar.keys.toSet())}; '
          'only in ar: ${ar.keys.toSet().difference(en.keys.toSet())}',
    );
  });

  test('no translation value is empty', () {
    for (final locale in {'en': en, 'ar': ar}.entries) {
      final empty = locale.value.entries
          .where((e) => e.value.trim().isEmpty)
          .map((e) => e.key);
      expect(empty, isEmpty, reason: '${locale.key} has empty values');
    }
  });

  test('placeholders match between ar and en', () {
    for (final key in en.keys) {
      if (!ar.containsKey(key)) continue;
      expect(
        _placeholders(ar[key]!),
        _placeholders(en[key]!),
        reason: 'placeholder mismatch for $key',
      );
    }
  });
}
