import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:riverpod_core/core/app/app.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/config_exception.dart';
import 'package:riverpod_core/core/config/env_loader.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/crash/crash_reporter.dart';
import 'package:riverpod_core/core/design_system/widgets/permissions/permission_rationale_dialog.dart';
import 'package:riverpod_core/core/firebase/observability_init.dart';
import 'package:riverpod_core/core/localization/app_locales.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';
import 'package:riverpod_core/core/notifications/notification_service_provider.dart';
import 'package:riverpod_core/core/permissions/permission_service.dart';
import 'package:riverpod_core/core/storage/hive_boxes.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/core/utils/formatting/formatting_setup.dart';
import 'package:riverpod_core/generated/codegen_loader.g.dart';

/// Shows the app. `runApp` in production; a capture in tests.
typedef AppRunner = void Function(Widget app);

/// Opens the local stores (D-034): Hive in the app documents directory, then
/// the settings and cache boxes. Returns the provider overrides that expose them.
Future<List<Override>> openAppStorage() async {
  await Hive.initFlutter();
  return storageOverrides(
    settings: await Hive.openBox<dynamic>(HiveBoxNames.settings),
    cache: await Hive.openBox<Map<dynamic, dynamic>>(HiveBoxNames.cache),
  );
}

/// Starts the app for [flavor] (D-024): load and validate config, open the
/// local stores, install the global error handlers, warm storage, then run the
/// app.
///
/// A config failure shows [ConfigErrorApp]; optional services never block.
/// A storage failure is fatal and goes to the zone error handler.
/// [envReader], [runner], [overrides], [openStorage] and [initNotifications]
/// exist for tests.
Future<void> bootstrap(
  Flavor flavor, {
  AssetReader? envReader,
  AppRunner runner = runApp,
  List<Override> overrides = const [],
  Future<List<Override>> Function()? openStorage,
  Future<void> Function()? initNotifications,
}) {
  final done = Completer<void>();
  // Before the config is known only errors are logged; replaced below.
  var logger = const AppLogger(level: LogLevel.error);
  CrashReporter crashReporter = const NoopCrashReporter();

  runZonedGuarded(
    () async {
      try {
        WidgetsFlutterBinding.ensureInitialized();

        final AppConfig config;
        try {
          final env = await EnvLoader.load(flavor, reader: envReader);
          config = AppConfig.fromMap(flavor, env);
        } on ConfigException catch (e) {
          logger.error('Invalid app configuration', error: e);
          runner(ConfigErrorApp(problems: e.problems));
          return;
        }

        final storage = await (openStorage ?? openAppStorage)();
        // D-032: no silent provider retries; Dio retries network calls only.
        final container = ProviderContainer(
          retry: (retryCount, error) => null,
          overrides: [
            appConfigProvider.overrideWithValue(config),
            // The rationale is shown before the system prompt (C-46).
            permissionRationalePresenterProvider.overrideWithValue(
              showPermissionRationale,
            ),
            ...storage,
            ...overrides,
          ],
        );
        logger = container.read(loggerProvider);
        await initObservability(container);
        crashReporter = container.read(crashReporterProvider);
        installErrorHandlers(logger: logger, crashReporter: crashReporter);

        try {
          await container.read(prefsStorageProvider.future);
        } on Object catch (e, s) {
          // Not fatal here: consumers see the same error in their AsyncValue.
          await reportError(
            logger,
            crashReporter,
            e,
            s,
            reason: 'Preferences failed to load',
          );
        }

        try {
          await (initNotifications ??
              () => container.read(notificationServiceProvider).initialize())();
        } on Object catch (e) {
          logger.warning('Error when init NotificationService', error: e);
        }

        await initFormatting();

        runner(
          UncontrolledProviderScope(
            container: container,
            child: EasyLocalization(
              supportedLocales: supportedLocales,
              path: translationsPath,
              // No startLocale: the saved locale, else the device locale if
              // supported, else the fallback (D-035).
              fallbackLocale: const Locale('en'),
              saveLocale: true,
              ignorePluralRules: false,
              assetLoader: const CodegenLoader(),
              child: const App(),
            ),
          ),
        );
      } finally {
        done.complete();
      }
    },
    (error, stackTrace) {
      unawaited(
        reportError(
          logger,
          crashReporter,
          error,
          stackTrace,
          fatal: true,
          reason: 'Uncaught zone error',
        ),
      );
    },
  );
  return done.future;
}

/// Routes framework and platform errors to the logger and [crashReporter].
void installErrorHandlers({
  required AppLogger logger,
  required CrashReporter crashReporter,
}) {
  FlutterError.onError = (details) {
    unawaited(
      reportError(
        logger,
        crashReporter,
        details.exception,
        details.stack,
        reason: details.exceptionAsString(),
      ),
    );
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    unawaited(
      reportError(
        logger,
        crashReporter,
        error,
        stackTrace,
        fatal: true,
        reason: 'Uncaught platform error',
      ),
    );
    return true;
  };
}

/// Logs [error] and forwards it to [crashReporter]. Never throws.
Future<void> reportError(
  AppLogger logger,
  CrashReporter crashReporter,
  Object error,
  StackTrace? stackTrace, {
  bool fatal = false,
  String? reason,
}) async {
  logger.error(
    reason ?? 'Unhandled error',
    error: error,
    stackTrace: stackTrace,
  );
  try {
    await crashReporter.recordError(
      error,
      stackTrace,
      fatal: fatal,
      reason: reason,
    );
  } on Object catch (e) {
    logger.error('Crash reporter failed', error: e);
  }
}

/// Minimal app shown when the config is invalid. English literals on purpose:
/// localization is not loaded yet and this screen is for the developer.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({required this.problems, super.key});

  final List<String> problems;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsetsDirectional.all(24),
            children: [
              const Text(
                'Invalid app configuration',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              for (final problem in problems) Text('- $problem'),
              const SizedBox(height: 16),
              const Text(
                'Fix env/<flavor>.env (copy env/<flavor>.env.example) '
                'and restart the app.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
