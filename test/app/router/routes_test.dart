import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/app/router/paths.dart';
import 'package:riverpod_core/app/router/routes.dart';

void main() {
  test('typed routes produce the paths in AppPaths', () {
    expect(const SplashRoute().location, AppPaths.splash);
    expect(const OnboardingRoute().location, AppPaths.onboarding);
    expect(const LoginRoute().location, AppPaths.login);
    expect(const HomeRoute().location, AppPaths.home);
    expect(const MoreRoute().location, AppPaths.more);
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
