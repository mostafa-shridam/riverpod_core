import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/crash/crash_reporter.dart';

import '../../helpers/create_container.dart';

AppConfig _config({required bool crash}) => AppConfig.fromMap(Flavor.dev, {
  'APP_NAME': 'App',
  'API_BASE_URL': 'http://localhost',
  'CONNECT_TIMEOUT_MS': '1000',
  'RECEIVE_TIMEOUT_MS': '1000',
  'ENABLE_CRASH_REPORTING': '$crash',
});

void main() {
  test('disabled in config selects the noop reporter', () {
    final container = createContainer(
      overrides: [appConfigProvider.overrideWithValue(_config(crash: false))],
    );
    expect(container.read(crashReporterProvider), isA<NoopCrashReporter>());
  });

  test('enabled in config selects the console reporter', () {
    final container = createContainer(
      overrides: [appConfigProvider.overrideWithValue(_config(crash: true))],
    );
    expect(container.read(crashReporterProvider), isA<ConsoleCrashReporter>());
  });

  test('noop reporter accepts calls without throwing', () async {
    const reporter = NoopCrashReporter();
    await reporter.recordError('e', null, fatal: true);
    await reporter.setUserId(null);
  });
}
