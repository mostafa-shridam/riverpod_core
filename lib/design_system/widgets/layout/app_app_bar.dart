import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/theme/theme_context.dart';

/// Standard top bar. The back button appears on its own when the route can
/// pop and mirrors in RTL. Scrolled-under content gets a surface tint, not a
/// shadow.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.bottom,
    this.centerTitle = false,
    this.automaticallyImplyLeading = true,
  }) : assert(
         title == null || titleWidget == null,
         'Pass either title or titleWidget',
       );

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;

  /// For example an `AppTabBar`.
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return AppBar(
      title: titleWidget ?? (title == null ? null : Text(title!)),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
      bottom: bottom,
      centerTitle: centerTitle,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: scheme.surfaceTint,
      elevation: tokens.elevation.none,
      scrolledUnderElevation: tokens.elevation.low,
    );
  }
}
