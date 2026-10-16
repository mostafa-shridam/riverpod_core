import 'package:easy_localization/easy_localization.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';
import 'package:riverpod_core/l10n/app_formatters.dart';
import 'package:riverpod_core/l10n/localized_text.dart';

/// "5 minutes ago" / "In 2 hours" relative to [now]. Beyond 30 days it falls
/// back to the formatted date. Needs a loaded localization (UI or tests).
String relativeTime(
  DateTime value, {
  required DateTime now,
  required AppFormatters formatters,
}) {
  final diff = value.difference(now);
  final past = diff.isNegative;
  final span = diff.abs();

  if (span < const Duration(minutes: 1)) {
    return LocaleKeys.l10n_relative_now.tr();
  }
  if (span < const Duration(hours: 1)) {
    return pluralText(
      past
          ? LocaleKeys.l10n_relative_minutesAgo
          : LocaleKeys.l10n_relative_minutesIn,
      span.inMinutes,
      formatters: formatters,
    );
  }
  if (span < const Duration(days: 1)) {
    return pluralText(
      past
          ? LocaleKeys.l10n_relative_hoursAgo
          : LocaleKeys.l10n_relative_hoursIn,
      span.inHours,
      formatters: formatters,
    );
  }
  if (span < const Duration(days: 30)) {
    return pluralText(
      past ? LocaleKeys.l10n_relative_daysAgo : LocaleKeys.l10n_relative_daysIn,
      span.inDays,
      formatters: formatters,
    );
  }
  return formatters.date(value);
}
