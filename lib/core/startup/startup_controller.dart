import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';
import 'package:riverpod_core/core/remote_config/remote_config_provider.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

part 'startup_controller.g.dart';

/// How long the splash stays up at least, so a fast start does not flash it.
/// Tests override it with zero.
@Riverpod(keepAlive: true)
Duration splashMinimumDisplay(Ref ref) => const Duration(milliseconds: 800);

/// How long startup waits for the remote config. Past it, the app starts with
/// the cached copy or the defaults.
@Riverpod(keepAlive: true)
Duration splashRemoteConfigTimeout(Ref ref) => const Duration(seconds: 3);

/// The startup sequence. Config is already validated in bootstrap. Mandatory
/// steps: the session restore, then the settings read (it carries the
/// onboarding-seen flag). A failed step leaves the state in error, so the
/// splash shows retry; retry is `ref.invalidate(startupControllerProvider)`.
/// The remote config is optional: it never blocks or fails startup.
@Riverpod(keepAlive: true)
class StartupController extends _$StartupController {
  @override
  Future<void> build() async {
    final shown = Future<void>.delayed(ref.read(splashMinimumDisplayProvider));
    await ref.read(sessionControllerProvider.notifier).restore();
    await ref.read(prefsStorageProvider.future);
    await _loadRemoteConfig();
    await shown;
  }

  Future<void> _loadRemoteConfig() async {
    try {
      await ref
          .read(remoteConfigProvider.future)
          .timeout(ref.read(splashRemoteConfigTimeoutProvider));
    } catch (error, stackTrace) {
      ref
          .read(loggerProvider)
          .warning(
            'Remote config unavailable; using cached or default values',
            error: error,
            stackTrace: stackTrace,
          );
    }
  }
}

/// True once the startup sequence has finished. The router waits for it.
@Riverpod(keepAlive: true)
bool startupReady(Ref ref) => ref.watch(startupControllerProvider).hasValue;
