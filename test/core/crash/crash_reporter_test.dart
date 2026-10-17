import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/crash/crash_backend.dart';
import 'package:riverpod_core/core/crash/crash_reporter.dart';
import 'package:riverpod_core/core/crash/firebase_crash_reporter.dart';
import 'package:riverpod_core/core/firebase/firebase_bootstrap.dart';

import '../../helpers/create_container.dart';
import '../../helpers/fake_crash_reporter.dart';

AppConfig _config({required bool crash}) => AppConfig.fromMap(Flavor.dev, {
  'APP_NAME': 'App',
  'API_BASE_URL': 'http://localhost',
  'CONNECT_TIMEOUT_MS': '1000',
  'RECEIVE_TIMEOUT_MS': '1000',
  'ENABLE_CRASH_REPORTING': '$crash',
});

void main() {
  ProviderContainer containerWith({
    required bool crash,
    required bool firebase,
    FakeCrashBackend? backend,
  }) {
    final container = createContainer(
      overrides: [
        appConfigProvider.overrideWithValue(_config(crash: crash)),
        if (backend != null) crashBackendProvider.overrideWithValue(backend),
      ],
    );
    container
        .read(firebaseAvailableProvider.notifier)
        .markAvailable(value: firebase);
    return container;
  }

  test('disabled in config selects the noop reporter', () {
    final container = containerWith(crash: false, firebase: true);
    expect(container.read(crashReporterProvider), isA<NoopCrashReporter>());
  });

  test('enabled but Firebase not configured selects the noop reporter', () {
    final container = containerWith(crash: true, firebase: false);
    expect(container.read(crashReporterProvider), isA<NoopCrashReporter>());
  });

  test('enabled and Firebase configured selects the Firebase reporter', () {
    final container = containerWith(crash: true, firebase: true);
    expect(container.read(crashReporterProvider), isA<FirebaseCrashReporter>());
  });

  test('noop reporter accepts calls without throwing', () async {
    const reporter = NoopCrashReporter();
    await reporter.recordError('e', null, fatal: true);
    await reporter.setUserId(null);
    await reporter.setCustomKey('k', 1);
    await reporter.log('breadcrumb');
    await reporter.setCollectionEnabled(enabled: false);
  });

  group('FirebaseCrashReporter forwards to the backend', () {
    late FakeCrashBackend backend;
    late FirebaseCrashReporter reporter;

    setUp(() {
      backend = FakeCrashBackend();
      reporter = FirebaseCrashReporter(backend);
    });

    test('fatal and non-fatal errors keep their flag and reason', () async {
      final stack = StackTrace.current;
      await reporter.recordError('boom', stack, fatal: true, reason: 'zone');
      await reporter.recordError('soft', null);
      expect(backend.errors, hasLength(2));
      expect(backend.errors.first.fatal, isTrue);
      expect(backend.errors.first.reason, 'zone');
      expect(backend.errors.first.stackTrace, stack);
      expect(backend.errors.last.fatal, isFalse);
    });

    test('user id is set, and cleared with an empty identifier', () async {
      await reporter.setUserId('u1');
      await reporter.setUserId(null);
      expect(backend.userIdentifiers, ['u1', '']);
    });

    test('custom keys, breadcrumbs and the collection flag', () async {
      await reporter.setCustomKey('screen', 'home');
      await reporter.log('opened home');
      await reporter.setCollectionEnabled(enabled: false);
      expect(backend.keys, {'screen': 'home'});
      expect(backend.logs, ['opened home']);
      expect(backend.collection, [false]);
    });
  });
}
