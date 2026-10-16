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
  int resetCount = 0;

  @override
  Future<void> logEvent(String name, {Map<String, Object?>? params}) async {
    events.add(RecordedEvent(name, params));
  }

  @override
  Future<void> setUserId(String? userId) async {
    userIds.add(userId);
  }

  @override
  Future<void> reset() async {
    resetCount++;
  }
}
