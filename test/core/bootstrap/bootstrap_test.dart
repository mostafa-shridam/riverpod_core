import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/bootstrap/bootstrap.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/crash/crash_reporter.dart';
import 'package:riverpod_core/core/design_system/widgets/permissions/permission_rationale_dialog.dart';
import 'package:riverpod_core/core/permissions/app_permission.dart';
import 'package:riverpod_core/core/permissions/permission_service.dart';
import 'package:riverpod_core/core/storage/cache/cache_store.dart';
import 'package:riverpod_core/core/storage/hive_boxes.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/core/utils/formatting/app_formatters.dart';
import 'package:riverpod_core/core/utils/formatting/localized_text.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

import '../../helpers/fake_crash_reporter.dart';
import '../../helpers/helpers.dart';

const _validEnv = '''
APP_NAME=Test
API_BASE_URL=https://api.example.com
CONNECT_TIMEOUT_MS=1000
RECEIVE_TIMEOUT_MS=1000
''';

/// Denied, with a rationale worth showing. Records each system prompt.
class _RecordingBackend implements PermissionBackend {
  final requests = <AppPermission>[];

  @override
  Future<AppPermissionResult> status(AppPermission permission) async =>
      AppPermissionResult.denied;

  @override
  Future<AppPermissionResult> request(AppPermission permission) async {
    requests.add(permission);
    return AppPermissionResult.granted;
  }

  @override
  Future<bool> shouldShowRationale(AppPermission permission) async => true;

  @override
  Future<bool> openSettings() async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterExceptionHandler? savedFlutterHandler;
  late bool Function(Object, StackTrace)? savedPlatformHandler;

  setUp(() {
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
    List<Override> extra = const [],
  }) async {
    Widget? app;
    final storage = await openTestStorage();
    await bootstrap(
      flavor,
      envReader: (path) async {
        readPaths?.add(path);
        return env;
      },
      openStorage: () async =>
          storageOverrides(settings: storage.settings, cache: storage.cache),
      runner: (widget) {
        app = widget;
        onRun?.call(widget);
      },
      overrides: [
        if (crash != null) crashReporterProvider.overrideWithValue(crash),
        ...extra,
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
      openStorage: () async => throw StateError('storage must not open'),
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

  test(
    'bootstrap starts the app with localization and a provider scope',
    () async {
      final app = await run(flavor: Flavor.dev);
      expect(app, isA<UncontrolledProviderScope>());
      final scope = app! as UncontrolledProviderScope;
      final localization = scope.child as EasyLocalization;
      expect(localization.saveLocale, isTrue);
      expect(localization.ignorePluralRules, isFalse);
      expect(localization.startLocale, isNull);
      expect(localization.fallbackLocale, const Locale('en'));
    },
  );

  test('the stores are exposed through providers after bootstrap', () async {
    final app = await run(flavor: Flavor.dev);
    final container = (app! as UncontrolledProviderScope).container;

    expect(
      await container.read(prefsStorageProvider.future),
      isA<PrefsStorage>(),
    );
    expect(container.read(cacheStoreProvider), isA<CacheStore>());
  });

  test('a storage failure stops the app before it runs', () async {
    Widget? app;
    await bootstrap(
      Flavor.dev,
      envReader: (_) async => _validEnv,
      runner: (w) => app = w,
      openStorage: () async => throw StateError('hive could not open'),
      initNotifications: () async {},
    );
    expect(app, isNull);
  });

  test('a failing provider build is not retried (D-032)', () async {
    var builds = 0;
    final failing = FutureProvider<int>((ref) {
      builds++;
      throw StateError('boom');
    });
    final app = await run(flavor: Flavor.dev);
    final container = (app! as UncontrolledProviderScope).container;
    final sub = container.listen(failing, (_, _) {});
    addTearDown(sub.close);

    // The default policy would retry after ~200 ms; wait past it.
    await Future<void>.delayed(const Duration(milliseconds: 600));

    expect(builds, 1);
    expect(container.read(failing).hasError, isTrue);
  });

  test('bootstrap wires the design-system rationale presenter', () async {
    final app = await run(flavor: Flavor.dev);
    final container = (app! as UncontrolledProviderScope).container;

    expect(
      container.read(permissionRationalePresenterProvider),
      same(showPermissionRationale),
    );
  });

  testWidgets('the rationale comes before the system prompt', (tester) async {
    final backend = _RecordingBackend();
    await pumpApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => ProviderScope.containerOf(context)
              .read(permissionServiceProvider)
              .ensure(AppPermission.camera, context),
          child: const Text('ask'),
        ),
      ),
      overrides: [
        permissionBackendProvider.overrideWithValue(backend),
        // The same tear-off bootstrap installs.
        permissionRationalePresenterProvider.overrideWithValue(
          showPermissionRationale,
        ),
      ],
    );

    await tester.tap(find.text('ask'));
    await tester.pumpAndSettle();

    expect(find.byType(PermissionRationaleDialog), findsOneWidget);
    expect(
      backend.requests,
      isEmpty,
      reason: 'the system prompt waits for the explanation',
    );

    await tester.tap(
      find.descendant(
        of: find.byType(PermissionRationaleDialog),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(backend.requests, [AppPermission.camera]);
  });

  testWidgets('Arabic plurals work inside pumpApp', (tester) async {
    late String text;
    await pumpApp(
      tester,
      Builder(
        builder: (context) {
          text = pluralText(
            LocaleKeys.common_itemsCount,
            11,
            formatters: AppFormatters(context.locale.languageCode),
          );
          return Text(text);
        },
      ),
      locale: const Locale('ar'),
    );
    expect(text, '11 عنصرًا');
  });
}
