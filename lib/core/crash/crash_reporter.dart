import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';

part 'crash_reporter.g.dart';

/// Reports unexpected errors to a crash backend. The vendor implementation
/// arrives with C-30; until then only [NoopCrashReporter] and
/// [ConsoleCrashReporter] exist.
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
}

/// Writes reports to the logger. Stand-in until a vendor is chosen (C-30).
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
}

/// The crash reporter chosen by `AppConfig.enableCrashReporting`.
@Riverpod(keepAlive: true)
CrashReporter crashReporter(Ref ref) {
  final config = ref.watch(appConfigProvider);
  if (!config.enableCrashReporting) {
    return const NoopCrashReporter();
  }
  return ConsoleCrashReporter(ref.watch(loggerProvider));
}
