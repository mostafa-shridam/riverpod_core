// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns [NotificationSettings]: loads them from the settings store and saves
/// every change. The master flag lives in `PrefsStorage.notificationsEnabled`.

@ProviderFor(NotificationSettingsController)
final notificationSettingsControllerProvider =
    NotificationSettingsControllerProvider._();

/// Owns [NotificationSettings]: loads them from the settings store and saves
/// every change. The master flag lives in `PrefsStorage.notificationsEnabled`.
final class NotificationSettingsControllerProvider
    extends
        $AsyncNotifierProvider<
          NotificationSettingsController,
          NotificationSettings
        > {
  /// Owns [NotificationSettings]: loads them from the settings store and saves
  /// every change. The master flag lives in `PrefsStorage.notificationsEnabled`.
  NotificationSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSettingsControllerHash();

  @$internal
  @override
  NotificationSettingsController create() => NotificationSettingsController();
}

String _$notificationSettingsControllerHash() =>
    r'd99d78059d6d57d8e40cca698e61da5bd9eee774';

/// Owns [NotificationSettings]: loads them from the settings store and saves
/// every change. The master flag lives in `PrefsStorage.notificationsEnabled`.

abstract class _$NotificationSettingsController
    extends $AsyncNotifier<NotificationSettings> {
  FutureOr<NotificationSettings> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<NotificationSettings>, NotificationSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<NotificationSettings>,
                NotificationSettings
              >,
              AsyncValue<NotificationSettings>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
