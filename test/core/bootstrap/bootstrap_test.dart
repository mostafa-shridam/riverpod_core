import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/bootstrap/bootstrap.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/crash/crash_reporter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_crash_reporter.dart';

const _validEnv = '''
APP_NAME=Test
API_BASE_URL=https://api.example.com
CONNECT_TIMEOUT_MS=1000
RECEIVE_TIMEOUT_MS=1000
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterExceptionHandler? savedFlutterHandler;
  late bool Function(Object, StackTrace)? savedPlatformHandler;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    savedFlutterHandler = FlutterError.onError;
    savedPlatformHandler = PlatformDispatcher.instance.onError;
  });

  tearDown(() {
    FlutterError.onError = savedFlutterHandler;
    PlatformDispatcher.instance.onError = savedPlatformHandler;
  });

  Future<Widget?> run({
    required Flavor flavor,
    String env = _validEnv,
    FakeCrashReporter? crash,
    void Function(Widget)? onRun,
    List<String>? readPaths,
  }) async {
    Widget? app;
    await bootstrap(
      flavor,
      envReader: (path) async {
        readPaths?.add(path);
        return env;
      },
      runner: (widget) {
        app = widget;
        onRun?.call(widget);
      },
      overrides: [
        if (crash != null) crashReporterProvider.overrideWithValue(crash),
      ],
      initNotifications: () async {},
    );
    return app;
  }

  test('invalid config yields the error app listing every problem', () async {
    final app = await run(flavor: Flavor.dev, env: 'FOO=bar');
    expect(app, isA<ConfigErrorApp>());
    final problems = (app! as ConfigErrorApp).problems;
    expect(problems.length, greaterThan(1));
  });

  testWidgets('error app renders the problems', (tester) async {
    await tester.pumpWidget(
      const ConfigErrorApp(problems: ['APP_NAME is required', 'Other']),
    );
    expect(find.textContaining('APP_NAME is required'), findsOneWidget);
    expect(find.textContaining('Other'), findsOneWidget);
  });

  test('missing env file yields the error app', () async {
    Widget? app;
    await bootstrap(
      Flavor.dev,
      envReader: (_) async => throw StateError('no file'),
      runner: (w) => app = w,
      initNotifications: () async {},
    );
    expect(app, isA<ConfigErrorApp>());
  });

  test('staging entrypoint loads the staging env and config', () async {
    final paths = <String>[];
    final app = await run(flavor: Flavor.staging, readPaths: paths);
    expect(paths, ['env/staging.env']);
    final scope = app! as UncontrolledProviderScope;
    expect(scope.container.read(appConfigProvider).flavor, Flavor.staging);
  });

  test('FlutterError and platform errors reach the crash reporter', () async {
    final crash = FakeCrashReporter();
    await run(flavor: Flavor.dev, crash: crash);

    FlutterError.onError!(
      FlutterErrorDetails(
        exception: StateError('flutter'),
        stack: StackTrace.current,
      ),
    );
    final handled = PlatformDispatcher.instance.onError!(
      StateError('platform'),
      StackTrace.current,
    );
    await Future<void>.delayed(Duration.zero);

    expect(handled, isTrue);
    expect(crash.errors.map((e) => '${e.error}'), [
      contains('flutter'),
      contains('platform'),
    ]);
    expect(crash.errors.last.fatal, isTrue);
  });

  test('uncaught zone errors reach the crash reporter', () async {
    final crash = FakeCrashReporter();
    await run(
      flavor: Flavor.dev,
      crash: crash,
      onRun: (_) => scheduleMicrotask(() => throw StateError('zone')),
    );
    await Future<void>.delayed(Duration.zero);

    expect(crash.errors.single.error, isA<StateError>());
    expect(crash.errors.single.fatal, isTrue);
  });
}
