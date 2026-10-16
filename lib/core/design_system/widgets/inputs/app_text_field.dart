import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';

/// The one text input used by features. Filled, rounded, with the M3
/// states (focus, error, disabled). Use `localizedValidator` for messages.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.obscureText = false,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helper;

  /// Shown below the field; use it for server errors. Validator errors
  /// show up on their own.
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final bool obscureText;

  /// Shows the built-in counter when set.
  final int? maxLength;

  /// Pass `maxLines: null` or a value above 1 for a multiline field.
  final int? minLines;
  final int? maxLines;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(tokens.radius.md);

    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: color, width: width),
    );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: obscureText ? 1 : maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      autofocus: autofocus,
      textAlign: TextAlign.start,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefixText: prefixText,
        suffixText: suffixText,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding: EdgeInsetsDirectional.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.md,
        ),
        border: border(scheme.outline, tokens.sizes.outlineWidth),
        enabledBorder: border(scheme.outlineVariant, tokens.sizes.outlineWidth),
        disabledBorder: border(
          scheme.outlineVariant,
          tokens.sizes.outlineWidth,
        ),
        focusedBorder: border(scheme.primary, tokens.sizes.focusedOutlineWidth),
        errorBorder: border(scheme.error, tokens.sizes.outlineWidth),
        focusedErrorBorder: border(
          scheme.error,
          tokens.sizes.focusedOutlineWidth,
        ),
      ),
    );
  }
}
