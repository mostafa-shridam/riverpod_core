import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';

/// Wraps any control with a label above and a helper or error line below,
/// and plugs it into a `Form` (validate, save, reset) as a [FormField].
///
/// Controlled: the control shows [value]; call `state.didChange(next)` from
/// the control (the selection widgets do this for you) and keep [value] in
/// your own state. An external change of [value] updates the validated
/// value too.
class AppFormField<T> extends FormField<T> {
  AppFormField({
    required T? value,
    required Widget Function(FormFieldState<T> state) builder,
    super.key,
    this.label,
    this.helper,
    this.showMessages = true,
    super.validator,
    super.onSaved,
    super.enabled,
    super.forceErrorText,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
  }) : super(
         initialValue: value,
         builder: (state) {
           final field = state.widget as AppFormField<T>;
           return _AppFormFieldBody<T>(
             state: state,
             label: field.label,
             helper: field.helper,
             showMessages: field.showMessages,
             enabled: field.enabled,
             child: builder(state),
           );
         },
       );

  /// Shown above the control.
  final String? label;

  /// Shown below the control while there is no error.
  final String? helper;

  /// Set to false when the control draws its own helper/error text (for
  /// example inside an `InputDecorator`); it can read `state.errorText`.
  final bool showMessages;

  @override
  FormFieldState<T> createState() => _AppFormFieldState<T>();
}

class _AppFormFieldState<T> extends FormFieldState<T> {
  @override
  void didUpdateWidget(covariant AppFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Controlled: follow the parent's value without notifying the Form.
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }
}

class _AppFormFieldBody<T> extends StatelessWidget {
  const _AppFormFieldBody({
    required this.state,
    required this.child,
    required this.label,
    required this.helper,
    required this.showMessages,
    required this.enabled,
  });

  final FormFieldState<T> state;
  final Widget child;
  final String? label;
  final String? helper;
  final bool showMessages;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final error = state.errorText;
    final hasError = error != null;
    final messageStyle = theme.textTheme.bodySmall;

    Widget? message;
    if (showMessages && hasError) {
      message = Semantics(
        liveRegion: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(top: tokens.spacing.xxs),
              child: ExcludeSemantics(
                child: Icon(
                  Icons.error_outline_rounded,
                  size: tokens.sizes.iconSm,
                  color: scheme.error,
                ),
              ),
            ),
            SizedBox(width: tokens.spacing.xs),
            Expanded(
              child: Text(
                error,
                style: messageStyle?.copyWith(color: scheme.error),
              ),
            ),
          ],
        ),
      );
    } else if (showMessages && helper != null) {
      message = Text(
        helper!,
        style: messageStyle?.copyWith(color: scheme.onSurfaceVariant),
      );
    }

    final labelColor = !enabled
        ? scheme.onSurface.withValues(alpha: 0.38)
        : hasError
        ? scheme.error
        : scheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: EdgeInsetsDirectional.only(bottom: tokens.spacing.sm),
            child: Text(
              label!,
              style: theme.textTheme.labelLarge?.copyWith(color: labelColor),
            ),
          ),
        child,
        AnimatedSize(
          duration: tokens.durations.fast,
          alignment: AlignmentDirectional.topStart,
          child: message == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: EdgeInsetsDirectional.only(
                    top: tokens.spacing.xs,
                    start: tokens.spacing.xs,
                  ),
                  child: message,
                ),
        ),
      ],
    );
  }
}
