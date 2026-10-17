import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/crash/crash_backend.dart';
import 'package:riverpod_core/core/crash/firebase_crash_reporter.dart';
import 'package:riverpod_core/core/firebase/firebase_bootstrap.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';

part 'crash_reporter.g.dart';

/// Reports unexpected errors to a crash backend. Implementations: Noop (off,
/// or Firebase not configured), Console (development), Firebase Crashlytics
/// (`firebase_crash_reporter.dart`). Never pass personal data.
abstract interface class CrashReporter {
  /// Records [error]. [fatal] marks errors that ended the current flow.
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
    String? reason,
  });

  /// Associates later reports with [userId]; null clears it (logout).
  Future<void> setUserId(String? userId);

  /// Attaches a custom key/value to later reports.
  Future<void> setCustomKey(String key, Object value);

  /// Adds a breadcrumb line to the next report.
  Future<void> log(String message);

  /// Turns collection on or off (the consent switch).
  Future<void> setCollectionEnabled({required bool enabled});
}

/// Does nothing. Used when crash reporting is disabled.
class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
    String? reason,
  }) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setCustomKey(String key, Object value) async {}

  @override
  Future<void> log(String message) async {}

  @override
  Future<void> setCollectionEnabled({required bool enabled}) async {}
}

/// Writes reports to the logger. For development; not selected by default.
class ConsoleCrashReporter implements CrashReporter {
  const ConsoleCrashReporter(this._logger);

  final AppLogger _logger;

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
    String? reason,
  }) async {
    _logger.error(
      '[crash${fatal ? ':fatal' : ''}] ${reason ?? 'unexpected error'}',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  Future<void> setUserId(String? userId) async {
    _logger.debug('[crash] user id ${userId == null ? 'cleared' : 'set'}');
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    _logger.debug('[crash] key $key set');
  }

  @override
  Future<void> log(String message) async {
    _logger.debug('[crash] $message');
  }

  @override
  Future<void> setCollectionEnabled({required bool enabled}) async {
    _logger.debug('[crash] collection ${enabled ? 'on' : 'off'}');
  }
}

/// The crash reporter: Crashlytics when `AppConfig.enableCrashReporting` is on
/// AND Firebase is configured, otherwise Noop (D-042).
@Riverpod(keepAlive: true)
CrashReporter crashReporter(Ref ref) {
  final config = ref.watch(appConfigProvider);
  if (!config.enableCrashReporting || !ref.watch(firebaseAvailableProvider)) {
    return const NoopCrashReporter();
  }
  return FirebaseCrashReporter(ref.watch(crashBackendProvider));
}
