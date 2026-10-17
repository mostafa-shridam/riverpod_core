import 'package:riverpod_core/core/analytics/analytics_backend.dart';
import 'package:riverpod_core/core/analytics/analytics_service.dart';

/// [AnalyticsService] on Firebase Analytics. Selected only when Firebase is
/// configured (D-042).
class FirebaseAnalyticsService implements AnalyticsService {
  const FirebaseAnalyticsService(this._backend);

  final AnalyticsBackend _backend;

  /// Firebase accepts only String and num parameters: nulls are dropped, bools
  /// become 1/0 and anything else is sent as its string.
  @override
  Future<void> logEvent(String name, {Map<String, Object?>? params}) =>
      _backend.logEvent(name, _clean(params));

  @override
  Future<void> logScreenView(String name) => _backend.logScreenView(name);

  @override
  Future<void> setUserId(String? userId) => _backend.setUserId(userId);

  @override
  Future<void> setUserProperty(String name, String? value) =>
      _backend.setUserProperty(name, value);

  @override
  Future<void> setCollectionEnabled({required bool enabled}) =>
      _backend.setCollectionEnabled(enabled: enabled);

  @override
  Future<void> reset() => _backend.resetAnalyticsData();

  static Map<String, Object>? _clean(Map<String, Object?>? params) {
    if (params == null) return null;
    final cleaned = <String, Object>{};
    for (final entry in params.entries) {
      final value = entry.value;
      if (value == null) continue;
      cleaned[entry.key] = switch (value) {
        final String s => s,
        final num n => n,
        final bool b => b ? 1 : 0,
        _ => value.toString(),
      };
    }
    return cleaned;
  }
}
