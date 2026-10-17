import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/storage/cache/cache_store.dart';
import 'package:riverpod_core/core/storage/clear_user_data.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';

import '../../helpers/helpers.dart';

void main() {
  test('wipes secrets, cache and user prefs; keeps device settings', () async {
    final secure = FakeSecureStorage({
      SecureKeys.accessToken: 'access',
      SecureKeys.refreshToken: 'refresh',
    });
    final storage = await openTestStorage();
    final prefs = PrefsStorage(storage.settings);
    final cache = CacheStore(storage.cache);
    await storage.settings.putAll({
      PrefKeys.themeMode: 'dark',
      PrefKeys.notificationsEnabled: false,
    });
    await cache.write(
      key: 'user-1/orders',
      payload: '[]',
      savedAt: DateTime.utc(2026),
    );

    await clearUserData(secure: secure, prefs: prefs, cache: cache);

    expect(secure.values, isEmpty);
    expect(cache.read('user-1/orders'), isNull);
    expect(prefs.notificationsEnabled, isTrue);
    expect(prefs.themeMode, 'dark');
  });
}
