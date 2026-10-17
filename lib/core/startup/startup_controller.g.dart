// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'startup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How long the splash stays up at least, so a fast start does not flash it.
/// Tests override it with zero.

@ProviderFor(splashMinimumDisplay)
final splashMinimumDisplayProvider = SplashMinimumDisplayProvider._();

/// How long the splash stays up at least, so a fast start does not flash it.
/// Tests override it with zero.

final class SplashMinimumDisplayProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// How long the splash stays up at least, so a fast start does not flash it.
  /// Tests override it with zero.
  SplashMinimumDisplayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splashMinimumDisplayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splashMinimumDisplayHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return splashMinimumDisplay(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$splashMinimumDisplayHash() =>
    r'3e54fa8b6c4fca254bef2462f279cf74e3e48d21';

/// How long startup waits for the remote config. Past it, the app starts with
/// the cached copy or the defaults.

@ProviderFor(splashRemoteConfigTimeout)
final splashRemoteConfigTimeoutProvider = SplashRemoteConfigTimeoutProvider._();

/// How long startup waits for the remote config. Past it, the app starts with
/// the cached copy or the defaults.

final class SplashRemoteConfigTimeoutProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// How long startup waits for the remote config. Past it, the app starts with
  /// the cached copy or the defaults.
  SplashRemoteConfigTimeoutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splashRemoteConfigTimeoutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splashRemoteConfigTimeoutHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return splashRemoteConfigTimeout(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$splashRemoteConfigTimeoutHash() =>
    r'078db055fa554db62f9a3c6844a8e746b2735acb';

/// The startup sequence. Config is already validated in bootstrap. Mandatory
/// steps: the session restore, then the settings read (it carries the
/// onboarding-seen flag). A failed step leaves the state in error, so the
/// splash shows retry; retry is `ref.invalidate(startupControllerProvider)`.
/// The remote config is optional: it never blocks or fails startup.

@ProviderFor(StartupController)
final startupControllerProvider = StartupControllerProvider._();

/// The startup sequence. Config is already validated in bootstrap. Mandatory
/// steps: the session restore, then the settings read (it carries the
/// onboarding-seen flag). A failed step leaves the state in error, so the
/// splash shows retry; retry is `ref.invalidate(startupControllerProvider)`.
/// The remote config is optional: it never blocks or fails startup.
final class StartupControllerProvider
    extends $AsyncNotifierProvider<StartupController, void> {
  /// The startup sequence. Config is already validated in bootstrap. Mandatory
  /// steps: the session restore, then the settings read (it carries the
  /// onboarding-seen flag). A failed step leaves the state in error, so the
  /// splash shows retry; retry is `ref.invalidate(startupControllerProvider)`.
  /// The remote config is optional: it never blocks or fails startup.
  StartupControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startupControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startupControllerHash();

  @$internal
  @override
  StartupController create() => StartupController();
}

String _$startupControllerHash() => r'1d1bf8dc9e9df8f50134925e4fee7d8751f7ddbc';

/// The startup sequence. Config is already validated in bootstrap. Mandatory
/// steps: the session restore, then the settings read (it carries the
/// onboarding-seen flag). A failed step leaves the state in error, so the
/// splash shows retry; retry is `ref.invalidate(startupControllerProvider)`.
/// The remote config is optional: it never blocks or fails startup.

abstract class _$StartupController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// True once the startup sequence has finished. The router waits for it.

@ProviderFor(startupReady)
final startupReadyProvider = StartupReadyProvider._();

/// True once the startup sequence has finished. The router waits for it.

final class StartupReadyProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// True once the startup sequence has finished. The router waits for it.
  StartupReadyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startupReadyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startupReadyHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return startupReady(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$startupReadyHash() => r'b1697ea1a97d8bb5e33e2d38d1ddeb83c66e5a17';
