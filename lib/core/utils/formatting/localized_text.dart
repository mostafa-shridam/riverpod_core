import 'package:easy_localization/easy_localization.dart';
import 'package:riverpod_core/core/utils/formatting/app_formatters.dart';

/// Plural-aware text. [key] is an object with zero/one/two/few/many/other
/// children (see `common.itemsCount`); the count replaces `{}` and goes through
/// [formatters] so it follows the digit policy.
///
/// Arabic few/many only work when `EasyLocalization` is built with
/// `ignorePluralRules: false` (see D-035).
String pluralText(String key, num count, {required AppFormatters formatters}) {
  return plural(key, count, args: [formatters.number(count)]);
}
