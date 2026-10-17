import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_core/features/app_gate/presentation/widgets/soft_update_banner.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Bottom navigation with one stack per branch (each tab keeps its own
/// history). Selecting the current tab again returns it to its first page.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The soft update notice sits above every tab (empty unless due).
      body: Column(
        children: [
          const SoftUpdateBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: LocaleKeys.app_nav_home.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            label: LocaleKeys.app_nav_more.tr(),
          ),
        ],
      ),
    );
  }
}
