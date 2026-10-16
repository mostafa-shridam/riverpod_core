import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_form_field.dart';

/// Switch row with a tappable label. Controlled: pass [value] and update it
/// in [onChanged]. The thumb shows a check when on, for non-color cues.
class AppSwitch extends StatelessWidget {
  const AppSwitch({
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

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;
  final String label;
  final String? subtitle;
  final FormFieldValidator<bool>? validator;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final active = enabled && onChanged != null;
    return AppFormField<bool>(
      value: value,
      enabled: active,
      validator: validator,
      forceErrorText: errorText,
      builder: (state) => SwitchListTile(
        value: value,
        onChanged: active
            ? (v) {
                state.didChange(v);
                onChanged!(v);
              }
            : null,
        title: Text(label),
        subtitle: subtitle == null ? null : Text(subtitle!),
        thumbIcon: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Icon(Icons.check_rounded, size: tokens.sizes.iconSm)
              : null,
        ),
        contentPadding: EdgeInsetsDirectional.symmetric(
          horizontal: tokens.spacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.md),
        ),
      ),
    );
  }
}
