import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';

/// Visual style of an [AppCard].
enum AppCardVariant { filled, outlined, elevated }

/// Rounded content container. Tappable when [onTap] or [onLongPress] is set.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.filled,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.semanticLabel,
  });

  final Widget child;
  final AppCardVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Defaults to the `lg` spacing token on every side.
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius.lg),
      side: variant == AppCardVariant.outlined
          ? BorderSide(color: scheme.outlineVariant)
          : BorderSide.none,
    );
    final tappable = onTap != null || onLongPress != null;
    Widget content = Padding(
      padding: padding ?? EdgeInsets.all(tokens.spacing.lg),
      child: child,
    );
    if (tappable) {
      content = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        customBorder: shape,
        child: content,
      );
    }
    Widget card = Material(
      color: switch (variant) {
        AppCardVariant.filled => scheme.surfaceContainerHighest,
        AppCardVariant.outlined => scheme.surface,
        AppCardVariant.elevated => scheme.surfaceContainerLow,
      },
      elevation: variant == AppCardVariant.elevated
          ? tokens.elevation.low
          : tokens.elevation.none,
      shadowColor: scheme.shadow,
      surfaceTintColor: scheme.surfaceTint,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: content,
    );
    if (semanticLabel != null || tappable) {
      card = Semantics(
        container: true,
        button: tappable,
        label: semanticLabel,
        child: card,
      );
    }
    if (margin != null) card = Padding(padding: margin!, child: card);
    return card;
  }
}
