import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/security/biometric_service.dart';
import 'package:riverpod_core/core/security/secure_screen.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

part 'app_lock_controller.freezed.dart';
part 'app_lock_controller.g.dart';

/// Prefs slot of the "app lock on" flag. It is a device setting, so it does
/// not start with `user.` and survives logout. Stored through the generic
/// string-list slot: `['1']` is on, empty is off.

/// How long the app may stay in the background before it asks again. Apps
/// override this provider; zero locks on every return.
@Riverpod(keepAlive: true)
Duration appLockTimeout(Ref ref) => const Duration(seconds: 30);

/// The clock of the app lock: override in tests.
@Riverpod(keepAlive: true)
DateTime Function() appLockClock(Ref ref) => DateTime.now;

/// What the lock overlay needs to know.
@freezed
abstract class AppLockState with _$AppLockState {
  const factory AppLockState({
    /// The user turned app lock on.
    @Default(false) bool enabled,

    /// The content is hidden until the user authenticates.
    @Default(false) bool locked,

    /// The app is not in the foreground: content is hidden in the app
    /// switcher even before the timeout passed.
    @Default(false) bool obscured,

    /// A system prompt is showing.
    @Default(false) bool unlocking,

    /// Result of the last attempt, for the lock screen message.
    BiometricResult? lastResult,
  }) = _AppLockState;
}

/// Optional app lock. Locks when the app comes back after more than
/// [appLockTimeoutProvider] in the background, and at cold start when on.
/// Unlock is a biometric prompt with the device credential as fallback.
@Riverpod(keepAlive: true)
class AppLockController extends _$AppLockController {
  DateTime? _backgroundedAt;
  bool _holdingSecureScreen = false;
  late SecureScreenGate _gate;

  @override
  AppLockState build() {
    final prefs = ref.watch(prefsStorageProvider).value;
    final enabled = prefs?.appLockEnabled ?? false;

    _gate = ref.watch(secureScreenGateProvider);
    final observer = _LifecycleObserver(onLifecycle);
    WidgetsBinding.instance.addObserver(observer);
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(observer);
      _holdSecureScreen(want: false);
    });

    _holdSecureScreen(want: enabled);
    return AppLockState(enabled: enabled, locked: enabled);
  }

  /// Feeds the app lifecycle in. Public so tests drive it directly.
  void onLifecycle(AppLifecycleState lifecycle) {
    // The system prompt itself pauses the app on some platforms.
    if (!state.enabled || state.unlocking) return;
    if (lifecycle == AppLifecycleState.resumed) {
      final since = _backgroundedAt;
      _backgroundedAt = null;
      final expired =
          since != null &&
          ref.read(appLockClockProvider)().difference(since) >=
              ref.read(appLockTimeoutProvider);
      state = state.copyWith(obscured: false, locked: state.locked || expired);
    } else {
      _backgroundedAt ??= ref.read(appLockClockProvider)();
      state = state.copyWith(obscured: true);
    }
  }

  /// Asks the user to authenticate. Never throws; the result is also in
  /// [AppLockState.lastResult]. When the device has no biometrics and no
  /// passcode any more, the lock cannot protect anything: it turns itself
  /// off so the user is not locked out.
  Future<BiometricResult> unlock() async {
    if (!state.locked) return BiometricResult.success;
    if (state.unlocking) return BiometricResult.cancelled;
    state = state.copyWith(unlocking: true);
    final result = await ref
        .read(biometricServiceProvider)
        .authenticate(LocaleKeys.security_lock_reason);
    switch (result) {
      case BiometricResult.success:
        _backgroundedAt = null;
        state = state.copyWith(
          unlocking: false,
          locked: false,
          lastResult: null,
        );
      case BiometricResult.notAvailable:
        await _persist(enabled: false);
        _holdSecureScreen(want: false);
        state = state.copyWith(
          unlocking: false,
          enabled: false,
          locked: false,
          obscured: false,
          lastResult: result,
        );
      case BiometricResult.cancelled ||
          BiometricResult.failed ||
          BiometricResult.lockedOut:
        state = state.copyWith(unlocking: false, lastResult: result);
    }
    return result;
  }

  /// Turns app lock on or off. Turning on needs one successful
  /// authentication first, so the user cannot lock themselves out; anything
  /// else leaves the setting unchanged and is returned as the result.
  Future<BiometricResult> setEnabled({required bool enabled}) async {
    if (enabled == state.enabled) return BiometricResult.success;
    if (enabled) {
      state = state.copyWith(unlocking: true);
      final result = await ref
          .read(biometricServiceProvider)
          .authenticate(LocaleKeys.security_lock_enableReason);
      state = state.copyWith(unlocking: false);
      if (result != BiometricResult.success) return result;
    }
    await _persist(enabled: enabled);
    _holdSecureScreen(want: enabled);
    _backgroundedAt = null;
    state = state.copyWith(
      enabled: enabled,
      locked: false,
      obscured: false,
      lastResult: null,
    );
    return BiometricResult.success;
  }

  Future<void> _persist({required bool enabled}) async {
    final prefs = await ref.read(prefsStorageProvider.future);
    await prefs.setAppLockEnabled(value: enabled);
  }

  /// While app lock is on the whole app is protected, which also hides it
  /// in the app switcher (Android `FLAG_SECURE`, iOS cover view).
  void _holdSecureScreen({required bool want}) {
    if (want == _holdingSecureScreen) return;
    _holdingSecureScreen = want;
    unawaited(want ? _gate.acquire() : _gate.release());
  }
}

class _LifecycleObserver with WidgetsBindingObserver {
  _LifecycleObserver(this._onLifecycle);

  final void Function(AppLifecycleState) _onLifecycle;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      _onLifecycle(state);
}
