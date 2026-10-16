import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:riverpod_core/l10n/app_formatters.dart';

void main() {
  setUpAll(initializeDateFormatting);

  final moment = DateTime(2026, 10, 16, 15, 45);

  group('en', () {
    const f = AppFormatters('en');
    test('numbers', () {
      expect(f.number(1234567.5), '1,234,567.5');
      expect(f.number(1.23456, maxDecimals: 2), '1.23');
      expect(f.percent(0.256), '26%');
      expect(f.percent(0.256, decimals: 1), '25.6%');
      expect(f.currency(1234.5, code: 'USD'), r'$1,234.50');
      expect(f.compact(1200), '1.2K');
    });
    test('dates', () {
      expect(f.date(moment), 'Oct 16, 2026');
      expect(f.dateLong(moment), 'Fri, Oct 16, 2026');
      expect(f.time(moment), contains('3:45'));
      expect(f.time(moment), contains('PM'));
      expect(f.dateTime(moment), contains('Oct 16, 2026'));
    });
    test('Arabic-Indic setting is ignored for en', () {
      const g = AppFormatters('en', useArabicIndicDigits: true);
      expect(g.number(1234), '1,234');
    });
  });

  group('ar with Latin digits (default policy)', () {
    const f = AppFormatters('ar');
    test('numbers use Latin digits and ASCII separators', () {
      expect(f.number(1234567.5), '1,234,567.5');
      expect(f.percent(0.25), '25%');
      expect(f.currency(1234.5, code: 'EGP'), contains('1,234.50'));
      expect(f.currency(1234.5, code: 'EGP', symbol: 'EGP'), contains('EGP'));
    });
    test('dates use Arabic names with Latin digits', () {
      final text = f.date(moment);
      expect(text, contains('2026'));
      expect(text, contains('16'));
      expect(text, contains('أكتوبر'));
      expect(f.time(moment), contains('3:45'));
      expect(f.time(moment), contains('م'));
    });
  });

  group('ar with Arabic-Indic digits', () {
    const f = AppFormatters('ar', useArabicIndicDigits: true);
    test('numbers', () {
      expect(f.number(1234), contains('١'));
      expect(f.number(1234), isNot(matches(RegExp('[0-9]'))));
      expect(f.percent(0.25), contains('٢٥'));
    });
    test('dates', () {
      final text = f.date(moment);
      expect(text, contains('٢٠٢٦'));
      expect(text, isNot(matches(RegExp('[0-9]'))));
    });
  });
}
