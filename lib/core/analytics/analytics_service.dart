import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/analytics/analytics_backend.dart';
import 'package:riverpod_core/core/analytics/firebase_analytics_service.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/firebase/firebase_bootstrap.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';

part 'analytics_service.g.dart';

/// Product analytics. Callers only depend on this interface. Never pass
/// personal data or secrets as params.
abstract interface class AnalyticsService {
  /// Logs the event [name] with optional [params].
  Future<void> logEvent(String name, {Map<String, Object?>? params});

  /// Logs that the screen [name] was shown.
  Future<void> logScreenView(String name);

  /// Sets (or with null clears) the analytics user id.
  Future<void> setUserId(String? userId);

  /// Sets (or with null clears) a user property. No personal data.
  Future<void> setUserProperty(String name, String? value);

  /// Turns collection on or off (the consent switch).
  Future<void> setCollectionEnabled({required bool enabled});

  /// Forgets the user and local analytics state (called by logout).
  Future<void> reset();
}

/// Does nothing. Used when analytics is disabled or Firebase is missing.
class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? params}) async {}

  @override
  Future<void> logScreenView(String name) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setUserProperty(String name, String? value) async {}

  @override
  Future<void> setCollectionEnabled({required bool enabled}) async {}

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
  Future<void> logScreenView(String name) async {
    _logger.debug('[analytics] screen $name');
  }

  @override
  Future<void> setUserId(String? userId) async {
    _logger.debug('[analytics] user id ${userId == null ? 'cleared' : 'set'}');
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    _logger.debug('[analytics] property $name set');
  }

  @override
  Future<void> setCollectionEnabled({required bool enabled}) async {
    _logger.debug('[analytics] collection ${enabled ? 'on' : 'off'}');
  }

  @override
  Future<void> reset() async {
    _logger.debug('[analytics] reset');
  }
}

/// The analytics service: Firebase Analytics when `AppConfig.enableAnalytics`
/// is on AND Firebase is configured, otherwise Noop (D-042).
@Riverpod(keepAlive: true)
AnalyticsService analyticsService(Ref ref) {
  final config = ref.watch(appConfigProvider);
  if (!config.enableAnalytics || !ref.watch(firebaseAvailableProvider)) {
    return const NoopAnalyticsService();
  }
  return FirebaseAnalyticsService(ref.watch(analyticsBackendProvider));
}
