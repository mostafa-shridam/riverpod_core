import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/design_system/widgets/feedback/feedback_strings.dart';

/// Inline message with a status icon, optional action and dismiss button.
/// Lives inside the page flow (unlike a toast, which floats above it).
class AppBanner extends StatelessWidget {
  const AppBanner({
    required this.message,
    super.key,
    this.type = AppStatusType.info,
    this.title,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
    this.dismissLabel,
  });

  final String message;
  final AppStatusType type;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Shows a close button when set.
  final VoidCallback? onDismiss;

  /// Overrides the localized "dismiss" tooltip.
  final String? dismissLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final colors = type.colorsOf(context);
    final hasAction = actionLabel != null && onAction != null;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Material(
        color: colors.container,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            tokens.spacing.lg,
            tokens.spacing.md,
            onDismiss == null ? tokens.spacing.lg : tokens.spacing.xs,
            tokens.spacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(top: tokens.spacing.xxs),
                child: Icon(type.icon, color: colors.accent),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    vertical: tokens.spacing.xs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.onContainer,
                          ),
                        ),
                      Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onContainer,
                        ),
                      ),
                      if (hasAction)
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            top: tokens.spacing.xs,
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: colors.onContainer,
                              minimumSize: const Size(
                                0,
                                kMinInteractiveDimension,
                              ),
                              padding: EdgeInsetsDirectional.symmetric(
                                horizontal: tokens.spacing.sm,
                              ),
                            ),
                            onPressed: onAction,
                            child: Text(actionLabel!),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: Icon(Icons.close_rounded, color: colors.onContainer),
                  tooltip: dismissLabel ?? dismissKey.tr(),
                  onPressed: onDismiss,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
