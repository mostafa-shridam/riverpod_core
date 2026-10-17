// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_lock_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Prefs slot of the "app lock on" flag. It is a device setting, so it does
/// not start with `user.` and survives logout. Stored through the generic
/// string-list slot: `['1']` is on, empty is off.
/// How long the app may stay in the background before it asks again. Apps
/// override this provider; zero locks on every return.

@ProviderFor(appLockTimeout)
final appLockTimeoutProvider = AppLockTimeoutProvider._();

/// Prefs slot of the "app lock on" flag. It is a device setting, so it does
/// not start with `user.` and survives logout. Stored through the generic
/// string-list slot: `['1']` is on, empty is off.
/// How long the app may stay in the background before it asks again. Apps
/// override this provider; zero locks on every return.

final class AppLockTimeoutProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// Prefs slot of the "app lock on" flag. It is a device setting, so it does
  /// not start with `user.` and survives logout. Stored through the generic
  /// string-list slot: `['1']` is on, empty is off.
  /// How long the app may stay in the background before it asks again. Apps
  /// override this provider; zero locks on every return.
  AppLockTimeoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLockTimeoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLockTimeoutHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return appLockTimeout(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$appLockTimeoutHash() => r'b0990e409640002343b583faea4767c1dc3f4449';

/// The clock of the app lock: override in tests.

@ProviderFor(appLockClock)
final appLockClockProvider = AppLockClockProvider._();

/// The clock of the app lock: override in tests.

final class AppLockClockProvider
    extends
        $FunctionalProvider<
          DateTime Function(),
          DateTime Function(),
          DateTime Function()
        >
    with $Provider<DateTime Function()> {
  /// The clock of the app lock: override in tests.
  AppLockClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLockClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLockClockHash();

  @$internal
  @override
  $ProviderElement<DateTime Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DateTime Function() create(Ref ref) {
    return appLockClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime Function()>(value),
    );
  }
}

String _$appLockClockHash() => r'41bfbf68fae8f2e3341a1494506bdb6a4b20a5fa';

/// Optional app lock. Locks when the app comes back after more than
/// [appLockTimeoutProvider] in the background, and at cold start when on.
/// Unlock is a biometric prompt with the device credential as fallback.

@ProviderFor(AppLockController)
final appLockControllerProvider = AppLockControllerProvider._();

/// Optional app lock. Locks when the app comes back after more than
/// [appLockTimeoutProvider] in the background, and at cold start when on.
/// Unlock is a biometric prompt with the device credential as fallback.
final class AppLockControllerProvider
    extends $NotifierProvider<AppLockController, AppLockState> {
  /// Optional app lock. Locks when the app comes back after more than
  /// [appLockTimeoutProvider] in the background, and at cold start when on.
  /// Unlock is a biometric prompt with the device credential as fallback.
  AppLockControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLockControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLockControllerHash();

  @$internal
  @override
  AppLockController create() => AppLockController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLockState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLockState>(value),
    );
  }
}

String _$appLockControllerHash() => r'c29b2d9cf51ce458f9f7dfffa2a3e639b6a6ad96';

/// Optional app lock. Locks when the app comes back after more than
/// [appLockTimeoutProvider] in the background, and at cold start when on.
/// Unlock is a biometric prompt with the device credential as fallback.

abstract class _$AppLockController extends $Notifier<AppLockState> {
  AppLockState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppLockState, AppLockState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppLockState, AppLockState>,
              AppLockState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
