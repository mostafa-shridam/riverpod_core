import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';

/// In-memory [SecureStorage]. Never touches the platform keystore: the
/// wrapped [FlutterSecureStorage] is never called because every method is
/// overridden.
class FakeSecureStorage extends SecureStorage {
  FakeSecureStorage([Map<String, String> initial = const {}])
    : _values = Map.of(initial),
      super(const FlutterSecureStorage());

  final Map<String, String> _values;

  /// Current stored values, for assertions.
  Map<String, String> get values => Map.unmodifiable(_values);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<void> clearAll() async => _values.clear();
}
