import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

part 'startup_controller.g.dart';

/// How long the splash stays up at least, so a fast start does not flash it.
/// Tests override it with zero.
@Riverpod(keepAlive: true)
Duration splashMinimumDisplay(Ref ref) => const Duration(milliseconds: 800);

/// The startup sequence. Config is already validated in bootstrap. Mandatory
/// steps: the session restore, then the settings read (it carries the
/// onboarding-seen flag). A failed step leaves the state in error, so the
/// splash shows retry; retry is `ref.invalidate(startupControllerProvider)`.
/// Remote flags join this sequence later.
@Riverpod(keepAlive: true)
class StartupController extends _$StartupController {
  @override
  Future<void> build() async {
    final shown = Future<void>.delayed(ref.read(splashMinimumDisplayProvider));
    await ref.read(sessionControllerProvider.notifier).restore();
    await ref.read(prefsStorageProvider.future);
    await shown;
  }
}

/// True once the startup sequence has finished. The router waits for it.
@Riverpod(keepAlive: true)
bool startupReady(Ref ref) => ref.watch(startupControllerProvider).hasValue;
