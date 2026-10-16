import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/analytics/analytics_service.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';

import '../../helpers/create_container.dart';
import '../../helpers/fake_analytics.dart';

AppConfig _config({required bool analytics}) => AppConfig.fromMap(Flavor.dev, {
  'APP_NAME': 'App',
  'API_BASE_URL': 'http://localhost',
  'CONNECT_TIMEOUT_MS': '1000',
  'RECEIVE_TIMEOUT_MS': '1000',
  'ENABLE_ANALYTICS': '$analytics',
});

void main() {
  test('disabled in config selects the noop service', () {
    final container = createContainer(
      overrides: [
        appConfigProvider.overrideWithValue(_config(analytics: false)),
      ],
    );
    expect(
      container.read(analyticsServiceProvider),
      isA<NoopAnalyticsService>(),
    );
  });

  test('enabled in config selects the console service', () {
    final container = createContainer(
      overrides: [
        appConfigProvider.overrideWithValue(_config(analytics: true)),
      ],
    );
    expect(
      container.read(analyticsServiceProvider),
      isA<ConsoleAnalyticsService>(),
    );
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
}
