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
}
