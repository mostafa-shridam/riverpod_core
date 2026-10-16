import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

import '../../helpers/helpers.dart';

void main() {
  group('PrefsStorage defaults', () {
    test('empty store reports documented defaults', () async {
      final prefs = await fakePrefsStorage();
      expect(prefs.themeMode, isNull);
      expect(prefs.locale, isNull);
      expect(prefs.onboardingSeen, isFalse);
      expect(prefs.notificationsEnabled, isTrue);
    });
  });

  group('PrefsStorage read and write', () {
    test('writes are read back', () async {
      final prefs = await fakePrefsStorage();
      await prefs.setThemeMode('dark');
      await prefs.setLocale('ar');
      await prefs.setOnboardingSeen(value: true);
      await prefs.setNotificationsEnabled(value: false);

      expect(prefs.themeMode, 'dark');
      expect(prefs.locale, 'ar');
      expect(prefs.onboardingSeen, isTrue);
      expect(prefs.notificationsEnabled, isFalse);
    });

    test('seeded values are visible', () async {
      final prefs = await fakePrefsStorage({PrefKeys.themeMode: 'light'});
      expect(prefs.themeMode, 'light');
    });
  });

  group('PrefsStorage.clearUserScoped', () {
    test('removes user.* keys and keeps device settings', () async {
      final prefs = await fakePrefsStorage({
        PrefKeys.themeMode: 'dark',
        PrefKeys.locale: 'ar',
        PrefKeys.onboardingSeen: true,
        PrefKeys.notificationsEnabled: false,
      });

      await prefs.clearUserScoped();

      expect(prefs.notificationsEnabled, isTrue, reason: 'user value removed');
      expect(prefs.themeMode, 'dark', reason: 'device setting kept');
      expect(prefs.locale, 'ar', reason: 'device setting kept');
      expect(prefs.onboardingSeen, isTrue, reason: 'device setting kept');
    });
  });
}
