// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prefs_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Settings store for the whole app, on the box bootstrap opened. Async so
/// callers keep the same `.future` and `.value` API as before the Hive port.

@ProviderFor(prefsStorage)
final prefsStorageProvider = PrefsStorageProvider._();

/// Settings store for the whole app, on the box bootstrap opened. Async so
/// callers keep the same `.future` and `.value` API as before the Hive port.

final class PrefsStorageProvider
    extends
        $FunctionalProvider<
          AsyncValue<PrefsStorage>,
          PrefsStorage,
          FutureOr<PrefsStorage>
        >
    with $FutureModifier<PrefsStorage>, $FutureProvider<PrefsStorage> {
  /// Settings store for the whole app, on the box bootstrap opened. Async so
  /// callers keep the same `.future` and `.value` API as before the Hive port.
  PrefsStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'prefsStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$prefsStorageHash();

  @$internal
  @override
  $FutureProviderElement<PrefsStorage> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PrefsStorage> create(Ref ref) {
    return prefsStorage(ref);
  }
}

String _$prefsStorageHash() => r'e025b6589c4a1ee03dbf02c58a8f74ec41850892';
