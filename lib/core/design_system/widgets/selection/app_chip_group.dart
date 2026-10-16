import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_chip.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_form_field.dart';

/// One choice of an [AppChipGroup].
@immutable
class AppChipOption<T> {
  const AppChipOption({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final IconData? icon;
  final bool enabled;
}

/// Wrapping group of filter chips, single or multi select. Controlled: pass
/// [selected] and update it in [onChanged] (the list of selected values, in
/// option order). Single select replaces the choice; tapping it again clears
/// it when [allowDeselect].
class AppChipGroup<T> extends StatelessWidget {
  const AppChipGroup({
    required this.options,
    required this.selected,
    required this.onChanged,
    super.key,
    this.multiSelect = false,
    this.allowDeselect = true,
    this.label,
    this.helper,
    this.validator,
    this.errorText,
    this.enabled = true,
  });

  final List<AppChipOption<T>> options;
  final List<T> selected;

  /// Null disables the group.
  final ValueChanged<List<T>>? onChanged;
  final bool multiSelect;
  final bool allowDeselect;
  final String? label;
  final String? helper;
  final FormFieldValidator<List<T>>? validator;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final active = enabled && onChanged != null;
    return AppFormField<List<T>>(
      value: selected,
      label: label,
      helper: helper,
      enabled: active,
      validator: validator,
      forceErrorText: errorText,
      builder: (state) {
        void toggle(T value) {
          final isOn = selected.contains(value);
          final List<T> next;
          if (multiSelect) {
            next = [
              for (final o in options)
                if (o.value == value ? !isOn : selected.contains(o.value))
                  o.value,
            ];
          } else if (isOn) {
            if (!allowDeselect) return;
            next = <T>[];
          } else {
            next = [value];
          }
          state.didChange(next);
          onChanged!(next);
        }

        return Wrap(
          spacing: tokens.spacing.sm,
          runSpacing: tokens.spacing.xs,
          children: [
            for (final o in options)
              AppChip(
                label: o.label,
                icon: o.icon,
                tone: AppChipTone.primary,
                selected: selected.contains(o.value),
                onSelected: active && o.enabled ? (_) => toggle(o.value) : null,
              ),
          ],
        );
      },
    );
  }
}
