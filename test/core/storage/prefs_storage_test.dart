import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

import '../../helpers/helpers.dart';

void main() {
  group('PrefsStorage defaults', () {
    test('empty store reports documented defaults', () async {
      final prefs = await fakePrefsStorage();
      expect(prefs.themeMode, isNull);
      expect(prefs.onboardingSeen, isFalse);
      expect(prefs.notificationsEnabled, isTrue);
    });
  });

  group('PrefsStorage read and write', () {
    test('writes are read back', () async {
      final prefs = await fakePrefsStorage();
      await prefs.setThemeMode('dark');
      await prefs.setOnboardingSeen(value: true);
      await prefs.setNotificationsEnabled(value: false);

      expect(prefs.themeMode, 'dark');
      expect(prefs.onboardingSeen, isTrue);
      expect(prefs.notificationsEnabled, isFalse);
    });

    test('seeded values are visible', () async {
      final prefs = await fakePrefsStorage({PrefKeys.themeMode: 'light'});
      expect(prefs.themeMode, 'light');
    });

    test('setters report success', () async {
      final prefs = await fakePrefsStorage();
      expect(await prefs.setThemeMode('dark'), isTrue);
    });

    test('values survive closing and reopening the box', () async {
      final path = await testStoragePath();
      final first = await openTestStorage(path: path);
      await PrefsStorage(first.settings).setOnboardingSeen(value: true);
      await Hive.close();

      final reopened = await openTestStorage(path: path);
      expect(PrefsStorage(reopened.settings).onboardingSeen, isTrue);
    });
  });

  group('PrefsStorage.clearUserScoped', () {
    test('removes user.* keys and keeps device settings', () async {
      final prefs = await fakePrefsStorage({
        PrefKeys.themeMode: 'dark',
        PrefKeys.onboardingSeen: true,
        PrefKeys.notificationsEnabled: false,
      });

      await prefs.clearUserScoped();

      expect(prefs.notificationsEnabled, isTrue, reason: 'user value removed');
      expect(prefs.themeMode, 'dark', reason: 'device setting kept');
      expect(prefs.onboardingSeen, isTrue, reason: 'device setting kept');
    });
  });

  group('PrefsStorage string lists', () {
    test('missing key reads as empty, writes are read back', () async {
      final prefs = await fakePrefsStorage();
      expect(prefs.getStringList('user.videos.favorites'), isEmpty);

      await prefs.setStringList('user.videos.favorites', ['a', 'b']);

      expect(prefs.getStringList('user.videos.favorites'), ['a', 'b']);
    });

    test('user.* lists are removed by clearUserScoped', () async {
      final prefs = await fakePrefsStorage();
      await prefs.setStringList('user.videos.favorites', ['a']);
      await prefs.setStringList('settings.other', ['x']);

      await prefs.clearUserScoped();

      expect(prefs.getStringList('user.videos.favorites'), isEmpty);
      expect(prefs.getStringList('settings.other'), ['x']);
    });
  });
}
