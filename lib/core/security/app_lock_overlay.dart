import 'dart:async';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/design_system/widgets/security/app_lock_screen.dart';
import 'package:riverpod_core/core/security/app_lock_controller.dart';
import 'package:riverpod_core/core/security/biometric_service.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Puts the lock screen over [child] (not a route, so it also covers dialogs
/// and sheets). Mount it once, in `MaterialApp.builder`. Prompts on its own
/// when the app becomes locked; the button asks again after a cancel.
class AppLockOverlay extends ConsumerStatefulWidget {
  const AppLockOverlay({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockOverlay> createState() => _AppLockOverlayState();
}

class _AppLockOverlayState extends ConsumerState<AppLockOverlay> {
  @override
  void initState() {
    super.initState();
    // Cold start with the lock on: prompt once the first frame is up.
    WidgetsBinding.instance.addPostFrameCallback((_) => _promptIfLocked());
  }

  void _promptIfLocked() {
    if (!mounted) return;
    if (ref.read(appLockControllerProvider).locked) _unlock();
  }

  void _unlock() =>
      unawaited(ref.read(appLockControllerProvider.notifier).unlock());

  @override
  Widget build(BuildContext context) {
    ref.listen(appLockControllerProvider, (previous, next) {
      // Prompt as soon as the app is back and locked, not only on tap.
      if (next.locked && !(previous?.locked ?? false)) _promptIfLocked();
    });
    final state = ref.watch(appLockControllerProvider);
    final covered = state.locked || state.obscured;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Nothing under the cover may take focus or be read by a screen reader.
        ExcludeFocus(
          excluding: covered,
          child: ExcludeSemantics(excluding: covered, child: widget.child),
        ),
        if (covered)
          AppLockScreen(
            onUnlock: state.locked && !state.unlocking ? _unlock : null,
            message: switch (state.lastResult) {
              BiometricResult.lockedOut =>
                LocaleKeys.security_settings_lockedOut.tr(),
              BiometricResult.failed =>
                LocaleKeys.security_settings_failed.tr(),
              _ => null,
            },
          ),
      ],
    );
  }
}
