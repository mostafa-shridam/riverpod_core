import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/app/router/placeholder_pages.dart';
import 'package:riverpod_core/app/router/routes.dart';
import 'package:riverpod_core/app/startup/splash_page.dart';
import 'package:riverpod_core/features/home/presentation/pages/home_page.dart';

void main() {
  test('typed routes produce the paths in AppPaths', () {
    expect(const SplashRoute().location, SplashPage.routeName);
    expect(const OnboardingRoute().location, OnboardingPage.routeName);
    expect(const LoginRoute().location, LoginPage.routeName);
    expect(const HomeRoute().location, HomePage.routeName);
    expect(const MoreRoute().location, MorePage.routeName);
  });

  test('item route carries its id in the path', () {
    expect(const ItemDetailRoute(id: '42').location, '/items/42');
  });

  group('routeForDeepLink', () {
    test('a known type resolves to the typed item route', () {
      final route = routeForDeepLink(type: 'myEvents', id: '42');
      expect(route, isA<ItemDetailRoute>());
      expect((route! as ItemDetailRoute).id, '42');
    });

    test('an unknown type is ignored, not guessed', () {
      expect(routeForDeepLink(type: 'nope', id: '42'), isNull);
    });
  });
}
