import 'package:riverpod_core/core/crash/crash_backend.dart';
import 'package:riverpod_core/core/crash/crash_reporter.dart';

/// One call recorded by [FakeCrashReporter].
class RecordedCrash {
  const RecordedCrash(this.error, this.stackTrace, this.fatal, this.reason);

  final Object error;
  final StackTrace? stackTrace;
  final bool fatal;
  final String? reason;
}

/// In-memory [CrashReporter] that records what it receives.
class FakeCrashReporter implements CrashReporter {
  final List<RecordedCrash> errors = [];
  final List<String?> userIds = [];
  final Map<String, Object> keys = {};
  final List<String> logs = [];
  final List<bool> collection = [];

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
    String? reason,
  }) async {
    errors.add(RecordedCrash(error, stackTrace, fatal, reason));
  }

  @override
  Future<void> setUserId(String? userId) async {
    userIds.add(userId);
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    keys[key] = value;
  }

  @override
  Future<void> log(String message) async {
    logs.add(message);
  }

  @override
  Future<void> setCollectionEnabled({required bool enabled}) async {
    collection.add(enabled);
  }
}

/// In-memory [CrashBackend] (the Crashlytics seam) that records its calls.
class FakeCrashBackend implements CrashBackend {
  final List<RecordedCrash> errors = [];
  final List<String> userIdentifiers = [];
  final Map<String, Object> keys = {};
  final List<String> logs = [];
  final List<bool> collection = [];

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    required bool fatal,
    String? reason,
  }) async {
    errors.add(RecordedCrash(error, stackTrace, fatal, reason));
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    userIdentifiers.add(identifier);
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    keys[key] = value;
  }

  @override
  Future<void> log(String message) async {
    logs.add(message);
  }

  @override
  Future<void> setCollectionEnabled({required bool enabled}) async {
    collection.add(enabled);
  }
}
