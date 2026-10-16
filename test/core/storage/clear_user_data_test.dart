import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/storage/clear_user_data.dart';
import 'package:riverpod_core/core/storage/database/app_database.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';

import '../../helpers/helpers.dart';

void main() {
  test('wipes secrets, cache and user prefs; keeps device settings', () async {
    final secure = FakeSecureStorage({
      SecureKeys.accessToken: 'access',
      SecureKeys.refreshToken: 'refresh',
    });
    final prefs = await fakePrefsStorage({
      PrefKeys.themeMode: 'dark',
      PrefKeys.notificationsEnabled: false,
    });
    final database = AppDatabase.inMemory();
    addTearDown(database.close);
    await database.writeCache(
      key: 'user-1/orders',
      payload: '[]',
      savedAt: DateTime.utc(2026),
    );

    await clearUserData(secure: secure, prefs: prefs, database: database);

    expect(secure.values, isEmpty);
    expect(await database.readCache('user-1/orders'), isNull);
    expect(prefs.notificationsEnabled, isTrue);
    expect(prefs.themeMode, 'dark');
  });
}
