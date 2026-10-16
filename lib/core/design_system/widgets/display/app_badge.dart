import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';

/// Count or dot badge. With a [child] it is anchored to the child's
/// top-end corner; without one it is a standalone pill.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    this.count,
    this.child,
    this.maxCount = 99,
    this.showZero = false,
    this.formatter,
    this.semanticLabel,
  }) : dot = false;

  /// A small dot without a number (unread marker).
  const AppBadge.dot({super.key, this.child, this.semanticLabel})
    : count = null,
      maxCount = 99,
      showZero = false,
      formatter = null,
      dot = true;

  final int? count;
  final Widget? child;
  final bool dot;

  /// Counts above this show as `maxCount+` (for example `99+`).
  final int maxCount;
  final bool showZero;

  /// Number formatting hook, for locale digits. Defaults to `toString()`.
  final String Function(int value)? formatter;
  final String? semanticLabel;

  /// The text shown for [count], with overflow applied.
  String labelFor(int count) {
    String format(int v) => formatter?.call(v) ?? '$v';
    return count > maxCount ? '${format(maxCount)}+' : format(count);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final visible = dot || (count != null && (count! > 0 || showZero));
    final label = dot || count == null ? null : labelFor(count!);

    final badge = Badge(
      isLabelVisible: visible,
      smallSize: tokens.spacing.md,
      largeSize: tokens.spacing.lg + tokens.spacing.xxs,
      backgroundColor: scheme.error,
      textColor: scheme.onError,
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing.xs),
      label: label == null ? null : Text(label),
      child: child,
    );
    return Semantics(
      label: semanticLabel ?? label,
      excludeSemantics: semanticLabel != null,
      child: badge,
    );
  }
}
