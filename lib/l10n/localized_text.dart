import 'package:easy_localization/easy_localization.dart';
import 'package:riverpod_core/l10n/app_formatters.dart';

/// Plural-aware text. [key] is an object with zero/one/two/few/many/other
/// children (see `l10n.itemsCount`); the count replaces `{}` and goes through
/// [formatters] so it follows the digit policy.
///
/// Arabic few/many only work when `EasyLocalization` is built with
/// `ignorePluralRules: false` (see `ai-docs/reports/C-12.md`).
String pluralText(String key, num count, {required AppFormatters formatters}) {
  return plural(key, count, args: [formatters.number(count)]);
}
