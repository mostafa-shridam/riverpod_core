import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/router/routes.dart';
import 'package:riverpod_core/features/home/presentation/pages/home_page.dart';
import 'package:riverpod_core/features/showcase/presentation/pages/showcase_page.dart';

import '../../core/design_system/widgets/display/ds_test_harness.dart';

AppConfig _config(Flavor flavor) => AppConfig.fromMap(flavor, const {
  'APP_NAME': 'Test App',
  'API_BASE_URL': 'https://api.example.com',
  'CONNECT_TIMEOUT_MS': '15000',
  'RECEIVE_TIMEOUT_MS': '20000',
});

void main() {
  test('the gallery exists in dev and staging, not in prod', () {
    expect(ShowcasePage.isEnabled(Flavor.dev), isTrue);
    expect(ShowcasePage.isEnabled(Flavor.staging), isTrue);
    expect(ShowcasePage.isEnabled(Flavor.prod), isFalse);
    expect(const ShowcaseRoute().location, ShowcasePage.routeName);
  });

  for (final flavor in Flavor.values) {
    testWidgets('home entry tile in ${flavor.name}', (tester) async {
      await pumpDs(
        tester,
        ProviderScope(
          overrides: [appConfigProvider.overrideWithValue(_config(flavor))],
          child: const HomePage(),
        ),
        scaffold: false,
      );
      expect(
        find.byKey(const ValueKey('open-showcase')),
        flavor == Flavor.prod ? findsNothing : findsOneWidget,
      );
    });
  }

  for (final flavor in [Flavor.dev, Flavor.prod]) {
    testWidgets('route in ${flavor.name} redirects only in prod', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: ShowcasePage.routeName,
        routes: [
          GoRoute(
            path: HomePage.routeName,
            builder: (_, _) => const SizedBox(key: ValueKey('home-stub')),
          ),
          GoRoute(
            path: ShowcasePage.routeName,
            redirect: (context, state) =>
                const ShowcaseRoute().redirect(context, state),
            builder: (_, _) => const SizedBox(key: ValueKey('gallery-stub')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await pumpDs(
        tester,
        ProviderScope(
          overrides: [appConfigProvider.overrideWithValue(_config(flavor))],
          child: Router<Object>.withConfig(config: router),
        ),
        scaffold: false,
      );
      await tester.pumpAndSettle();
      expect(
        router.state.uri.path,
        flavor == Flavor.prod ? HomePage.routeName : ShowcasePage.routeName,
      );
    });
  }
}
