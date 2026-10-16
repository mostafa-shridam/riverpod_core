import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:riverpod_core/design_system/widgets/inputs/app_text_field.dart';

/// Phone input that accepts digits only. No country picker: the app adds
/// the country code itself.
class AppPhoneField extends StatelessWidget {
  const AppPhoneField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helper,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.maxLength,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helper;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      label: label,
      hint: hint,
      helper: helper,
      errorText: errorText,
      validator: validator,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      maxLength: maxLength,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      prefixIcon: const Icon(Icons.phone_outlined),
    );
  }
}
