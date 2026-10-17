import 'package:hive_ce/hive_ce.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_core/core/storage/hive_boxes.dart';

part 'prefs_storage.g.dart';

/// Every settings key the app uses. Keys starting with [userPrefix] belong to
/// the signed-in user and are wiped on logout; the others are device settings.
/// The locale is not stored here: easy_localization persists it (D-035).
abstract final class PrefKeys {
  static const themeMode = 'settings.themeMode';
  static const onboardingSeen = 'settings.onboardingSeen';
  static const appLock = 'settings.appLock';
  static const collectionConsent = 'settings.collectionConsent';

  static const dismissedUpdateVersions = 'app.remoteConfig.dismissedUpdates';

  static const userPrefix = 'user.';
  static const notificationsEnabled = 'user.notificationsEnabled';
  static const disabledNotificationChannels =
      'user.notifications.disabledChannels';
}

/// Settings store on the Hive settings box. Secrets never go here (see
/// `SecureStorage`), and cached data never goes here (see `CacheStore`).
class PrefsStorage {
  PrefsStorage(this._box);

  final Box<dynamic> _box;

  String? get themeMode => _box.get(PrefKeys.themeMode) as String?;

  Future<bool> setThemeMode(String value) => _put(PrefKeys.themeMode, value);

  bool get onboardingSeen =>
      (_box.get(PrefKeys.onboardingSeen) as bool?) ?? false;

  Future<bool> setOnboardingSeen({required bool value}) =>
      _put(PrefKeys.onboardingSeen, value);

  bool get notificationsEnabled =>
      (_box.get(PrefKeys.notificationsEnabled) as bool?) ?? true;

  Future<bool> setNotificationsEnabled({required bool value}) =>
      _put(PrefKeys.notificationsEnabled, value);

  /// Whether the app lock is on. Stored as `['1']` when on, `[]` when off, the
  /// same encoding the generic slot callers already write.
  bool get appLockEnabled => getStringList(PrefKeys.appLock).contains('1');

  Future<bool> setAppLockEnabled({required bool value}) =>
      setStringList(PrefKeys.appLock, value ? const ['1'] : const []);

  /// The crash and analytics collection switch. Null until the user chooses, so
  /// the caller applies its default. Device-level: it survives logout.
  bool? get collectionConsent => _box.get(PrefKeys.collectionConsent) as bool?;

  Future<bool> setCollectionConsent({required bool value}) =>
      _put(PrefKeys.collectionConsent, value);

  /// Versions whose soft update notice the user dismissed.
  List<String> get dismissedUpdateVersions =>
      getStringList(PrefKeys.dismissedUpdateVersions);

  Future<bool> setDismissedUpdateVersions(List<String> value) =>
      setStringList(PrefKeys.dismissedUpdateVersions, value);

  /// Notification channel ids the user turned off.
  List<String> get disabledNotificationChannels =>
      getStringList(PrefKeys.disabledNotificationChannels);

  Future<bool> setDisabledNotificationChannels(List<String> value) =>
      setStringList(PrefKeys.disabledNotificationChannels, value);

  /// Generic string-list slot for features (for example favorite ids). Name
  /// the key `user.<feature>.<name>` when it belongs to the signed-in user, so
  /// [clearUserScoped] removes it on logout.
  List<String> getStringList(String key) =>
      (_box.get(key) as List?)?.cast<String>().toList() ?? const [];

  Future<bool> setStringList(String key, List<String> value) =>
      _put(key, value);

  /// Removes every key under [PrefKeys.userPrefix]. Device settings stay.
  Future<void> clearUserScoped() async {
    final userKeys = _box.keys
        .cast<String>()
        .where((key) => key.startsWith(PrefKeys.userPrefix))
        .toList();
    await _box.deleteAll(userKeys);
  }

  /// Returns true once the value is on disk, matching the earlier store API.
  Future<bool> _put(String key, Object value) async {
    await _box.put(key, value);
    return true;
  }
}

/// Settings store for the whole app, on the box bootstrap opened. Async so
/// callers keep the same `.future` and `.value` API as before the Hive port.
@Riverpod(keepAlive: true)
Future<PrefsStorage> prefsStorage(Ref ref) async =>
    PrefsStorage(ref.watch(settingsBoxProvider));
