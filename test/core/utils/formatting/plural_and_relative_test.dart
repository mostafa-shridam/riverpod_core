import 'dart:convert';
import 'dart:io';

// Test-only: loads translations without a widget tree.
// ignore: implementation_imports
import 'package:easy_localization/src/localization.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/translations.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:riverpod_core/core/utils/formatting/app_formatters.dart';
import 'package:riverpod_core/core/utils/formatting/localized_text.dart';
import 'package:riverpod_core/core/utils/formatting/relative_time.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

void _load(String code) {
  final json =
      jsonDecode(File('assets/translations/$code.json').readAsStringSync())
          as Map<String, dynamic>;
  Localization.load(
    Locale(code),
    translations: Translations(json),
    ignorePluralRules: false,
  );
}

void main() {
  setUpAll(initializeDateFormatting);

  group('Arabic plurals (zero/one/two/few/many/other)', () {
    setUp(() => _load('ar'));
    const f = AppFormatters('ar');
    String t(num n) =>
        pluralText(LocaleKeys.common_itemsCount, n, formatters: f);

    test('each category picks its own form', () {
      expect(t(0), 'لا عناصر');
      expect(t(1), 'عنصر واحد');
      expect(t(2), 'عنصران');
      expect(t(3), '3 عناصر');
      expect(t(10), '10 عناصر');
      expect(t(11), '11 عنصرًا');
      expect(t(99), '99 عنصرًا');
      expect(t(100), '100 عنصر');
    });

    test('count follows the digit policy', () {
      const indic = AppFormatters('ar', useArabicIndicDigits: true);
      expect(
        pluralText(LocaleKeys.common_itemsCount, 5, formatters: indic),
        '٥ عناصر',
      );
    });
  });

  group('English plurals', () {
    setUp(() => _load('en'));
    const f = AppFormatters('en');
    String t(num n) =>
        pluralText(LocaleKeys.common_itemsCount, n, formatters: f);

    test('one and other', () {
      expect(t(1), 'One item');
      expect(t(2), '2 items');
      expect(t(1000), '1,000 items');
    });
  });

  group('relativeTime', () {
    final now = DateTime(2026, 10, 16, 12);

    test('en', () {
      _load('en');
      const f = AppFormatters('en');
      String r(Duration d) => relativeTime(now.add(d), now: now, formatters: f);
      expect(r(const Duration(seconds: -10)), 'Just now');
      expect(r(const Duration(minutes: -5)), '5 minutes ago');
      expect(r(const Duration(hours: -1)), '1 hour ago');
      expect(r(const Duration(days: -1)), 'Yesterday');
      expect(r(const Duration(hours: 3)), 'In 3 hours');
      expect(r(const Duration(days: 2, minutes: 1)), 'In 2 days');
      expect(r(const Duration(days: -60)), contains('Aug'));
    });

    test('ar uses dual, few and many forms', () {
      _load('ar');
      const f = AppFormatters('ar');
      String r(Duration d) => relativeTime(now.add(d), now: now, formatters: f);
      expect(r(const Duration(seconds: -10)), 'الآن');
      expect(r(const Duration(minutes: -2)), 'منذ دقيقتين');
      expect(r(const Duration(minutes: -5)), 'منذ 5 دقائق');
      expect(r(const Duration(minutes: -20)), 'منذ 20 دقيقة');
      expect(r(const Duration(hours: 2)), 'بعد ساعتين');
    });
  });
}
