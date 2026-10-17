import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/analytics/analytics_backend.dart';
import 'package:riverpod_core/core/analytics/analytics_route_observer.dart';
import 'package:riverpod_core/core/analytics/analytics_service.dart';
import 'package:riverpod_core/core/analytics/firebase_analytics_service.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/firebase/firebase_bootstrap.dart';

import '../../helpers/create_container.dart';
import '../../helpers/fake_analytics.dart';

AppConfig _config({required bool analytics}) => AppConfig.fromMap(Flavor.dev, {
  'APP_NAME': 'App',
  'API_BASE_URL': 'http://localhost',
  'CONNECT_TIMEOUT_MS': '1000',
  'RECEIVE_TIMEOUT_MS': '1000',
  'ENABLE_ANALYTICS': '$analytics',
});

ProviderContainer _containerWith({
  required bool analytics,
  required bool firebase,
}) {
  final container = createContainer(
    overrides: [
      appConfigProvider.overrideWithValue(_config(analytics: analytics)),
      analyticsBackendProvider.overrideWithValue(FakeAnalyticsBackend()),
    ],
  );
  container
      .read(firebaseAvailableProvider.notifier)
      .markAvailable(value: firebase);
  return container;
}

void main() {
  test('disabled in config selects the noop service', () {
    final container = _containerWith(analytics: false, firebase: true);
    expect(
      container.read(analyticsServiceProvider),
      isA<NoopAnalyticsService>(),
    );
  });

  test('enabled but Firebase not configured selects the noop service', () {
    final container = _containerWith(analytics: true, firebase: false);
    expect(
      container.read(analyticsServiceProvider),
      isA<NoopAnalyticsService>(),
    );
  });

  test('enabled and Firebase configured selects the Firebase service', () {
    final container = _containerWith(analytics: true, firebase: true);
    expect(
      container.read(analyticsServiceProvider),
      isA<FirebaseAnalyticsService>(),
    );
  });

  test('noop service accepts calls without throwing', () async {
    const service = NoopAnalyticsService();
    await service.logEvent('e');
    await service.logScreenView('s');
    await service.setUserId(null);
    await service.setUserProperty('p', null);
    await service.setCollectionEnabled(enabled: false);
    await service.reset();
  });

  test('fake records events, user ids and resets', () async {
    final fake = FakeAnalytics();
    await fake.logEvent('open', params: {'a': 1});
    await fake.setUserId('u1');
    await fake.reset();
    expect(fake.events.single.name, 'open');
    expect(fake.userIds, ['u1']);
    expect(fake.resetCount, 1);
  });

  group('FirebaseAnalyticsService forwards to the backend', () {
    late FakeAnalyticsBackend backend;
    late FirebaseAnalyticsService service;

    setUp(() {
      backend = FakeAnalyticsBackend();
      service = FirebaseAnalyticsService(backend);
    });

    test(
      'events: nulls dropped, bools become numbers, others strings',
      () async {
        await service.logEvent(
          'buy',
          params: {
            'n': 2,
            's': 'x',
            'b': true,
            'gone': null,
            'd': Duration.zero,
          },
        );
        await service.logEvent('plain');
        expect(backend.events.first.name, 'buy');
        expect(backend.events.first.params, {
          'n': 2,
          's': 'x',
          'b': 1,
          'd': '0:00:00.000000',
        });
        expect(backend.events.last.params, isNull);
      },
    );

    test('screen, user id, property, collection and reset', () async {
      await service.logScreenView('/home');
      await service.setUserId('u1');
      await service.setUserProperty('plan', 'free');
      await service.setCollectionEnabled(enabled: false);
      await service.reset();
      expect(backend.screens, ['/home']);
      expect(backend.userIds, ['u1']);
      expect(backend.properties, {'plan': 'free'});
      expect(backend.collection, [false]);
      expect(backend.resetCount, 1);
    });
  });

  group('AnalyticsRouteObserver', () {
    Route<dynamic> page(String? name) => MaterialPageRoute<void>(
      settings: RouteSettings(name: name),
      builder: (_) => const SizedBox(),
    );

    test('logs named page routes on push, replace and pop', () {
      final analytics = FakeAnalytics();
      final observer = AnalyticsRouteObserver(() => analytics);
      final home = page('/home');
      final detail = page('/detail');
      observer.didPush(home, null);
      observer.didPush(detail, home);
      observer.didPop(detail, home);
      observer.didReplace(newRoute: detail, oldRoute: home);
      expect(analytics.screens, ['/home', '/detail', '/home', '/detail']);
    });

    test('ignores unnamed routes and repeated names', () {
      final analytics = FakeAnalytics();
      final observer = AnalyticsRouteObserver(() => analytics);
      observer.didPush(page(null), null);
      observer.didPush(page('/a'), null);
      observer.didPush(page('/a'), null);
      expect(analytics.screens, ['/a']);
    });

    test('provider reads the current analytics service', () {
      final analytics = FakeAnalytics();
      final container = createContainer(
        overrides: [analyticsServiceProvider.overrideWithValue(analytics)],
      );
      container.read(analyticsRouteObserverProvider).didPush(page('/x'), null);
      expect(analytics.screens, ['/x']);
    });
  });
}
