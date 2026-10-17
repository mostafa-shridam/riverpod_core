// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_prune_scheduler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The scheduler for the whole app. Stops listening when the container goes.

@ProviderFor(cachePruneScheduler)
final cachePruneSchedulerProvider = CachePruneSchedulerProvider._();

/// The scheduler for the whole app. Stops listening when the container goes.

final class CachePruneSchedulerProvider
    extends
        $FunctionalProvider<
          CachePruneScheduler,
          CachePruneScheduler,
          CachePruneScheduler
        >
    with $Provider<CachePruneScheduler> {
  /// The scheduler for the whole app. Stops listening when the container goes.
  CachePruneSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cachePruneSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cachePruneSchedulerHash();

  @$internal
  @override
  $ProviderElement<CachePruneScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CachePruneScheduler create(Ref ref) {
    return cachePruneScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CachePruneScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CachePruneScheduler>(value),
    );
  }
}

String _$cachePruneSchedulerHash() =>
    r'b7f4802fb120f3742c1563eb95cd546fe3a0a4d9';
