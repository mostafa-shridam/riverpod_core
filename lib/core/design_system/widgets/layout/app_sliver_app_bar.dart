import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';

/// Collapsing top bar for scroll views: a large title that shrinks into a
/// regular bar as the content scrolls (M3 large/medium app bar).
class AppSliverAppBar extends StatelessWidget {
  const AppSliverAppBar({
    super.key,
    required this.title,
    this.large = true,
    this.leading,
    this.actions,
    this.bottom,
    this.pinned = true,
    this.floating = false,
  });

  final String title;

  /// Large (default) or medium expanded height.
  final bool large;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool pinned;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final titleWidget = Text(title);
    final background = scheme.surface;
    final tint = scheme.surfaceTint;
    final scrolled = tokens.elevation.low;
    final none = tokens.elevation.none;
    return large
        ? SliverAppBar.large(
            title: titleWidget,
            leading: leading,
            actions: actions,
            bottom: bottom,
            pinned: pinned,
            floating: floating,
            backgroundColor: background,
            surfaceTintColor: tint,
            elevation: none,
            scrolledUnderElevation: scrolled,
          )
        : SliverAppBar.medium(
            title: titleWidget,
            leading: leading,
            actions: actions,
            bottom: bottom,
            pinned: pinned,
            floating: floating,
            backgroundColor: background,
            surfaceTintColor: tint,
            elevation: none,
            scrolledUnderElevation: scrolled,
          );
  }
}
