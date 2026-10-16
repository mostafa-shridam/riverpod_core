import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_form_field.dart';

String _format(BuildContext context, double v) =>
    intl.NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    ).format(v);

/// Slider with the current value shown at the end of the row (locale digits
/// by default). Controlled: pass [value] and update it in [onChanged].
class AppSlider extends StatelessWidget {
  const AppSlider({
    required this.value,
    required this.onChanged,
    super.key,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
    this.helper,
    this.valueFormatter,
    this.showValue = true,
    this.onChangeEnd,
    this.validator,
    this.errorText,
    this.enabled = true,
  });

  final double value;

  /// Null disables the slider.
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final String? helper;

  /// Text for a value; defaults to the locale-aware decimal format.
  final String Function(double value)? valueFormatter;
  final bool showValue;
  final FormFieldValidator<double>? validator;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onChanged != null;
    String fmt(double v) => (valueFormatter ?? (x) => _format(context, x))(v);
    return AppFormField<double>(
      value: value,
      label: label,
      helper: helper,
      enabled: active,
      validator: validator,
      forceErrorText: errorText,
      builder: (state) => _SliderRow(
        valueText: showValue ? fmt(value) : null,
        slider: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          label: fmt(value),
          semanticFormatterCallback: fmt,
          onChanged: active
              ? (v) {
                  state.didChange(v);
                  onChanged!(v);
                }
              : null,
          onChangeEnd: active ? onChangeEnd : null,
        ),
      ),
    );
  }
}

/// Two-thumb slider for a range, with the range shown at the end of the row.
/// Controlled: pass [values] and update them in [onChanged].
class AppRangeSlider extends StatelessWidget {
  const AppRangeSlider({
    required this.values,
    required this.onChanged,
    super.key,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
    this.helper,
    this.valueFormatter,
    this.showValue = true,
    this.onChangeEnd,
    this.validator,
    this.errorText,
    this.enabled = true,
  });

  final RangeValues values;

  /// Null disables the slider.
  final ValueChanged<RangeValues>? onChanged;
  final ValueChanged<RangeValues>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final String? helper;
  final String Function(double value)? valueFormatter;
  final bool showValue;
  final FormFieldValidator<RangeValues>? validator;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = enabled && onChanged != null;
    String fmt(double v) => (valueFormatter ?? (x) => _format(context, x))(v);
    return AppFormField<RangeValues>(
      value: values,
      label: label,
      helper: helper,
      enabled: active,
      validator: validator,
      forceErrorText: errorText,
      builder: (state) => _SliderRow(
        valueText: showValue
            ? '${fmt(values.start)} - ${fmt(values.end)}'
            : null,
        slider: RangeSlider(
          values: RangeValues(
            values.start.clamp(min, max),
            values.end.clamp(min, max),
          ),
          min: min,
          max: max,
          divisions: divisions,
          labels: RangeLabels(fmt(values.start), fmt(values.end)),
          semanticFormatterCallback: fmt,
          onChanged: active
              ? (v) {
                  state.didChange(v);
                  onChanged!(v);
                }
              : null,
          onChangeEnd: active ? onChangeEnd : null,
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({required this.slider, required this.valueText});

  final Widget slider;
  final String? valueText;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: tokens.sizes.minTouchTarget),
      child: Row(
        children: [
          Expanded(child: slider),
          if (valueText != null) ...[
            SizedBox(width: tokens.spacing.sm),
            Flexible(
              child: ExcludeSemantics(
                child: Text(
                  valueText!,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
