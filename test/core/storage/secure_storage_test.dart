import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';

import '../../helpers/helpers.dart';

void main() {
  test('read, write and delete a value', () async {
    final storage = FakeSecureStorage();
    await storage.write('k', 'v');
    expect(await storage.read('k'), 'v');
    await storage.delete('k');
    expect(await storage.read('k'), isNull);
  });

  test('token helpers read the documented keys', () async {
    final storage = FakeSecureStorage({
      SecureKeys.accessToken: 'access',
      SecureKeys.refreshToken: 'refresh',
    });
    expect(await storage.readAccessToken(), 'access');
    expect(await storage.readRefreshToken(), 'refresh');
  });

  test('clearAll removes every secret', () async {
    final storage = FakeSecureStorage({
      SecureKeys.accessToken: 'access',
      SecureKeys.refreshToken: 'refresh',
    });
    await storage.clearAll();
    expect(storage.values, isEmpty);
  });

  test('the fake is what a container override provides', () async {
    final container = createContainer(
      overrides: [secureStorageProvider.overrideWithValue(FakeSecureStorage())],
    );
    final storage = container.read(secureStorageProvider);
    await storage.write(SecureKeys.accessToken, 'a');
    expect(await storage.readAccessToken(), 'a');
  });
}
