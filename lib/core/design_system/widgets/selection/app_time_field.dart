import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/widgets/selection/app_picker_field.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Time field that opens the platform time picker and shows the time in the
/// active locale and the device's 12/24-hour setting.
/// Controlled: pass [value] and update it in [onChanged].
class AppTimeField extends StatelessWidget {
  const AppTimeField({
    required this.value,
    required this.onChanged,
    super.key,
    this.initialTime = const TimeOfDay(hour: 9, minute: 0),
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.validator,
    this.pickerHelp,
    this.enabled = true,
  });

  final TimeOfDay? value;

  /// Null disables the field.
  final ValueChanged<TimeOfDay>? onChanged;

  /// Time the picker opens on when [value] is null.
  final TimeOfDay initialTime;
  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final FormFieldValidator<TimeOfDay>? validator;

  /// Title of the picker dialog; defaults to the localized "Select time".
  final String? pickerHelp;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final current = value;
    return AppPickerField<TimeOfDay>(
      value: current,
      displayText: current == null
          ? null
          : MaterialLocalizations.of(context).formatTimeOfDay(
              current,
              alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(
                context,
              ),
            ),
      label: label,
      hint: hint ?? LocaleKeys.ds_selection_selectTime.tr(),
      helper: helper,
      errorText: errorText,
      validator: validator,
      enabled: enabled,
      leadingIcon: Icons.schedule_rounded,
      trailingIcon: Icons.arrow_drop_down_rounded,
      onChanged: onChanged,
      onPick: onChanged == null
          ? null
          : () => showTimePicker(
              context: context,
              initialTime: value ?? initialTime,
              helpText: pickerHelp ?? LocaleKeys.ds_selection_selectTime.tr(),
            ),
    );
  }
}
