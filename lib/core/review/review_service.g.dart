// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Platform seam: override in tests with a fake.

@ProviderFor(reviewBackend)
final reviewBackendProvider = ReviewBackendProvider._();

/// Platform seam: override in tests with a fake.

final class ReviewBackendProvider
    extends $FunctionalProvider<ReviewBackend, ReviewBackend, ReviewBackend>
    with $Provider<ReviewBackend> {
  /// Platform seam: override in tests with a fake.
  ReviewBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewBackendHash();

  @$internal
  @override
  $ProviderElement<ReviewBackend> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReviewBackend create(Ref ref) {
    return reviewBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewBackend>(value),
    );
  }
}

String _$reviewBackendHash() => r'49a6d7629ce980e64c5f433a7fa300d889f58ad4';

/// Clock of the review throttle: override in tests.

@ProviderFor(reviewClock)
final reviewClockProvider = ReviewClockProvider._();

/// Clock of the review throttle: override in tests.

final class ReviewClockProvider
    extends
        $FunctionalProvider<
          DateTime Function(),
          DateTime Function(),
          DateTime Function()
        >
    with $Provider<DateTime Function()> {
  /// Clock of the review throttle: override in tests.
  ReviewClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewClockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewClockHash();

  @$internal
  @override
  $ProviderElement<DateTime Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DateTime Function() create(Ref ref) {
    return reviewClock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime Function()>(value),
    );
  }
}

String _$reviewClockHash() => r'59a0b05e086e0fc00d1db8db63e29812ba47f0be';

/// The iOS App Store id used by the store-listing fallback. Null by default:
/// an app overrides it with its own id.

@ProviderFor(appStoreId)
final appStoreIdProvider = AppStoreIdProvider._();

/// The iOS App Store id used by the store-listing fallback. Null by default:
/// an app overrides it with its own id.

final class AppStoreIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// The iOS App Store id used by the store-listing fallback. Null by default:
  /// an app overrides it with its own id.
  AppStoreIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appStoreIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStoreIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return appStoreId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$appStoreIdHash() => r'8df6d9f766f8482e68b27af1de79701007d82b43';

/// The one way features ask for a review.

@ProviderFor(reviewService)
final reviewServiceProvider = ReviewServiceProvider._();

/// The one way features ask for a review.

final class ReviewServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReviewService>,
          ReviewService,
          FutureOr<ReviewService>
        >
    with $FutureModifier<ReviewService>, $FutureProvider<ReviewService> {
  /// The one way features ask for a review.
  ReviewServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewServiceHash();

  @$internal
  @override
  $FutureProviderElement<ReviewService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReviewService> create(Ref ref) {
    return reviewService(ref);
  }
}

String _$reviewServiceHash() => r'b6efa6c8af5b595d079e5621ba0547b6843cec41';
