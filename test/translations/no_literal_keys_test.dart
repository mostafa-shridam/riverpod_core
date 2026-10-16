import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A `.tr()` or `.plural()` call on a string literal: `'app_nav.home'.tr()`,
/// `"app.title".tr()`, or `.plural('items.count', ...)`. Keys must come from
/// `LocaleKeys` (D-037), so the translation key is checked at compile time.
final _literalTranslation = RegExp(
  r'''(['"])[^'"\n]*\1\s*\.\s*(tr|plural)\s*\(|\.\s*plural\(\s*['"]''',
);

/// Matches of [_literalTranslation] in [source], as `line: text`.
List<String> literalTranslations(String source) {
  final hits = <String>[];
  final lines = source.split('\n');
  for (var i = 0; i < lines.length; i++) {
    for (final match in _literalTranslation.allMatches(lines[i])) {
      hits.add('${i + 1}: ${match.group(0)}');
    }
  }
  return hits;
}

void main() {
  group('self-test of the pattern', () {
    test('catches a literal key with tr()', () {
      expect(literalTranslations("Text('app_nav.home'.tr())"), hasLength(1));
    });

    test('catches a double-quoted literal with tr()', () {
      expect(literalTranslations('x = "app.title".tr();'), hasLength(1));
    });

    test('catches plural() with a literal key', () {
      expect(literalTranslations("n.plural('items.count', 2)"), hasLength(1));
    });

    test('accepts LocaleKeys constants and plain strings', () {
      expect(
        literalTranslations(
          'Text(LocaleKeys.app_nav_home.tr());\n'
          "final label = 'plain text';\n"
          'final n = LocaleKeys.items_count.plural(2);',
        ),
        isEmpty,
      );
    });
  });

  test('no string literal is passed to tr() or plural() under lib/', () {
    final failures = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('.g.dart') ||
          entity.path.contains('lib/generated/')) {
        continue;
      }
      for (final hit in literalTranslations(entity.readAsStringSync())) {
        failures.add('${entity.path}:$hit');
      }
    }
    expect(
      failures,
      isEmpty,
      reason: 'Use LocaleKeys.<group>_<key>.tr() instead (D-037).',
    );
  });
}
