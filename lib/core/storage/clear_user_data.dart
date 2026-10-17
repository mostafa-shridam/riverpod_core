import 'package:riverpod_core/core/storage/cache/cache_store.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';

/// Logout wipe: every secret, every cache row and every user-scoped setting.
/// Device settings (theme, onboarding) are kept.
Future<void> clearUserData({
  required SecureStorage secure,
  required PrefsStorage prefs,
  required CacheStore cache,
}) async {
  await secure.clearAll();
  await cache.clear();
  await prefs.clearUserScoped();
}
