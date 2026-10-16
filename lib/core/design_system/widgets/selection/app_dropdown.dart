import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/widgets/bottom_sheets/app_selection_sheet.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_picker_field.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Single choice field. Tapping opens an `AppSelectionSheet` (with a search
/// box when [searchable]); the chosen label is shown in the field.
/// Controlled: pass [value] and update it in [onChanged].
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.validator,
    this.searchable = false,
    this.sheetTitle,
    this.searchHint,
    this.noResultsLabel,
    this.enabled = true,
  });

  final List<AppSelectionOption<T>> options;
  final T? value;

  /// Null disables the field.
  final ValueChanged<T>? onChanged;
  final String? label;

  /// Placeholder; defaults to the localized "Select".
  final String? hint;
  final String? helper;
  final String? errorText;
  final FormFieldValidator<T>? validator;

  /// Adds a search box to the sheet (use for long lists).
  final bool searchable;

  /// Sheet title; defaults to [label].
  final String? sheetTitle;
  final String? searchHint;
  final String? noResultsLabel;
  final bool enabled;

  String? get _selectedLabel {
    for (final o in options) {
      if (o.value == value) return o.label;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AppPickerField<T>(
      value: value,
      displayText: _selectedLabel,
      label: label,
      hint: hint ?? LocaleKeys.ds_selection_select.tr(),
      helper: helper,
      errorText: errorText,
      validator: validator,
      enabled: enabled,
      trailingIcon: Icons.keyboard_arrow_down_rounded,
      onChanged: onChanged,
      onPick: onChanged == null
          ? null
          : () => AppSelectionSheet.showSingle<T>(
              context: context,
              options: options,
              title: sheetTitle ?? label,
              selected: value,
              searchable: searchable,
              searchHint: searchHint,
              noResultsLabel: noResultsLabel,
            ),
    );
  }
}
