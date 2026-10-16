// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether onboarding was seen. Null while the settings are still loading.

@ProviderFor(onboardingSeen)
final onboardingSeenProvider = OnboardingSeenProvider._();

/// Whether onboarding was seen. Null while the settings are still loading.

final class OnboardingSeenProvider
    extends $FunctionalProvider<bool?, bool?, bool?>
    with $Provider<bool?> {
  /// Whether onboarding was seen. Null while the settings are still loading.
  OnboardingSeenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingSeenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingSeenHash();

  @$internal
  @override
  $ProviderElement<bool?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool? create(Ref ref) {
    return onboardingSeen(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool?>(value),
    );
  }
}

String _$onboardingSeenHash() => r'ebf2a954397aeca6d93e6888f344df9f163d7d2b';

/// The one router of the app (D-016). Redirects are [appRedirect]; the router
/// re-runs them whenever session or onboarding state changes.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// The one router of the app (D-016). Redirects are [appRedirect]; the router
/// re-runs them whenever session or onboarding state changes.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The one router of the app (D-016). Redirects are [appRedirect]; the router
  /// re-runs them whenever session or onboarding state changes.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'6102564c1962e12a1099513ba39ae3794cd40dab';
