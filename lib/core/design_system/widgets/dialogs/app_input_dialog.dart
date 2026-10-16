import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/widgets/dialogs/app_dialog.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Dialog with one text field and validation. Pops the entered text on
/// confirm (only when [validator] returns null), or null on cancel.
class AppInputDialog extends StatefulWidget {
  const AppInputDialog({
    required this.title,
    super.key,
    this.message,
    this.label,
    this.hint,
    this.initialValue,
    this.validator,
    this.keyboardType,
    this.maxLength,
    this.obscureText = false,
    this.confirmLabel,
    this.cancelLabel,
  });

  final String title;
  final String? message;
  final String? label;
  final String? hint;
  final String? initialValue;

  /// Returns a localized error text, or null when the value is valid.
  final String? Function(String value)? validator;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool obscureText;
  final String? confirmLabel;
  final String? cancelLabel;

  /// Opens the dialog; returns the text or null when cancelled.
  static Future<String?> show({
    required BuildContext context,
    required String title,
    String? message,
    String? label,
    String? hint,
    String? initialValue,
    String? Function(String value)? validator,
    TextInputType? keyboardType,
    int? maxLength,
    bool obscureText = false,
    String? confirmLabel,
    String? cancelLabel,
  }) {
    return showAppDialog<String>(
      context: context,
      builder: (_) => AppInputDialog(
        title: title,
        message: message,
        label: label,
        hint: hint,
        initialValue: initialValue,
        validator: validator,
        keyboardType: keyboardType,
        maxLength: maxLength,
        obscureText: obscureText,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      ),
    );
  }

  @override
  State<AppInputDialog> createState() => _AppInputDialogState();
}

class _AppInputDialogState extends State<AppInputDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    const minSize = Size(0, kMinInteractiveDimension);
    return AppDialogFrame(
      title: widget.title,
      message: widget.message,
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          obscureText: widget.obscureText,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          validator: widget.validator == null
              ? null
              : (v) => widget.validator!(v ?? ''),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
          ),
        ),
      ),
      primary: FilledButton(
        style: FilledButton.styleFrom(minimumSize: minSize),
        onPressed: _submit,
        child: Text(widget.confirmLabel ?? LocaleKeys.ds_overlays_confirm.tr()),
      ),
      secondary: TextButton(
        style: TextButton.styleFrom(minimumSize: minSize),
        onPressed: () => Navigator.of(context).pop(),
        child: Text(widget.cancelLabel ?? LocaleKeys.ds_overlays_cancel.tr()),
      ),
    );
  }
}
