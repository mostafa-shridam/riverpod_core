// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prefs_storage.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Settings store for the whole app. Awaits `SharedPreferences` once.

@ProviderFor(prefsStorage)
final prefsStorageProvider = PrefsStorageProvider._();

/// Settings store for the whole app. Awaits `SharedPreferences` once.

final class PrefsStorageProvider
    extends
        $FunctionalProvider<
          AsyncValue<PrefsStorage>,
          PrefsStorage,
          FutureOr<PrefsStorage>
        >
    with $FutureModifier<PrefsStorage>, $FutureProvider<PrefsStorage> {
  /// Settings store for the whole app. Awaits `SharedPreferences` once.
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

String _$prefsStorageHash() => r'c345a51e4d6b85b2bd9f759559c0af6019708151';
