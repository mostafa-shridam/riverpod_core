// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State and actions of one transfer. AutoDispose: leaving the screen cancels
/// a running transfer.

@ProviderFor(TransferController)
final transferControllerProvider = TransferControllerProvider._();

/// State and actions of one transfer. AutoDispose: leaving the screen cancels
/// a running transfer.
final class TransferControllerProvider
    extends $NotifierProvider<TransferController, TransferState> {
  /// State and actions of one transfer. AutoDispose: leaving the screen cancels
  /// a running transfer.
  TransferControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transferControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transferControllerHash();

  @$internal
  @override
  TransferController create() => TransferController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransferState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransferState>(value),
    );
  }
}

String _$transferControllerHash() =>
    r'90332f7da50ef17ac1a277d4cbb0886d2a182382';

/// State and actions of one transfer. AutoDispose: leaving the screen cancels
/// a running transfer.

abstract class _$TransferController extends $Notifier<TransferState> {
  TransferState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TransferState, TransferState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TransferState, TransferState>,
              TransferState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
