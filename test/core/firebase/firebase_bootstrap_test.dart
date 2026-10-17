import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/analytics/analytics_backend.dart';
import 'package:riverpod_core/core/analytics/analytics_service.dart';
import 'package:riverpod_core/core/analytics/firebase_analytics_service.dart';
import 'package:riverpod_core/core/bootstrap/bootstrap.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/crash/crash_backend.dart';
import 'package:riverpod_core/core/crash/crash_reporter.dart';
import 'package:riverpod_core/core/crash/firebase_crash_reporter.dart';
import 'package:riverpod_core/core/firebase/collection_consent.dart';
import 'package:riverpod_core/core/firebase/firebase_bootstrap.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';
import 'package:riverpod_core/core/storage/hive_boxes.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

import '../../helpers/create_container.dart';
import '../../helpers/fake_analytics.dart';
import '../../helpers/fake_crash_reporter.dart';
import '../../helpers/fake_prefs_storage.dart';

const _env = '''
APP_NAME=Test
API_BASE_URL=https://api.example.com
CONNECT_TIMEOUT_MS=1000
RECEIVE_TIMEOUT_MS=1000
ENABLE_CRASH_REPORTING=true
ENABLE_ANALYTICS=true
''';

/// A logger that records the messages it receives.
AppLogger _recordingLogger(List<String> messages) => AppLogger(
  level: LogLevel.debug,
  sink: (level, message, error, stackTrace) => messages.add(message),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestStorage storage;
  late FlutterExceptionHandler? savedFlutterHandler;
  late bool Function(Object, StackTrace)? savedPlatformHandler;

  setUp(() async {
    storage = await openTestStorage();
    savedFlutterHandler = FlutterError.onError;
    savedPlatformHandler = PlatformDispatcher.instance.onError;
  });

  tearDown(() {
    FlutterError.onError = savedFlutterHandler;
    PlatformDispatcher.instance.onError = savedPlatformHandler;
  });

  group('FirebaseBootstrap', () {
    test('success: true, initializer runs once for many callers', () async {
      var calls = 0;
      final bootstrap = FirebaseBootstrap(
        initializer: () async => calls++,
        logger: _recordingLogger([]),
      );
      expect(
        await Future.wait([
          bootstrap.ensureInitialized(),
          bootstrap.ensureInitialized(),
        ]),
        [true, true],
      );
      expect(await bootstrap.ensureInitialized(), isTrue);
      expect(calls, 1);
    });

    test('failure: false, never throws, logs the line exactly once', () async {
      final logged = <String>[];
      final bootstrap = FirebaseBootstrap(
        initializer: () async => throw StateError('no google-services.json'),
        logger: _recordingLogger(logged),
      );
      expect(await bootstrap.ensureInitialized(), isFalse);
      expect(await bootstrap.ensureInitialized(), isFalse);
      expect(logged, ['Firebase not configured: crash/analytics disabled']);
    });
  });

  group('bootstrap selection', () {
    Future<ProviderContainer> run({
      required Future<void> Function() initializer,
      FakeCrashBackend? crash,
      FakeAnalyticsBackend? analytics,
    }) async {
      Widget? app;
      await bootstrap(
        Flavor.prod,
        envReader: (_) async => _env,
        runner: (widget) => app = widget,
        openStorage: () async =>
            storageOverrides(settings: storage.settings, cache: storage.cache),
        overrides: [
          firebaseInitializerProvider.overrideWithValue(initializer),
          crashBackendProvider.overrideWithValue(crash ?? FakeCrashBackend()),
          analyticsBackendProvider.overrideWithValue(
            analytics ?? FakeAnalyticsBackend(),
          ),
        ],
        initNotifications: () async {},
      );
      return (app! as UncontrolledProviderScope).container;
    }

    test('without Firebase files both services are Noop', () async {
      final container = await run(
        initializer: () async => throw StateError('not configured'),
      );
      expect(container.read(firebaseAvailableProvider), isFalse);
      expect(container.read(crashReporterProvider), isA<NoopCrashReporter>());
      expect(
        container.read(analyticsServiceProvider),
        isA<NoopAnalyticsService>(),
      );
    });

    test('with Firebase the real implementations are selected', () async {
      final container = await run(initializer: () async {});
      expect(container.read(firebaseAvailableProvider), isTrue);
      expect(
        container.read(crashReporterProvider),
        isA<FirebaseCrashReporter>(),
      );
      expect(
        container.read(analyticsServiceProvider),
        isA<FirebaseAnalyticsService>(),
      );
    });

    test('fatal and non-fatal errors reach the crash backend', () async {
      final crash = FakeCrashBackend();
      await run(initializer: () async {}, crash: crash);
      FlutterError.onError!(
        FlutterErrorDetails(exception: StateError('framework')),
      );
      PlatformDispatcher.instance.onError!(
        StateError('platform'),
        StackTrace.empty,
      );
      await Future<void>.delayed(Duration.zero);
      expect(crash.errors.map((e) => e.fatal), [false, true]);
    });

    test('saved consent is applied to both vendors at startup', () async {
      await storage.settings.put(PrefKeys.collectionConsent, false);
      final crash = FakeCrashBackend();
      final analytics = FakeAnalyticsBackend();
      await run(initializer: () async {}, crash: crash, analytics: analytics);
      expect(crash.collection, [false]);
      expect(analytics.collection, [false]);
    });
  });

  group('CollectionConsent', () {
    test('defaults to on, applies it, and persists a change', () async {
      final crash = FakeCrashReporter();
      final analytics = FakeAnalytics();
      final prefs = PrefsStorage(storage.settings);
      final container = createContainer(
        overrides: [
          crashReporterProvider.overrideWithValue(crash),
          analyticsServiceProvider.overrideWithValue(analytics),
          prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
        ],
      );
      expect(await container.read(collectionConsentProvider.future), isTrue);
      expect(crash.collection, [true]);

      await container
          .read(collectionConsentProvider.notifier)
          .setEnabled(value: false);
      expect(container.read(collectionConsentProvider).value, isFalse);
      expect(crash.collection, [true, false]);
      expect(analytics.collection, [true, false]);
      expect(storage.settings.get(PrefKeys.collectionConsent), isFalse);

      // A new app start reads the saved choice.
      final next = createContainer(
        overrides: [
          crashReporterProvider.overrideWithValue(crash),
          analyticsServiceProvider.overrideWithValue(analytics),
          prefsStorageProvider.overrideWith(
            (ref) => Future.value(PrefsStorage(storage.settings)),
          ),
        ],
      );
      expect(await next.read(collectionConsentProvider.future), isFalse);
    });
  });
}
