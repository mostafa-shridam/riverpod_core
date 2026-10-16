import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';

/// Shared body of `EmptyState` and `ErrorState`: illustration, title,
/// message and an optional action, centered and width-limited.
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.illustration,
    required this.title,
    required this.message,
    this.action,
  });

  final Widget illustration;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final spacing = context.tokens.spacing;
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: spacing.xxxl * 8),
        child: Padding(
          padding: EdgeInsetsDirectional.all(spacing.xl),
          child: Semantics(
            container: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                illustration,
                SizedBox(height: spacing.xl),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (action != null) ...[SizedBox(height: spacing.xl), action!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
