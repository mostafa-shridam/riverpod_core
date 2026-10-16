import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'package:riverpod_core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/design_system/widgets/feedback/feedback_strings.dart';

/// Linear progress. `value` 0..1 is determinate, null is indeterminate.
/// Rounded track, optional [label] and localized percent text.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    this.value,
    this.label,
    this.showPercent = false,
    this.color,
    this.semanticLabel,
  }) : assert(value == null || (value >= 0 && value <= 1));

  final double? value;
  final String? label;

  /// Shows "45%" (locale digits) at the end of the label row.
  final bool showPercent;
  final Color? color;

  /// Overrides the localized "progress" announcement.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final percent = value == null
        ? null
        : intl.NumberFormat.percentPattern(locale).format(value);
    final hasText = label != null || (showPercent && percent != null);

    return Semantics(
      label: semanticLabel ?? label ?? progressLabelKey.tr(),
      value: percent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasText)
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: tokens.spacing.xs),
              child: Row(
                children: [
                  if (label != null)
                    Expanded(
                      child: Text(label!, style: theme.textTheme.labelLarge),
                    )
                  else
                    const Spacer(),
                  if (showPercent && percent != null)
                    Text(
                      percent,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ExcludeSemantics(
            child: LinearProgressIndicator(
              value: value,
              minHeight: tokens.spacing.sm,
              color: color ?? scheme.primary,
              backgroundColor: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(tokens.radius.full),
            ),
          ),
        ],
      ),
    );
  }
}
