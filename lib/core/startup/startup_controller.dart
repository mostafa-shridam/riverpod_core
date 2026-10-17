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

/// The clock the minimum display time is measured on. Tests move it by hand.
@Riverpod(keepAlive: true)
DateTime Function() startupClock(Ref ref) => DateTime.now;

/// How often the splash checks the clock while it holds.
const _holdPoll = Duration(milliseconds: 20);

/// The startup sequence. Config is already validated in bootstrap. Mandatory
/// steps: the session restore, then the settings read (it carries the
/// onboarding-seen flag). A failed step leaves the state in error, so the
/// splash shows retry; retry is `ref.invalidate(startupControllerProvider)`.
/// The remote config is optional: it never blocks or fails startup.
@Riverpod(keepAlive: true)
class StartupController extends _$StartupController {
  @override
  Future<void> build() async {
    final clock = ref.read(startupClockProvider);
    final deadline = clock().add(ref.read(splashMinimumDisplayProvider));
    await ref.read(sessionControllerProvider.notifier).restore();
    await ref.read(prefsStorageProvider.future);
    await _loadRemoteConfig();
    await _holdUntil(deadline, clock);
  }

  /// Waits until [clock] reaches [deadline]. A clock already past it returns
  /// at once, so the wait is decided by the clock, not by a timer.
  Future<void> _holdUntil(DateTime deadline, DateTime Function() clock) async {
    for (var left = deadline.difference(clock()); left > Duration.zero;) {
      await Future<void>.delayed(left < _holdPoll ? left : _holdPoll);
      left = deadline.difference(clock());
    }
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
