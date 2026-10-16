import 'package:riverpod_core/core/storage/database/app_database.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';

/// Logout wipe: every secret, every cache row and every user-scoped setting.
/// Device settings (theme, locale, onboarding) are kept.
Future<void> clearUserData({
  required SecureStorage secure,
  required PrefsStorage prefs,
  required AppDatabase database,
}) async {
  await secure.clearAll();
  await database.clearCache();
  await prefs.clearUserScoped();
}
