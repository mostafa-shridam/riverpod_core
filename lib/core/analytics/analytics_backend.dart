import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics_backend.g.dart';

/// The Firebase Analytics calls the app uses, so tests never need the plugin.
abstract interface class AnalyticsBackend {
  Future<void> logEvent(String name, Map<String, Object>? parameters);

  Future<void> logScreenView(String screenName);

  Future<void> setUserId(String? id);

  Future<void> setUserProperty(String name, String? value);

  Future<void> setCollectionEnabled({required bool enabled});

  Future<void> resetAnalyticsData();
}

/// [AnalyticsBackend] on `firebase_analytics`. Touches the plugin only when a
/// method is called, which happens only after Firebase started.
class FirebaseAnalyticsBackend implements AnalyticsBackend {
  const FirebaseAnalyticsBackend();

  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  @override
  Future<void> logEvent(String name, Map<String, Object>? parameters) =>
      _analytics.logEvent(name: name, parameters: parameters);

  @override
  Future<void> logScreenView(String screenName) =>
      _analytics.logScreenView(screenName: screenName);

  @override
  Future<void> setUserId(String? id) => _analytics.setUserId(id: id);

  @override
  Future<void> setUserProperty(String name, String? value) =>
      _analytics.setUserProperty(name: name, value: value);

  @override
  Future<void> setCollectionEnabled({required bool enabled}) =>
      _analytics.setAnalyticsCollectionEnabled(enabled);

  @override
  Future<void> resetAnalyticsData() => _analytics.resetAnalyticsData();
}

/// Platform seam for Firebase Analytics: override in tests.
@Riverpod(keepAlive: true)
AnalyticsBackend analyticsBackend(Ref ref) => const FirebaseAnalyticsBackend();
