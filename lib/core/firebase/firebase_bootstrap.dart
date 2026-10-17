import 'package:firebase_core/firebase_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';

part 'firebase_bootstrap.g.dart';

/// Starts Firebase. Seam: tests override [firebaseInitializer].
typedef FirebaseInitializer = Future<void> Function();

/// Default initializer: the native config files decide whether it works.
@Riverpod(keepAlive: true)
FirebaseInitializer firebaseInitializer(Ref ref) => () async {
  if (Firebase.apps.isEmpty) await Firebase.initializeApp();
};

/// Initializes Firebase at most once for crash, analytics and notifications
/// (D-042). Without `google-services.json` / `GoogleService-Info.plist` the
/// result is false, one line is logged, and nothing throws.
class FirebaseBootstrap {
  FirebaseBootstrap({required this.initializer, required this.logger});

  final FirebaseInitializer initializer;
  final AppLogger logger;
  Future<bool>? _result;

  /// True when Firebase is configured and started. Never throws.
  Future<bool> ensureInitialized() => _result ??= _initialize();

  Future<bool> _initialize() async {
    try {
      await initializer();
      return true;
    } on Object {
      logger.warning('Firebase not configured: crash/analytics disabled');
      return false;
    }
  }
}

/// The one [FirebaseBootstrap] of the app.
@Riverpod(keepAlive: true)
FirebaseBootstrap firebaseBootstrap(Ref ref) => FirebaseBootstrap(
  initializer: ref.watch(firebaseInitializerProvider),
  logger: ref.watch(loggerProvider),
);

/// Whether Firebase started. False until `initObservability` ran, and when
/// the app has no Firebase files. Crash and analytics pick their vendor
/// implementation from it.
@Riverpod(keepAlive: true)
class FirebaseAvailable extends _$FirebaseAvailable {
  @override
  bool build() => false;

  /// Called once by startup with the result of the Firebase init.
  void markAvailable({required bool value}) => state = value;
}
