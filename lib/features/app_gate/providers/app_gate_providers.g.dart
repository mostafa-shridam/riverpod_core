// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_gate_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storeOpener)
final storeOpenerProvider = StoreOpenerProvider._();

final class StoreOpenerProvider
    extends $FunctionalProvider<StoreOpener, StoreOpener, StoreOpener>
    with $Provider<StoreOpener> {
  StoreOpenerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storeOpenerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storeOpenerHash();

  @$internal
  @override
  $ProviderElement<StoreOpener> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StoreOpener create(Ref ref) {
    return storeOpener(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StoreOpener value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StoreOpener>(value),
    );
  }
}

String _$storeOpenerHash() => r'ce89bf4987dd3bb90e1aee3e86859faaacc2258b';

/// Newest versions the user dismissed the soft update notice for. Device
/// setting (not per user), read and written through `PrefsStorage`.

@ProviderFor(DismissedUpdates)
final dismissedUpdatesProvider = DismissedUpdatesProvider._();

/// Newest versions the user dismissed the soft update notice for. Device
/// setting (not per user), read and written through `PrefsStorage`.
final class DismissedUpdatesProvider
    extends $AsyncNotifierProvider<DismissedUpdates, List<String>> {
  /// Newest versions the user dismissed the soft update notice for. Device
  /// setting (not per user), read and written through `PrefsStorage`.
  DismissedUpdatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dismissedUpdatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dismissedUpdatesHash();

  @$internal
  @override
  DismissedUpdates create() => DismissedUpdates();
}

String _$dismissedUpdatesHash() => r'8db0eada1d86981c4632dd106d2acb042c7f51ee';

/// Newest versions the user dismissed the soft update notice for. Device
/// setting (not per user), read and written through `PrefsStorage`.

abstract class _$DismissedUpdates extends $AsyncNotifier<List<String>> {
  FutureOr<List<String>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>>, List<String>>,
              AsyncValue<List<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether the soft update notice should show now: the build is behind the
/// latest version and the user has not dismissed that version. False while
/// the dismissals are still loading, so the notice never flashes.

@ProviderFor(softUpdateNotice)
final softUpdateNoticeProvider = SoftUpdateNoticeProvider._();

/// Whether the soft update notice should show now: the build is behind the
/// latest version and the user has not dismissed that version. False while
/// the dismissals are still loading, so the notice never flashes.

final class SoftUpdateNoticeProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the soft update notice should show now: the build is behind the
  /// latest version and the user has not dismissed that version. False while
  /// the dismissals are still loading, so the notice never flashes.
  SoftUpdateNoticeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'softUpdateNoticeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$softUpdateNoticeHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return softUpdateNotice(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$softUpdateNoticeHash() => r'a919e6af7d6b9fbff077b277255542276d9d93d2';
