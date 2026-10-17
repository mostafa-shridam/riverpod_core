import 'package:riverpod_core/core/analytics/analytics_backend.dart';
import 'package:riverpod_core/core/analytics/analytics_service.dart';

/// One event recorded by [FakeAnalytics].
class RecordedEvent {
  const RecordedEvent(this.name, this.params);

  final String name;
  final Map<String, Object?>? params;
}

/// In-memory [AnalyticsService] that records what it receives.
class FakeAnalytics implements AnalyticsService {
  final List<RecordedEvent> events = [];
  final List<String?> userIds = [];
  final List<String> screens = [];
  final Map<String, String?> properties = {};
  final List<bool> collection = [];
  int resetCount = 0;

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? params}) async {
    events.add(RecordedEvent(name, params));
  }

  @override
  Future<void> logScreenView(String name) async {
    screens.add(name);
  }

  @override
  Future<void> setUserId(String? userId) async {
    userIds.add(userId);
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    properties[name] = value;
  }

  @override
  Future<void> setCollectionEnabled({required bool enabled}) async {
    collection.add(enabled);
  }

  @override
  Future<void> reset() async {
    resetCount++;
  }
}

/// In-memory [AnalyticsBackend] (the Firebase Analytics seam).
class FakeAnalyticsBackend implements AnalyticsBackend {
  final List<RecordedEvent> events = [];
  final List<String> screens = [];
  final List<String?> userIds = [];
  final Map<String, String?> properties = {};
  final List<bool> collection = [];
  int resetCount = 0;

  @override
  Future<void> logEvent(String name, Map<String, Object>? parameters) async {
    events.add(RecordedEvent(name, parameters));
  }

  @override
  Future<void> logScreenView(String screenName) async {
    screens.add(screenName);
  }

  @override
  Future<void> setUserId(String? id) async {
    userIds.add(id);
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    properties[name] = value;
  }

  @override
  Future<void> setCollectionEnabled({required bool enabled}) async {
    collection.add(enabled);
  }

  @override
  Future<void> resetAnalyticsData() async {
    resetCount++;
  }
}
