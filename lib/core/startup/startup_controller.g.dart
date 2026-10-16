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

/// The startup sequence. Config is already validated in bootstrap. Mandatory
/// steps: the session restore, then the settings read (it carries the
/// onboarding-seen flag). A failed step leaves the state in error, so the
/// splash shows retry; retry is `ref.invalidate(startupControllerProvider)`.
/// Remote flags join this sequence later.

@ProviderFor(StartupController)
final startupControllerProvider = StartupControllerProvider._();

/// The startup sequence. Config is already validated in bootstrap. Mandatory
/// steps: the session restore, then the settings read (it carries the
/// onboarding-seen flag). A failed step leaves the state in error, so the
/// splash shows retry; retry is `ref.invalidate(startupControllerProvider)`.
/// Remote flags join this sequence later.
final class StartupControllerProvider
    extends $AsyncNotifierProvider<StartupController, void> {
  /// The startup sequence. Config is already validated in bootstrap. Mandatory
  /// steps: the session restore, then the settings read (it carries the
  /// onboarding-seen flag). A failed step leaves the state in error, so the
  /// splash shows retry; retry is `ref.invalidate(startupControllerProvider)`.
  /// Remote flags join this sequence later.
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

String _$startupControllerHash() => r'0452a6a6695a33d0da1b01c4dc55bd2c42ffb33a';

/// The startup sequence. Config is already validated in bootstrap. Mandatory
/// steps: the session restore, then the settings read (it carries the
/// onboarding-seen flag). A failed step leaves the state in error, so the
/// splash shows retry; retry is `ref.invalidate(startupControllerProvider)`.
/// Remote flags join this sequence later.

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
