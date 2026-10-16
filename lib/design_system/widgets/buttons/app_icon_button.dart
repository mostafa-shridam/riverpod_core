import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/design_system/widgets/buttons/app_button.dart';

/// Container style of an [AppIconButton].
enum AppIconButtonVariant { filled, tonal, outlined, standard }

/// Icon-only action. [tooltip] is required: it is the accessible name.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.variant = AppIconButtonVariant.standard,
    this.size = AppButtonSize.md,
    this.badge,
  });

  final IconData icon;
  final String tooltip;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final AppButtonSize size;

  /// Optional overlay (for example an `AppBadge`) at the top-end corner.
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final sizes = context.tokens.sizes;
    final dimension = switch (size) {
      AppButtonSize.sm => sizes.buttonHeightSm,
      AppButtonSize.md => sizes.buttonHeightMd,
      AppButtonSize.lg => sizes.buttonHeightLg,
    };
    final iconSize = switch (size) {
      AppButtonSize.sm => sizes.iconSm,
      AppButtonSize.md => sizes.iconMd,
      AppButtonSize.lg => sizes.iconLg,
    };
    final style = IconButton.styleFrom(
      minimumSize: Size.square(dimension),
      iconSize: iconSize,
    );
    final child = Icon(icon);

    final button = switch (variant) {
      AppIconButtonVariant.filled => IconButton.filled(
        style: style,
        tooltip: tooltip,
        onPressed: onPressed,
        icon: child,
      ),
      AppIconButtonVariant.tonal => IconButton.filledTonal(
        style: style,
        tooltip: tooltip,
        onPressed: onPressed,
        icon: child,
      ),
      AppIconButtonVariant.outlined => IconButton.outlined(
        style: style,
        tooltip: tooltip,
        onPressed: onPressed,
        icon: child,
      ),
      AppIconButtonVariant.standard => IconButton(
        style: style,
        tooltip: tooltip,
        onPressed: onPressed,
        icon: child,
      ),
    };

    if (badge == null) return button;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        PositionedDirectional(top: 0, end: 0, child: badge!),
      ],
    );
  }
}
