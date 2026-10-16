import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_app_bar.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_bottom_nav_bar.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_scaffold.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_stepper.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_tab_bar.dart';

import '../display/ds_test_harness.dart';

const _destinations = [
  AppNavDestination(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  AppNavDestination(label: 'Search', icon: Icons.search, badgeCount: 3),
  AppNavDestination(label: 'Profile', icon: Icons.person_outline),
];

const _steps = [
  AppStep(
    title: 'Account',
    subtitle: 'Your details',
    content: Text('Step content goes here.'),
  ),
  AppStep(title: 'Address', content: Text('Second content.')),
  AppStep(title: 'Confirm'),
];

Widget _page({required bool withTabs}) => DefaultTabController(
  length: 3,
  child: AppScaffold(
    appBar: AppAppBar(
      title: 'Overview',
      actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      bottom: withTabs
          ? const AppTabBar(
              tabs: [
                AppTabItem(label: 'Alpha'),
                AppTabItem(label: 'Beta', badgeCount: 4),
                AppTabItem(label: 'Gamma'),
              ],
            )
          : null,
    ),
    banner: Builder(
      builder: (context) => Container(
        padding: const EdgeInsetsDirectional.all(8),
        color: Theme.of(context).colorScheme.tertiaryContainer,
        child: Text(
          'Banner slot',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onTertiaryContainer,
          ),
        ),
      ),
    ),
    navigationBar: AppBottomNavBar(
      destinations: _destinations,
      selectedIndex: 1,
      onSelected: (_) {},
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {},
      child: const Icon(Icons.add),
    ),
    body: const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 16),
          AppStepper(steps: _steps, currentStep: 1),
          SizedBox(height: 24),
          AppStepper(steps: _steps, currentStep: 1, axis: Axis.horizontal),
        ],
      ),
    ),
  ),
);

void main() {
  for (final scale in [1.0, 2.0]) {
    for (final mode in goldenModes) {
      testWidgets('layout phone ${mode.name} x$scale', (tester) async {
        await pumpDs(
          tester,
          _page(withTabs: true),
          scaffold: false,
          locale: mode.locale,
          dark: mode.dark,
          textScale: scale,
          size: const Size(400, 800),
        );
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(AppScaffold),
          matchesGoldenFile(
            '../../../../goldens/display/layout_phone_${mode.name}_x${scale.toInt()}.png',
          ),
        );
      });
    }
  }

  for (final mode in goldenModes) {
    testWidgets('layout tablet rail ${mode.name}', (tester) async {
      await pumpDs(
        tester,
        _page(withTabs: false),
        scaffold: false,
        locale: mode.locale,
        dark: mode.dark,
        size: const Size(800, 700),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(NavigationRail), findsOneWidget);
      await expectLater(
        find.byType(AppScaffold),
        matchesGoldenFile(
          '../../../../goldens/display/layout_tablet_${mode.name}.png',
        ),
      );
    });
  }
}
