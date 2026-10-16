// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's chosen locale, persisted in prefs. The UI switches through
/// [changeAppLocale]; this controller is the source of truth for the choice.

@ProviderFor(LocaleController)
final localeControllerProvider = LocaleControllerProvider._();

/// The user's chosen locale, persisted in prefs. The UI switches through
/// [changeAppLocale]; this controller is the source of truth for the choice.
final class LocaleControllerProvider
    extends $AsyncNotifierProvider<LocaleController, Locale> {
  /// The user's chosen locale, persisted in prefs. The UI switches through
  /// [changeAppLocale]; this controller is the source of truth for the choice.
  LocaleControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeControllerHash();

  @$internal
  @override
  LocaleController create() => LocaleController();
}

String _$localeControllerHash() => r'a828558268882f2b10a3761d70c5d51f579ffc38';

/// The user's chosen locale, persisted in prefs. The UI switches through
/// [changeAppLocale]; this controller is the source of truth for the choice.

abstract class _$LocaleController extends $AsyncNotifier<Locale> {
  FutureOr<Locale> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Locale>, Locale>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Locale>, Locale>,
              AsyncValue<Locale>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Formatters for the current locale. Falls back to English while the saved
/// locale is still loading.

@ProviderFor(appFormatters)
final appFormattersProvider = AppFormattersProvider._();

/// Formatters for the current locale. Falls back to English while the saved
/// locale is still loading.

final class AppFormattersProvider
    extends $FunctionalProvider<AppFormatters, AppFormatters, AppFormatters>
    with $Provider<AppFormatters> {
  /// Formatters for the current locale. Falls back to English while the saved
  /// locale is still loading.
  AppFormattersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appFormattersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appFormattersHash();

  @$internal
  @override
  $ProviderElement<AppFormatters> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppFormatters create(Ref ref) {
    return appFormatters(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppFormatters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppFormatters>(value),
    );
  }
}

String _$appFormattersHash() => r'e7c221dfc76aa9bcec0e61bf77b04b6ec03c2614';
