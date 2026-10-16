import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_form_field.dart';

/// Tappable field that looks like `AppTextField` (filled, rounded, floating
/// label, same focus/error/disabled states) but opens a picker instead of a
/// keyboard. Building block of `AppDropdown`, `AppDateField`, `AppTimeField`.
class AppPickerField<T> extends StatefulWidget {
  const AppPickerField({
    required this.value,
    required this.displayText,
    required this.onPick,
    required this.onChanged,
    required this.trailingIcon,
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.validator,
    this.enabled = true,
    this.leadingIcon,
    this.onSaved,
  });

  final T? value;

  /// Text shown for [value]; null means "nothing picked yet".
  final String? displayText;

  /// Opens the picker; null result (dismissed) changes nothing. Null
  /// callback disables the field.
  final Future<T?> Function()? onPick;
  final ValueChanged<T>? onChanged;
  final IconData trailingIcon;
  final IconData? leadingIcon;
  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final FormFieldValidator<T>? validator;
  final FormFieldSetter<T>? onSaved;
  final bool enabled;

  @override
  State<AppPickerField<T>> createState() => _AppPickerFieldState<T>();
}

class _AppPickerFieldState<T> extends State<AppPickerField<T>> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final active = widget.enabled && widget.onPick != null;
    final radius = BorderRadius.circular(tokens.radius.md);

    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );

    return AppFormField<T>(
      value: widget.value,
      enabled: active,
      showMessages: false,
      validator: widget.validator,
      onSaved: widget.onSaved,
      forceErrorText: widget.errorText,
      builder: (state) {
        Future<void> open() async {
          final picked = await widget.onPick!();
          if (picked == null || !mounted) return;
          state.didChange(picked);
          widget.onChanged?.call(picked);
        }

        final text = widget.displayText;
        final hasLabel = widget.label != null;
        final iconColor = active
            ? scheme.onSurfaceVariant
            : scheme.onSurface.withValues(alpha: 0.38);
        return Semantics(
          button: true,
          enabled: active,
          focusable: active,
          label: widget.label,
          value: text ?? widget.hint,
          onTap: active ? open : null,
          excludeSemantics: true,
          child: InkWell(
            borderRadius: radius,
            onTap: active ? open : null,
            onFocusChange: (f) => setState(() => _focused = f),
            child: InputDecorator(
              isEmpty: text == null,
              isFocused: _focused,
              expands: false,
              decoration: InputDecoration(
                enabled: active,
                labelText: widget.label,
                hintText: hasLabel ? widget.hint : null,
                helperText: widget.helper,
                errorText: state.errorText,
                prefixIcon: widget.leadingIcon == null
                    ? null
                    : Icon(widget.leadingIcon, color: iconColor),
                suffixIcon: Icon(widget.trailingIcon, color: iconColor),
                filled: true,
                fillColor: scheme.surfaceContainerHighest,
                contentPadding: EdgeInsetsDirectional.symmetric(
                  horizontal: tokens.spacing.lg,
                  vertical: tokens.spacing.md,
                ),
                constraints: BoxConstraints(
                  minHeight: tokens.sizes.minTouchTarget,
                ),
                border: border(scheme.outline, tokens.sizes.outlineWidth),
                enabledBorder: border(
                  scheme.outlineVariant,
                  tokens.sizes.outlineWidth,
                ),
                disabledBorder: border(
                  scheme.outlineVariant,
                  tokens.sizes.outlineWidth,
                ),
                focusedBorder: border(
                  scheme.primary,
                  tokens.sizes.focusedOutlineWidth,
                ),
                errorBorder: border(scheme.error, tokens.sizes.outlineWidth),
                focusedErrorBorder: border(
                  scheme.error,
                  tokens.sizes.focusedOutlineWidth,
                ),
              ),
              child: text != null
                  ? Text(
                      text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: active
                            ? scheme.onSurface
                            : scheme.onSurface.withValues(alpha: 0.38),
                      ),
                    )
                  : (!hasLabel && widget.hint != null
                        ? Text(
                            widget.hint!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          )
                        : const SizedBox.shrink()),
            ),
          ),
        );
      },
    );
  }
}
