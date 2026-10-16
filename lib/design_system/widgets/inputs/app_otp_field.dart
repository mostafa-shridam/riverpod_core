import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:riverpod_core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/design_system/widgets/inputs/inputs_strings.dart';

/// One-time-code input: [length] boxes, one hidden text field.
///
/// Typing fills the next box (auto-advance). Pasting keeps only digits and
/// the first [length] of them. Digits always read left to right, so the
/// boxes are laid out LTR even in RTL apps: a deliberate exception to the
/// layout rule (see the C-09 report).
class AppOtpField extends StatefulWidget {
  const AppOtpField({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
  }) : assert(length > 0);

  /// Number of boxes.
  final int length;

  /// Called with the digits typed so far.
  final ValueChanged<String>? onChanged;

  /// Called once when the last box is filled.
  final ValueChanged<String>? onCompleted;

  /// Shown below the boxes in the error color.
  final String? errorText;
  final bool enabled;
  final bool autofocus;

  @override
  State<AppOtpField> createState() => _AppOtpFieldState();
}

class _AppOtpFieldState extends State<AppOtpField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  void _onChanged(String value) {
    setState(() {});
    widget.onChanged?.call(value);
    if (value.length == widget.length) widget.onCompleted?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final text = _controller.text;
    // The box that receives the next digit; the last one when full.
    final active = text.length < widget.length
        ? text.length
        : widget.length - 1;

    final boxes = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.length; i++) ...[
          if (i > 0) SizedBox(width: tokens.spacing.sm),
          _OtpBox(
            digit: i < text.length ? text[i] : '',
            semanticsLabel: otpDigitLabelKey.tr(
              args: ['${i + 1}', '${widget.length}'],
            ),
            highlighted: _focusNode.hasFocus && i == active,
            hasError: widget.errorText != null,
            color: scheme.primary,
            idleColor: scheme.outline,
            errorColor: scheme.error,
          ),
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              boxes,
              // Sits above the boxes so taps on them reach the text field.
              Positioned.fill(
                child: Opacity(
                  opacity: 0,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    autofocus: widget.autofocus,
                    showCursor: false,
                    enableInteractiveSelection: false,
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(widget.length),
                    ],
                    onChanged: _onChanged,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: EdgeInsetsDirectional.only(top: tokens.spacing.sm),
            child: Text(
              widget.errorText!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ),
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.digit,
    required this.semanticsLabel,
    required this.highlighted,
    required this.hasError,
    required this.color,
    required this.idleColor,
    required this.errorColor,
  });

  final String digit;
  final String semanticsLabel;
  final bool highlighted;
  final bool hasError;
  final Color color;
  final Color idleColor;
  final Color errorColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final sizes = tokens.sizes;
    final borderColor = hasError
        ? errorColor
        : highlighted
        ? color
        : idleColor;
    return Semantics(
      label: semanticsLabel,
      value: digit,
      excludeSemantics: true,
      child: Container(
        width: sizes.otpBoxWidth,
        height: sizes.otpBoxHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tokens.radius.md),
          border: Border.all(
            color: borderColor,
            width: highlighted || hasError
                ? sizes.focusedOutlineWidth
                : sizes.outlineWidth,
          ),
        ),
        child: Text(digit, style: Theme.of(context).textTheme.headlineSmall),
      ),
    );
  }
}
