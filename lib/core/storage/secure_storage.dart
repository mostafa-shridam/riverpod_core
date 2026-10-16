import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage.g.dart';

/// Keys of secrets. Tokens only; never log values read from here.
abstract final class SecureKeys {
  static const accessToken = 'auth.accessToken';
  static const refreshToken = 'auth.refreshToken';
}

/// Secret store on the platform keystore (`flutter_secure_storage`).
class SecureStorage {
  SecureStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);

  /// Removes every secret the app stored. Used on logout.
  Future<void> clearAll() => _storage.deleteAll();

  Future<String?> readAccessToken() => read(SecureKeys.accessToken);

  Future<String?> readRefreshToken() => read(SecureKeys.refreshToken);
}

/// Secret store for the whole app.
@Riverpod(keepAlive: true)
SecureStorage secureStorage(Ref ref) {
  return SecureStorage(const FlutterSecureStorage());
}
