import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Visual weight. Use one [primary] per screen; [destructive] only for
/// irreversible actions.
enum AppButtonVariant { primary, secondary, tonal, outlined, text, destructive }

/// Height steps. The tap target stays at least 48 dp for every size.
enum AppButtonSize { sm, md, lg }

/// The one button used by features. Wraps M3 buttons with design tokens.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = false,
    this.loadingLabel,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;

  /// Shown before the label; mirrors to the end side in RTL.
  final IconData? icon;

  /// Shown after the label; mirrors to the start side in RTL.
  final IconData? trailingIcon;

  /// Keeps the label width, shows a spinner and blocks taps.
  final bool isLoading;
  final bool fullWidth;

  /// Spinner accessibility label. Defaults to `ds_buttons.loading`.
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final sizes = tokens.sizes;
    final spacing = tokens.spacing;
    final scheme = Theme.of(context).colorScheme;
    final colors = _ButtonColors.of(variant, scheme);
    final iconSize = switch (size) {
      AppButtonSize.sm => sizes.iconSm,
      AppButtonSize.md => sizes.iconMd,
      AppButtonSize.lg => sizes.iconLg,
    };
    final height = switch (size) {
      AppButtonSize.sm => sizes.buttonHeightSm,
      AppButtonSize.md => sizes.buttonHeightMd,
      AppButtonSize.lg => sizes.buttonHeightLg,
    };
    final horizontalPadding = switch (size) {
      AppButtonSize.sm => spacing.md,
      AppButtonSize.md => spacing.lg,
      AppButtonSize.lg => spacing.xl,
    };

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize),
          SizedBox(width: spacing.sm),
        ],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
        if (trailingIcon != null) ...[
          SizedBox(width: spacing.sm),
          Icon(trailingIcon, size: iconSize),
        ],
      ],
    );

    // Visibility keeps the label's size while loading, so the width stays.
    final body = Stack(
      alignment: Alignment.center,
      children: [
        Visibility(
          visible: !isLoading,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: content,
        ),
        if (isLoading)
          Semantics(
            label: loadingLabel ?? LocaleKeys.ds_buttons_loading.tr(),
            child: SizedBox.square(
              dimension: iconSize,
              child: CircularProgressIndicator(
                strokeWidth: sizes.spinnerStroke,
                color: colors.foreground,
              ),
            ),
          ),
      ],
    );

    // Null colors fall back to the M3 disabled colors of the button type.
    WidgetStateProperty<Color?>? resolve(Color? color) => color == null
        ? null
        : WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled) ? null : color,
          );

    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(0, height)),
      padding: WidgetStatePropertyAll(
        EdgeInsetsDirectional.symmetric(horizontal: horizontalPadding),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radius.full),
        ),
      ),
      textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.labelLarge),
      backgroundColor: resolve(colors.background),
      foregroundColor: resolve(colors.foreground),
      side: colors.border == null
          ? null
          : WidgetStatePropertyAll(
              BorderSide(color: colors.border!, width: sizes.outlineWidth),
            ),
    );

    final VoidCallback? handler = onPressed != null && !isLoading
        ? onPressed
        : null;
    final button = switch (variant) {
      AppButtonVariant.outlined => OutlinedButton(
        style: style,
        onPressed: handler,
        child: body,
      ),
      AppButtonVariant.text => TextButton(
        style: style,
        onPressed: handler,
        child: body,
      ),
      _ => FilledButton(style: style, onPressed: handler, child: body),
    };

    final sized = fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
    return sized;
  }
}

class _ButtonColors {
  const _ButtonColors({this.background, required this.foreground, this.border});

  factory _ButtonColors.of(AppButtonVariant variant, ColorScheme scheme) {
    return switch (variant) {
      AppButtonVariant.primary => _ButtonColors(
        background: scheme.primary,
        foreground: scheme.onPrimary,
      ),
      AppButtonVariant.secondary => _ButtonColors(
        background: scheme.secondary,
        foreground: scheme.onSecondary,
      ),
      AppButtonVariant.tonal => _ButtonColors(
        background: scheme.secondaryContainer,
        foreground: scheme.onSecondaryContainer,
      ),
      AppButtonVariant.outlined => _ButtonColors(
        foreground: scheme.primary,
        border: scheme.outline,
      ),
      AppButtonVariant.text => _ButtonColors(foreground: scheme.primary),
      AppButtonVariant.destructive => _ButtonColors(
        background: scheme.error,
        foreground: scheme.onError,
      ),
    };
  }

  final Color? background;
  final Color foreground;
  final Color? border;
}
