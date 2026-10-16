import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_app_bar.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_bottom_nav_bar.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_scaffold.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_sliver_app_bar.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_stepper.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_tab_bar.dart';

import '../display/ds_test_harness.dart';

const _destinations = [
  AppNavDestination(label: 'Home', icon: Icons.home_outlined),
  AppNavDestination(label: 'Search', icon: Icons.search, badgeCount: 3),
  AppNavDestination(label: 'Profile', icon: Icons.person_outline),
];

AppBottomNavBar _nav({int index = 0, ValueChanged<int>? onSelected}) =>
    AppBottomNavBar(
      destinations: _destinations,
      selectedIndex: index,
      onSelected: onSelected ?? (_) {},
    );

void main() {
  group('AppAppBar', () {
    testWidgets('shows title and actions', (tester) async {
      await pumpDs(
        tester,
        const AppScaffold(
          appBar: AppAppBar(title: 'Inbox', actions: [Icon(Icons.search)]),
          body: SizedBox(),
        ),
        scaffold: false,
      );
      expect(find.text('Inbox'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('adds a back button only when the route can pop', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const AppScaffold(
          appBar: AppAppBar(title: 'Root'),
          body: SizedBox(),
        ),
        scaffold: false,
      );
      expect(find.byType(BackButton), findsNothing);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      unawaited(
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => const AppScaffold(
              appBar: AppAppBar(title: 'Detail'),
              body: SizedBox(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BackButton), findsOneWidget);
    });

    test('preferredSize includes the bottom widget', () {
      const bar = AppAppBar(
        title: 'x',
        bottom: AppTabBar(tabs: [AppTabItem(label: 'a')]),
      );
      expect(bar.preferredSize.height, kToolbarHeight + 48);
    });

    testWidgets('titleWidget replaces title', (tester) async {
      await pumpDs(
        tester,
        const AppScaffold(
          appBar: AppAppBar(titleWidget: Text('Custom')),
          body: SizedBox(),
        ),
        scaffold: false,
      );
      expect(find.text('Custom'), findsOneWidget);
    });
  });

  group('AppSliverAppBar', () {
    testWidgets('large bar collapses while scrolling', (tester) async {
      await pumpDs(
        tester,
        Scaffold(
          body: CustomScrollView(
            slivers: [
              const AppSliverAppBar(title: 'Library'),
              SliverList.builder(
                itemCount: 40,
                itemBuilder: (_, i) => SizedBox(height: 56, child: Text('$i')),
              ),
            ],
          ),
        ),
        scaffold: false,
      );
      final expanded = _sliverExtent(tester);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      final collapsed = _sliverExtent(tester);
      expect(collapsed, lessThan(expanded));
      expect(find.text('Library'), findsWidgets);
    });

    testWidgets('medium variant is shorter than large', (tester) async {
      Future<double> height({required bool large}) async {
        await pumpDs(
          tester,
          Scaffold(
            body: CustomScrollView(
              slivers: [AppSliverAppBar(title: 'T', large: large)],
            ),
          ),
          scaffold: false,
        );
        return _sliverExtent(tester);
      }

      expect(await height(large: false), lessThan(await height(large: true)));
    });
  });

  group('AppTabBar', () {
    Widget tabs({
      AppTabBarStyle style = AppTabBarStyle.underline,
      bool scrollable = false,
      ValueChanged<int>? onTap,
      List<AppTabItem>? items,
    }) => DefaultTabController(
      length: (items ?? _tabItems).length,
      child: Column(
        children: [
          AppTabBar(
            tabs: items ?? _tabItems,
            style: style,
            isScrollable: scrollable,
            onTap: onTap,
          ),
          const Expanded(
            child: TabBarView(
              children: [Text('page-a'), Text('page-b'), Text('page-c')],
            ),
          ),
        ],
      ),
    );

    testWidgets('tapping a tab switches the page', (tester) async {
      final taps = <int>[];
      await pumpDs(tester, tabs(onTap: taps.add));
      expect(find.text('page-a'), findsOneWidget);
      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
      expect(find.text('page-b'), findsOneWidget);
      expect(taps, [1]);
    });

    testWidgets('renders both styles, scrollable and fixed', (tester) async {
      for (final style in AppTabBarStyle.values) {
        for (final scrollable in [false, true]) {
          await pumpDs(tester, tabs(style: style, scrollable: scrollable));
          expect(find.text('Alpha'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets('shows a badge on tabs with a count', (tester) async {
      await pumpDs(
        tester,
        tabs(
          items: const [
            AppTabItem(label: 'Alpha', icon: Icons.home, badgeCount: 7),
            AppTabItem(label: 'Beta', badgeCount: 12),
            AppTabItem(label: 'Gamma'),
          ],
        ),
      );
      expect(find.text('7'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });

    test('preferredSize grows when any tab has an icon', () {
      const plain = AppTabBar(tabs: [AppTabItem(label: 'a')]);
      const icons = AppTabBar(
        tabs: [AppTabItem(label: 'a', icon: Icons.home)],
      );
      expect(plain.preferredSize.height, 48);
      expect(icons.preferredSize.height, greaterThan(48));
    });
  });

  group('AppBottomNavBar', () {
    testWidgets('is a bottom bar on phones and reports taps', (tester) async {
      var selected = -1;
      await pumpDs(
        tester,
        AppScaffold(
          navigationBar: _nav(onSelected: (i) => selected = i),
          body: const SizedBox(),
        ),
        scaffold: false,
      );
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      await tester.tap(find.text('Profile'));
      expect(selected, 2);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('becomes a labelled rail at the start edge on tablets', (
      tester,
    ) async {
      for (final (locale, atStart) in [('en', true), ('ar', false)]) {
        await pumpDs(
          tester,
          AppScaffold(navigationBar: _nav(), body: const SizedBox()),
          scaffold: false,
          size: tabletSize,
          locale: locale,
        );
        expect(find.byType(NavigationBar), findsNothing);
        final rail = tester.getRect(find.byType(NavigationRail));
        final rail0 = atStart ? rail.left : tabletSize.width - rail.right;
        expect(rail0, 0, reason: locale);
        expect(
          tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
          isFalse,
        );
      }
    });

    testWidgets('is an extended rail on desktop and selects on tap', (
      tester,
    ) async {
      var selected = -1;
      await pumpDs(
        tester,
        AppScaffold(
          navigationBar: _nav(onSelected: (i) => selected = i),
          body: const SizedBox(),
        ),
        scaffold: false,
        size: desktopSize,
      );
      expect(
        tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
        isTrue,
      );
      await tester.tap(find.text('Search'));
      expect(selected, 1);
    });

    testWidgets('survives text scale 2.0 on phone and tablet', (tester) async {
      for (final size in [phoneSize, tabletSize]) {
        await pumpDs(
          tester,
          AppScaffold(navigationBar: _nav(), body: const SizedBox()),
          scaffold: false,
          size: size,
          textScale: 2.0,
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('AppScaffold', () {
    Widget scaffold({
      Widget? banner,
      bool adaptivePadding = true,
      double maxWidth = 720,
    }) => AppScaffold(
      banner: banner,
      adaptivePadding: adaptivePadding,
      maxWidth: maxWidth,
      floatingActionButton: const FloatingActionButton(
        onPressed: null,
        child: Icon(Icons.add),
      ),
      body: const SizedBox.expand(key: Key('body')),
    );

    testWidgets('side padding adapts to the width class', (tester) async {
      for (final (size, padding) in [
        (phoneSize, 16.0),
        (tabletSize, 24.0),
        (desktopSize, 32.0),
      ]) {
        await pumpDs(tester, scaffold(), scaffold: false, size: size);
        final width = tester.getSize(find.byKey(const Key('body'))).width;
        final available = size.width > 720 ? 720.0 : size.width;
        expect(width, available - 2 * padding, reason: '$size');
      }
    });

    testWidgets('content is capped at maxWidth and centered', (tester) async {
      await pumpDs(
        tester,
        scaffold(adaptivePadding: false),
        scaffold: false,
        size: desktopSize,
      );
      final rect = tester.getRect(find.byKey(const Key('body')));
      expect(rect.width, 720);
      expect(rect.center.dx, desktopSize.width / 2);
    });

    testWidgets('infinite maxWidth is edge to edge', (tester) async {
      await pumpDs(
        tester,
        scaffold(adaptivePadding: false, maxWidth: double.infinity),
        scaffold: false,
        size: desktopSize,
      );
      expect(
        tester.getSize(find.byKey(const Key('body'))).width,
        desktopSize.width,
      );
    });

    testWidgets('banner slot is full width and collapses when removed', (
      tester,
    ) async {
      await pumpDs(
        tester,
        scaffold(
          banner: const ColoredBox(color: Colors.red, child: Text('offline')),
        ),
        scaffold: false,
        size: desktopSize,
      );
      expect(find.text('offline'), findsOneWidget);
      expect(
        tester
            .getSize(
              find
                  .ancestor(
                    of: find.text('offline'),
                    matching: find.byType(ColoredBox),
                  )
                  .first,
            )
            .width,
        desktopSize.width,
      );
      final bodyTop = tester.getTopLeft(find.byKey(const Key('body'))).dy;

      await pumpDs(tester, scaffold(), scaffold: false, size: desktopSize);
      expect(find.text('offline'), findsNothing);
      expect(
        tester.getTopLeft(find.byKey(const Key('body'))).dy,
        lessThan(bodyTop),
      );
    });

    testWidgets('shows the floating action button', (tester) async {
      await pumpDs(tester, scaffold(), scaffold: false);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('AppStepper', () {
    const steps = [
      AppStep(title: 'Account', subtitle: 'Your details', content: Text('c1')),
      AppStep(title: 'Address', content: Text('c2')),
      AppStep(title: 'Confirm', content: Text('c3')),
    ];

    testWidgets('vertical shows only the current content and check marks', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const SingleChildScrollView(
          child: AppStepper(steps: steps, currentStep: 1),
        ),
      );
      expect(find.text('c1'), findsNothing);
      expect(find.text('c2'), findsOneWidget);
      expect(find.text('c3'), findsNothing);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('Your details'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('step taps are reported on both axes', (tester) async {
      final tapped = <int>[];
      for (final axis in Axis.values) {
        await pumpDs(
          tester,
          SingleChildScrollView(
            child: AppStepper(
              steps: steps,
              currentStep: 0,
              axis: axis,
              onStepTapped: tapped.add,
            ),
          ),
        );
        await tester.tap(find.text('Address'));
      }
      expect(tapped, [1, 1]);
    });

    testWidgets('horizontal lists titles and no content', (tester) async {
      await pumpDs(
        tester,
        const AppStepper(steps: steps, currentStep: 2, axis: Axis.horizontal),
      );
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('c3'), findsNothing);
      expect(find.byIcon(Icons.check), findsNWidgets(2));
    });

    testWidgets('semantics announce position and state, in Arabic too', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const AppStepper(steps: steps, currentStep: 1, axis: Axis.horizontal),
      );
      expect(
        find.bySemanticsLabel('Step 2 of 3, Address, Current step'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Step 1 of 3, Account, Completed'),
        findsOneWidget,
      );
      await pumpDs(
        tester,
        const AppStepper(steps: steps, currentStep: 1, axis: Axis.horizontal),
        locale: 'ar',
      );
      expect(
        find.bySemanticsLabel('الخطوة 2 من 3, Address, الخطوة الحالية'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('survives text scale 2.0 on both axes', (tester) async {
      for (final axis in Axis.values) {
        await pumpDs(
          tester,
          SingleChildScrollView(
            child: AppStepper(
              steps: const [
                AppStep(title: 'A rather long step title', content: Text('c')),
                AppStep(title: 'Another long step title'),
                AppStep(title: 'Final long step title'),
              ],
              currentStep: 0,
              axis: axis,
            ),
          ),
          textScale: 2.0,
        );
        expect(tester.takeException(), isNull, reason: '$axis');
      }
    });
  });
}

double _sliverExtent(WidgetTester tester) => tester
    .renderObject<RenderSliver>(find.byType(SliverAppBar))
    .geometry!
    .paintExtent;

const _tabItems = [
  AppTabItem(label: 'Alpha'),
  AppTabItem(label: 'Beta'),
  AppTabItem(label: 'Gamma'),
];
