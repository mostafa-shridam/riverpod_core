import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/widgets/selection/app_picker_field.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Date field that opens the platform date picker and shows the date in the
/// active locale (digits and month names follow ar/en).
/// Controlled: pass [value] (date only) and update it in [onChanged].
class AppDateField extends StatelessWidget {
  const AppDateField({
    required this.value,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    super.key,
    this.initialDate,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.validator,
    this.pickerHelp,
    this.enabled = true,
  });

  final DateTime? value;

  /// Null disables the field.
  final ValueChanged<DateTime>? onChanged;
  final DateTime firstDate;
  final DateTime lastDate;

  /// Date the picker opens on when [value] is null; defaults to today
  /// clamped into the range.
  final DateTime? initialDate;
  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final FormFieldValidator<DateTime>? validator;

  /// Title of the picker dialog; defaults to the localized "Select date".
  final String? pickerHelp;
  final bool enabled;

  DateTime _opening() {
    final base = value ?? initialDate ?? DateTime.now();
    final day = DateUtils.dateOnly(base);
    if (day.isBefore(firstDate)) return firstDate;
    if (day.isAfter(lastDate)) return lastDate;
    return day;
  }

  @override
  Widget build(BuildContext context) {
    final current = value;
    return AppPickerField<DateTime>(
      value: current,
      displayText: current == null
          ? null
          : MaterialLocalizations.of(context).formatMediumDate(current),
      label: label,
      hint: hint ?? LocaleKeys.ds_selection_selectDate.tr(),
      helper: helper,
      errorText: errorText,
      validator: validator,
      enabled: enabled,
      leadingIcon: Icons.calendar_today_rounded,
      trailingIcon: Icons.arrow_drop_down_rounded,
      onChanged: onChanged,
      onPick: onChanged == null
          ? null
          : () => showDatePicker(
              context: context,
              initialDate: _opening(),
              firstDate: firstDate,
              lastDate: lastDate,
              helpText: pickerHelp ?? LocaleKeys.ds_selection_selectDate.tr(),
            ),
    );
  }
}
