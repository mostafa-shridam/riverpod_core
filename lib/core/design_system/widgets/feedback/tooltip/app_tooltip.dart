import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';

/// Themed tooltip: inverse surface, rounded `sm`, long-press on touch and
/// hover on pointers. [message] must already be localized by the caller.
class AppTooltip extends StatelessWidget {
  const AppTooltip({
    required this.message,
    required this.child,
    super.key,
    this.preferBelow = true,
    this.triggerMode = TooltipTriggerMode.longPress,
  });

  final String message;
  final Widget child;
  final bool preferBelow;
  final TooltipTriggerMode triggerMode;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      triggerMode: triggerMode,
      waitDuration: tokens.durations.slow,
      showDuration: tokens.durations.slow * 8,
      constraints: BoxConstraints(maxWidth: tokens.spacing.xxxl * 6),
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: tokens.spacing.md,
        vertical: tokens.spacing.sm,
      ),
      margin: EdgeInsetsDirectional.all(tokens.spacing.sm),
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(tokens.radius.sm),
      ),
      textStyle: theme.textTheme.bodySmall?.copyWith(
        color: scheme.onInverseSurface,
      ),
      child: child,
    );
  }
}
