import 'package:riverpod_core/core/crash/crash_backend.dart';
import 'package:riverpod_core/core/crash/crash_reporter.dart';

/// [CrashReporter] on Firebase Crashlytics. Selected only when Firebase is
/// configured (D-042).
class FirebaseCrashReporter implements CrashReporter {
  const FirebaseCrashReporter(this._backend);

  final CrashBackend _backend;

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
    String? reason,
  }) => _backend.recordError(error, stackTrace, fatal: fatal, reason: reason);

  /// Only the opaque user id is sent. A null id sets an empty identifier,
  /// which is how Crashlytics clears it.
  @override
  Future<void> setUserId(String? userId) =>
      _backend.setUserIdentifier(userId ?? '');

  @override
  Future<void> setCustomKey(String key, Object value) =>
      _backend.setCustomKey(key, value);

  @override
  Future<void> log(String message) => _backend.log(message);

  @override
  Future<void> setCollectionEnabled({required bool enabled}) =>
      _backend.setCollectionEnabled(enabled: enabled);
}
