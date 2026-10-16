import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_badge.dart';

/// One tab of an [AppTabBar].
class AppTabItem {
  const AppTabItem({required this.label, this.icon, this.badgeCount});

  final String label;
  final IconData? icon;

  /// Shows an `AppBadge` on the icon (or label when there is no icon).
  final int? badgeCount;
}

/// Look of the selected tab.
enum AppTabBarStyle { underline, pill }

/// Tab strip. Needs a [TabController] (or a surrounding `DefaultTabController`).
class AppTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.isScrollable = false,
    this.style = AppTabBarStyle.underline,
  });

  final List<AppTabItem> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;

  /// Scrollable tabs hug their labels; otherwise they share the width.
  final bool isScrollable;
  final AppTabBarStyle style;

  static const double _height = 48;
  static const double _heightWithIcon = 72;

  bool get _hasIcons => tabs.any((t) => t.icon != null);

  @override
  Size get preferredSize =>
      Size.fromHeight(_hasIcons ? _heightWithIcon : _height);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pill = style == AppTabBarStyle.pill;

    return TabBar(
      controller: controller,
      onTap: onTap,
      isScrollable: isScrollable,
      tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
      labelColor: pill ? scheme.onPrimaryContainer : scheme.primary,
      unselectedLabelColor: scheme.onSurfaceVariant,
      labelStyle: theme.textTheme.titleSmall,
      unselectedLabelStyle: theme.textTheme.titleSmall,
      dividerColor: pill ? Colors.transparent : scheme.outlineVariant,
      indicatorSize: pill ? TabBarIndicatorSize.tab : TabBarIndicatorSize.label,
      indicatorPadding: pill
          ? EdgeInsets.symmetric(vertical: tokens.spacing.xs)
          : EdgeInsets.zero,
      indicator: pill
          ? BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(tokens.radius.full),
            )
          : UnderlineTabIndicator(
              borderSide: BorderSide(
                color: scheme.primary,
                width: tokens.spacing.xs,
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(tokens.radius.sm),
              ),
            ),
      overlayColor: WidgetStatePropertyAll(
        scheme.primary.withValues(alpha: 0.08),
      ),
      splashBorderRadius: BorderRadius.circular(tokens.radius.full),
      tabs: [for (final t in tabs) _build(context, t)],
    );
  }

  Tab _build(BuildContext context, AppTabItem item) {
    final tokens = context.tokens;
    final icon = item.icon == null ? null : Icon(item.icon);
    Widget? anchored(Widget w) => item.badgeCount == null
        ? w
        : AppBadge(count: item.badgeCount, child: w);
    return Tab(
      text: icon != null || item.badgeCount == null ? item.label : null,
      icon: icon == null ? null : anchored(icon),
      child: icon == null && item.badgeCount != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(item.label)),
                SizedBox(width: tokens.spacing.xs),
                AppBadge(count: item.badgeCount),
              ],
            )
          : null,
    );
  }
}
