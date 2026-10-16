import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';

/// Single list row: leading, title, subtitle, trailing. Rows are at least
/// 56 dp tall so touch targets stay above 48 dp at any text scale.
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.enabled = true,
    this.showChevron = false,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool enabled;

  /// Adds a chevron at the end (the icon mirrors itself in RTL). Ignored when [trailing]
  /// is set.
  final bool showChevron;

  static const double _minHeight = 56;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.radius.md),
    );
    final foreground = !enabled
        ? scheme.onSurface.withValues(alpha: 0.38)
        : selected
        ? scheme.onSecondaryContainer
        : scheme.onSurface;
    final end =
        trailing ?? (showChevron ? const Icon(Icons.chevron_right) : null);
    final interactive = enabled && (onTap != null || onLongPress != null);

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: _minHeight),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.sm,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              IconTheme.merge(
                data: IconThemeData(color: foreground),
                child: leading!,
              ),
              SizedBox(width: tokens.spacing.lg),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle.merge(
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: foreground,
                    ),
                    child: title,
                  ),
                  if (subtitle != null)
                    DefaultTextStyle.merge(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: enabled ? scheme.onSurfaceVariant : foreground,
                      ),
                      child: subtitle!,
                    ),
                ],
              ),
            ),
            if (end != null) ...[
              SizedBox(width: tokens.spacing.md),
              IconTheme.merge(
                data: IconThemeData(color: scheme.onSurfaceVariant),
                child: end,
              ),
            ],
          ],
        ),
      ),
    );

    return Semantics(
      container: true,
      button: interactive,
      enabled: enabled,
      selected: selected,
      child: Material(
        color: selected ? scheme.secondaryContainer : Colors.transparent,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          onLongPress: enabled ? onLongPress : null,
          customBorder: shape,
          child: row,
        ),
      ),
    );
  }
}
