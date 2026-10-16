import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_form_field.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/selection_strings.dart';

/// Star rating from 0 to [max] in whole steps, filling from the start edge
/// (right in Arabic). Controlled: pass [value]; tapping the selected star
/// again clears to 0 when [allowClear]. With [onChanged] null the stars are
/// display only (not dimmed); set [enabled] false to dim them.
class AppRating extends StatelessWidget {
  const AppRating({
    required this.value,
    required this.onChanged,
    super.key,
    this.max = 5,
    this.label,
    this.helper,
    this.allowClear = true,
    this.validator,
    this.errorText,
    this.enabled = true,
  });

  final int value;

  /// Null makes the rating read-only.
  final ValueChanged<int>? onChanged;
  final int max;
  final String? label;
  final String? helper;
  final bool allowClear;
  final FormFieldValidator<int>? validator;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final interactive = enabled && onChanged != null;
    final locale = Localizations.localeOf(context).toString();
    final nf = intl.NumberFormat.decimalPattern(locale);
    final starSize = tokens.sizes.iconLg + tokens.spacing.xs;
    final filled = enabled ? tokens.colors.warning : scheme.outlineVariant;

    return AppFormField<int>(
      value: value,
      label: label,
      helper: helper,
      enabled: enabled,
      validator: validator,
      forceErrorText: errorText,
      builder: (state) {
        void set(int next) {
          state.didChange(next);
          onChanged!(next);
        }

        return Semantics(
          container: true,
          label: label,
          value: ratingValueKey.tr(args: [nf.format(value), nf.format(max)]),
          increasedValue: nf.format((value + 1).clamp(0, max)),
          decreasedValue: nf.format((value - 1).clamp(0, max)),
          onIncrease: interactive && value < max ? () => set(value + 1) : null,
          onDecrease: interactive && value > 0 ? () => set(value - 1) : null,
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 1; i <= max; i++)
                  SizedBox.square(
                    dimension: tokens.sizes.minTouchTarget,
                    child: InkResponse(
                      radius: tokens.sizes.minTouchTarget / 2,
                      onTap: interactive
                          ? () => set(allowClear && i == value ? 0 : i)
                          : null,
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: tokens.durations.fast,
                          child: Icon(
                            i <= value
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            key: ValueKey(i <= value),
                            size: starSize,
                            color: i <= value
                                ? filled
                                : scheme.outline.withValues(
                                    alpha: enabled ? 1 : 0.38,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
