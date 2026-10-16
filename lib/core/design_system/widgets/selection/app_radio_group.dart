import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_form_field.dart';

/// One choice of an [AppRadioGroup].
@immutable
class AppRadioOption<T> {
  const AppRadioOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? subtitle;
  final bool enabled;
}

/// Vertical list of mutually exclusive choices with an optional group
/// [label]. Controlled: pass [value] and update it in [onChanged].
class AppRadioGroup<T> extends StatelessWidget {
  const AppRadioGroup({
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
    this.label,
    this.helper,
    this.validator,
    this.errorText,
    this.enabled = true,
  });

  final List<AppRadioOption<T>> options;
  final T? value;

  /// Null disables the whole group.
  final ValueChanged<T>? onChanged;
  final String? label;
  final String? helper;
  final FormFieldValidator<T>? validator;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final active = enabled && onChanged != null;
    return AppFormField<T>(
      value: value,
      label: label,
      helper: helper,
      enabled: active,
      validator: validator,
      forceErrorText: errorText,
      builder: (state) => Semantics(
        container: true,
        explicitChildNodes: true,
        child: RadioGroup<T>(
          groupValue: value,
          onChanged: (v) {
            if (!active || v == null) return;
            state.didChange(v);
            onChanged!(v);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final option in options)
                RadioListTile<T>(
                  value: option.value,
                  enabled: active && option.enabled,
                  title: Text(option.label),
                  subtitle: option.subtitle == null
                      ? null
                      : Text(option.subtitle!),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsetsDirectional.symmetric(
                    horizontal: tokens.spacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radius.md),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
