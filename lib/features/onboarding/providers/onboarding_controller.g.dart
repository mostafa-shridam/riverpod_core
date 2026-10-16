// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Carousel state: the index of the slide shown now. Finishing stores the
/// onboarding-seen flag; the router then leaves onboarding by itself.

@ProviderFor(OnboardingController)
final onboardingControllerProvider = OnboardingControllerProvider._();

/// Carousel state: the index of the slide shown now. Finishing stores the
/// onboarding-seen flag; the router then leaves onboarding by itself.
final class OnboardingControllerProvider
    extends $NotifierProvider<OnboardingController, int> {
  /// Carousel state: the index of the slide shown now. Finishing stores the
  /// onboarding-seen flag; the router then leaves onboarding by itself.
  OnboardingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingControllerHash();

  @$internal
  @override
  OnboardingController create() => OnboardingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$onboardingControllerHash() =>
    r'08f41d5d9dc986860e7e946aae7b7a9875a21b48';

/// Carousel state: the index of the slide shown now. Finishing stores the
/// onboarding-seen flag; the router then leaves onboarding by itself.

abstract class _$OnboardingController extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
