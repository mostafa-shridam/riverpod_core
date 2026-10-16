import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/extension/language.dart';

void main() {
  test('Language maps to and from locales', () {
    expect(Language.arabic.locale, const Locale('ar'));
    expect(Language.fromLocale(const Locale('ar', 'EG')), Language.arabic);
    expect(Language.fromLocale(const Locale('fr')), Language.english);
  });
}
