import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_form_field.dart';

/// Checkbox row with a tappable label (the whole row is the 48 dp target).
/// Controlled: pass [value] and update it in [onChanged]. Pass a
/// [validator] (for example "must accept") to use it inside a `Form`.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
    super.key,
    this.subtitle,
    this.validator,
    this.errorText,
    this.enabled = true,
  });

  final bool value;

  /// Null disables the checkbox.
  final ValueChanged<bool>? onChanged;
  final String label;
  final String? subtitle;
  final FormFieldValidator<bool>? validator;

  /// Server-side error shown below the row.
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final active = enabled && onChanged != null;
    return AppFormField<bool>(
      value: value,
      enabled: active,
      validator: validator,
      forceErrorText: errorText,
      builder: (state) {
        final hasError = state.hasError;
        return CheckboxListTile(
          value: value,
          onChanged: active
              ? (v) {
                  final next = v ?? false;
                  state.didChange(next);
                  onChanged!(next);
                }
              : null,
          title: Text(label),
          subtitle: subtitle == null ? null : Text(subtitle!),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsetsDirectional.symmetric(
            horizontal: tokens.spacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radius.md),
          ),
          side: hasError
              ? BorderSide(
                  color: scheme.error,
                  width: tokens.sizes.focusedOutlineWidth,
                )
              : null,
          isError: hasError,
        );
      },
    );
  }
}
