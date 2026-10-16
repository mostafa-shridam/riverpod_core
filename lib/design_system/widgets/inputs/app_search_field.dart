import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/design_system/widgets/inputs/inputs_strings.dart';

/// Search input. [onChanged] fires after typing pauses for the
/// `searchDebounce` token; clearing fires it at once.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  TextEditingController? _ownController;
  Timer? _debounce;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void dispose() {
    _debounce?.cancel();
    _ownController?.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final callback = widget.onChanged;
    if (callback == null) return;
    _debounce = Timer(context.tokens.durations.searchDebounce, () {
      if (mounted) callback(value);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(tokens.radius.full),
      borderSide: BorderSide.none,
    );

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, _) {
        return TextField(
          controller: _controller,
          autofocus: widget.autofocus,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: widget.hint ?? searchHintKey.tr(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: clearKey.tr(),
                    icon: const Icon(Icons.close),
                    onPressed: _clear,
                  ),
            filled: true,
            fillColor: scheme.surfaceContainerHighest,
            contentPadding: EdgeInsetsDirectional.symmetric(
              horizontal: tokens.spacing.lg,
              vertical: tokens.spacing.md,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
        );
      },
    );
  }
}
