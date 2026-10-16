import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/router/routes.dart';
import 'package:riverpod_core/features/home/presentation/pages/home_page.dart';
import 'package:riverpod_core/features/videos/presentation/pages/video_detail_page.dart';
import 'package:riverpod_core/features/videos/presentation/pages/videos_page.dart';

import '../../core/design_system/widgets/display/ds_test_harness.dart';
import '../../helpers/fake_connectivity.dart';
import '../../helpers/fake_prefs_storage.dart';
import 'videos_test_support.dart';

Future<void> _pumpRouter(
  WidgetTester tester, {
  required Flavor flavor,
  required String location,
}) async {
  final prefs = (await tester.runAsync(fakePrefsStorage))!;
  final router = GoRouter(initialLocation: location, routes: $appRoutes);
  addTearDown(router.dispose);
  await pumpDs(
    tester,
    ProviderScope(
      overrides: videosOverrides(
        source: fastSource(),
        prefs: prefs,
        connectivity: FakeConnectivity(),
        flavor: flavor,
      ),
      child: Router<Object>.withConfig(config: router),
    ),
    scaffold: false,
  );
}

void main() {
  group('typed routes', () {
    test('locations come from the page route names', () {
      expect(const VideosRoute().location, VideosPage.routeName);
      expect(const VideosRoute().location, '/videos');
      expect(const VideoDetailRoute(id: 'bee').location, '/videos/bee');
      expect(
        const VideoDetailRoute(
          id: 'custom',
          url: 'https://a.test/v.mp4',
        ).location,
        '/videos/custom?url=${Uri.encodeQueryComponent('https://a.test/v.mp4')}',
      );
      expect(VideoDetailPage.routeName, '/videos/:id');
    });
  });

  group('flavor gate', () {
    for (final flavor in [Flavor.dev, Flavor.staging]) {
      testWidgets('${flavor.name} opens the list and the detail', (
        tester,
      ) async {
        await _pumpRouter(tester, flavor: flavor, location: '/videos');
        expect(find.byType(VideosPage), findsOneWidget);

        await _pumpRouter(tester, flavor: flavor, location: '/videos/bee');
        expect(find.byType(VideoDetailPage), findsOneWidget);
      });
    }

    testWidgets('prod redirects both routes to home', (tester) async {
      for (final location in ['/videos', '/videos/bee']) {
        await _pumpRouter(tester, flavor: Flavor.prod, location: location);
        expect(find.byType(VideosPage), findsNothing, reason: location);
        expect(find.byType(VideoDetailPage), findsNothing, reason: location);
        expect(find.byType(HomePage), findsOneWidget, reason: location);
      }
    });
  });

  group('home entry', () {
    testWidgets('the Videos tile shows in dev and staging only', (
      tester,
    ) async {
      for (final flavor in Flavor.values) {
        await _pumpRouter(tester, flavor: flavor, location: '/home');
        expect(
          find.byKey(const ValueKey('home-videos-tile')),
          flavor == Flavor.prod ? findsNothing : findsOneWidget,
          reason: flavor.name,
        );
      }
    });

    testWidgets('tapping the tile opens the list', (tester) async {
      await _pumpRouter(tester, flavor: Flavor.dev, location: '/home');
      await tester.tap(find.byKey(const ValueKey('home-videos-tile')));
      await tester.pumpAndSettle();
      expect(find.byType(VideosPage), findsOneWidget);
    });
  });
}
