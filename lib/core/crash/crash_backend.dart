import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'crash_backend.g.dart';

/// The Crashlytics calls the app uses, so tests never need the plugin.
abstract interface class CrashBackend {
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    required bool fatal,
    String? reason,
  });

  Future<void> setUserIdentifier(String identifier);

  Future<void> setCustomKey(String key, Object value);

  Future<void> log(String message);

  Future<void> setCollectionEnabled({required bool enabled});
}

/// [CrashBackend] on `firebase_crashlytics`. Touches the plugin only when a
/// method is called, which happens only after Firebase started.
class CrashlyticsBackend implements CrashBackend {
  const CrashlyticsBackend();

  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    required bool fatal,
    String? reason,
  }) =>
      _crashlytics.recordError(error, stackTrace, fatal: fatal, reason: reason);

  @override
  Future<void> setUserIdentifier(String identifier) =>
      _crashlytics.setUserIdentifier(identifier);

  @override
  Future<void> setCustomKey(String key, Object value) =>
      _crashlytics.setCustomKey(key, value);

  @override
  Future<void> log(String message) => _crashlytics.log(message);

  @override
  Future<void> setCollectionEnabled({required bool enabled}) =>
      _crashlytics.setCrashlyticsCollectionEnabled(enabled);
}

/// Platform seam for Crashlytics: override in tests.
@Riverpod(keepAlive: true)
CrashBackend crashBackend(Ref ref) => const CrashlyticsBackend();
