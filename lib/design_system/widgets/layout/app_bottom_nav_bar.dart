import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/responsive/breakpoints.dart';
import 'package:riverpod_core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/design_system/widgets/display/app_badge.dart';

/// One destination of an [AppBottomNavBar].
class AppNavDestination {
  const AppNavDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badgeCount,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;

  /// Shows an `AppBadge` on the icon; 0 or null hides it.
  final int? badgeCount;
}

/// Primary navigation. A bottom bar on phones; on tablets and desktops it
/// becomes a side rail at the start edge (labels below icons on tablets,
/// extended on desktops).
///
/// The rail needs the full height next to the content, so hand this widget to
/// `AppScaffold.navigationBar`, which places it. Outside `AppScaffold` on a
/// wide window it still renders as a rail and the caller must lay it out.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    this.railLeading,
  }) : assert(destinations.length >= 2 && destinations.length <= 5);

  final List<AppNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  /// Widget above the rail destinations (a logo or a FAB). Rail only.
  final Widget? railLeading;

  /// True when [AppScaffold] must lay this out as a side rail.
  static bool isRail(BuildContext context) =>
      context.breakpoint != AppBreakpoint.phone;

  Widget _icon(AppNavDestination d, {required bool selected}) {
    final icon = Icon(selected ? d.selectedIcon ?? d.icon : d.icon);
    final count = d.badgeCount;
    return count == null || count <= 0
        ? icon
        : AppBadge(count: count, child: icon);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final labelStyle = theme.textTheme.labelMedium;

    if (!isRail(context)) {
      return NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: scheme.surfaceTint,
        indicatorColor: scheme.secondaryContainer,
        elevation: tokens.elevation.low,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          for (final d in destinations)
            NavigationDestination(
              icon: _icon(d, selected: false),
              selectedIcon: _icon(d, selected: true),
              label: d.label,
              tooltip: d.label,
            ),
        ],
      );
    }

    final extended = context.breakpoint == AppBreakpoint.desktop;
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      extended: extended,
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      backgroundColor: scheme.surface,
      indicatorColor: scheme.secondaryContainer,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.full),
      ),
      selectedLabelTextStyle: labelStyle?.copyWith(color: scheme.onSurface),
      unselectedLabelTextStyle: labelStyle?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      leading: railLeading,
      groupAlignment: -1,
      destinations: [
        for (final d in destinations)
          NavigationRailDestination(
            icon: _icon(d, selected: false),
            selectedIcon: _icon(d, selected: true),
            label: Text(d.label),
            padding: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
          ),
      ],
    );
  }
}
