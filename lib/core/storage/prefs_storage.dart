import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'prefs_storage.g.dart';

/// Every settings key the app uses. Keys starting with [userPrefix] belong to
/// the signed-in user and are wiped on logout; the others are device settings.
abstract final class PrefKeys {
  static const themeMode = 'settings.themeMode';
  static const locale = 'settings.locale';
  static const onboardingSeen = 'settings.onboardingSeen';

  static const userPrefix = 'user.';
  static const notificationsEnabled = 'user.notificationsEnabled';
}

/// Settings store on `shared_preferences`. Secrets never go here (see
/// `SecureStorage`), and structured or cached data never goes here (see
/// `AppDatabase`).
class PrefsStorage {
  PrefsStorage(this._prefs);

  final SharedPreferences _prefs;

  String? get themeMode => _prefs.getString(PrefKeys.themeMode);

  Future<bool> setThemeMode(String value) =>
      _prefs.setString(PrefKeys.themeMode, value);

  String? get locale => _prefs.getString(PrefKeys.locale);

  Future<bool> setLocale(String value) =>
      _prefs.setString(PrefKeys.locale, value);

  bool get onboardingSeen => _prefs.getBool(PrefKeys.onboardingSeen) ?? false;

  Future<bool> setOnboardingSeen({required bool value}) =>
      _prefs.setBool(PrefKeys.onboardingSeen, value);

  bool get notificationsEnabled =>
      _prefs.getBool(PrefKeys.notificationsEnabled) ?? true;

  Future<bool> setNotificationsEnabled({required bool value}) =>
      _prefs.setBool(PrefKeys.notificationsEnabled, value);

  /// Generic string-list slot for features (for example favorite ids). Name
  /// the key `user.<feature>.<name>` when it belongs to the signed-in user, so
  /// [clearUserScoped] removes it on logout.
  List<String> getStringList(String key) =>
      _prefs.getStringList(key) ?? const [];

  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  /// Removes every key under [PrefKeys.userPrefix]. Device settings stay.
  Future<void> clearUserScoped() async {
    final userKeys = _prefs.getKeys().where(
      (key) => key.startsWith(PrefKeys.userPrefix),
    );
    for (final key in userKeys.toList()) {
      await _prefs.remove(key);
    }
  }
}

/// Settings store for the whole app. Awaits `SharedPreferences` once.
@Riverpod(keepAlive: true)
Future<PrefsStorage> prefsStorage(Ref ref) async {
  return PrefsStorage(await SharedPreferences.getInstance());
}
