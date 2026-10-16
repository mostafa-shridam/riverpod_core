import 'package:intl/intl.dart';

/// Locale-aware formatting for every user-visible number, date and amount.
///
/// Digit policy: Latin digits by default in both languages. With
/// [useArabicIndicDigits] and an Arabic locale, digits are Arabic-Indic.
/// `intl` formats Arabic with Arabic-Indic digits and separators, so the
/// output is normalised here to keep one predictable policy.
class AppFormatters {
  const AppFormatters(this.locale, {this.useArabicIndicDigits = false});

  /// BCP-47 language code (`ar`, `en`).
  final String locale;
  final bool useArabicIndicDigits;

  bool get _isArabic => locale == 'ar';

  /// Plain number with grouping, e.g. `1,234.5`.
  String number(num value, {int? maxDecimals}) {
    final format = NumberFormat.decimalPattern(locale);
    if (maxDecimals != null) format.maximumFractionDigits = maxDecimals;
    return _numeric(format.format(value));
  }

  /// A [ratio] of `0.256` becomes `26%`.
  String percent(double ratio, {int decimals = 0}) {
    final format = NumberFormat.decimalPercentPattern(
      locale: locale,
      decimalDigits: decimals,
    );
    return _numeric(format.format(ratio));
  }

  /// Money in ISO-4217 [code] (`USD`, `EGP`); [symbol] overrides the glyph.
  String currency(num value, {required String code, String? symbol}) {
    final format = symbol == null
        ? NumberFormat.simpleCurrency(locale: locale, name: code)
        : NumberFormat.currency(locale: locale, name: code, symbol: symbol);
    return _numeric(format.format(value));
  }

  /// Compact form: `1.2K` / `١٫٢ ألف`.
  String compact(num value) {
    return _numeric(NumberFormat.compact(locale: locale).format(value));
  }

  /// `16 Oct 2026`.
  String date(DateTime value) =>
      _digits(DateFormat.yMMMd(locale).format(value));

  /// `Fri, 16 Oct 2026`.
  String dateLong(DateTime value) {
    return _digits(DateFormat.yMMMEd(locale).format(value));
  }

  /// `3:45 PM` / `3:45 م`.
  String time(DateTime value) => _digits(DateFormat.jm(locale).format(value));

  /// Date and time together.
  String dateTime(DateTime value) {
    return _digits(DateFormat.yMMMd(locale).add_jm().format(value));
  }

  /// Numbers: separators follow the digit policy too.
  String _numeric(String text) {
    var out = text;
    if (_isArabic && !useArabicIndicDigits) {
      out = out
          .replaceAll('٫', '.')
          .replaceAll('٬', ',')
          .replaceAll('٪؜', '%')
          .replaceAll('٪', '%')
          .replaceAll(RegExp('[‎‏؜]'), '');
    }
    return _digits(out);
  }

  String _digits(String text) {
    if (!_isArabic) return text;
    return useArabicIndicDigits ? _toArabicIndic(text) : _toLatin(text);
  }

  static const _arabicIndic = '٠١٢٣٤٥٦٧٨٩';

  static String _toLatin(String text) {
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      final index = _arabicIndic.indexOf(char);
      buffer.write(index == -1 ? char : '$index');
    }
    return buffer.toString();
  }

  static String _toArabicIndic(String text) {
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      final digit = int.tryParse(char);
      buffer.write(digit == null ? char : _arabicIndic[digit]);
    }
    return buffer.toString();
  }
}
