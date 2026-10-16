import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/theme/theme_context.dart';

/// Which sides of a horizontal [AppDivider] are inset by the `lg` token.
enum AppDividerInset { none, start, both }

/// Hairline divider. Horizontal by default, optionally with a centered
/// [label]; [AppDivider.vertical] for rows.
class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.inset = AppDividerInset.none, this.label})
    : vertical = false;

  const AppDivider.vertical({super.key})
    : vertical = true,
      inset = AppDividerInset.none,
      label = null;

  final bool vertical;
  final AppDividerInset inset;

  /// Short text shown in the middle of the line, such as "or".
  final String? label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    if (vertical) {
      return VerticalDivider(
        width: tokens.spacing.lg,
        thickness: 1,
        color: scheme.outlineVariant,
      );
    }
    final start = inset == AppDividerInset.none ? 0.0 : tokens.spacing.lg;
    final end = inset == AppDividerInset.both ? tokens.spacing.lg : 0.0;
    final line = Divider(
      height: tokens.spacing.lg,
      thickness: 1,
      color: scheme.outlineVariant,
    );
    return Padding(
      padding: EdgeInsetsDirectional.only(start: start, end: end),
      child: label == null
          ? line
          : Row(
              children: [
                Expanded(child: line),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: tokens.spacing.md),
                  child: Text(
                    label!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(child: line),
              ],
            ),
    );
  }
}
