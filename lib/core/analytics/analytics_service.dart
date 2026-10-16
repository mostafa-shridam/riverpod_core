import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';

part 'analytics_service.g.dart';

/// Product analytics. The vendor implementation is a later task; callers only
/// depend on this interface. Never pass personal data or secrets as params.
abstract interface class AnalyticsService {
  /// Logs the event [name] with optional [params].
  Future<void> logEvent(String name, {Map<String, Object?>? params});

  /// Sets (or with null clears) the analytics user id.
  Future<void> setUserId(String? userId);

  /// Forgets the user and local analytics state (called by logout).
  Future<void> reset();
}

/// Does nothing. Used when analytics is disabled.
class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? params}) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> reset() async {}
}

/// Writes events to the logger (debug level). For development.
class ConsoleAnalyticsService implements AnalyticsService {
  const ConsoleAnalyticsService(this._logger);

  final AppLogger _logger;

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? params}) async {
    _logger.debug('[analytics] $name ${params ?? const <String, Object?>{}}');
  }

  @override
  Future<void> setUserId(String? userId) async {
    _logger.debug('[analytics] user id ${userId == null ? 'cleared' : 'set'}');
  }

  @override
  Future<void> reset() async {
    _logger.debug('[analytics] reset');
  }
}

/// The analytics service chosen by `AppConfig.enableAnalytics`.
@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) {
  final config = ref.watch(appConfigProvider);
  if (!config.enableAnalytics) {
    return const NoopAnalyticsService();
  }
  return ConsoleAnalyticsService(ref.watch(loggerProvider));
}
