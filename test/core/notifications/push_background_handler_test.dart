import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/notifications/push/push_background_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the entry point completes without Riverpod or Firebase', () async {
    // No ProviderScope, no Firebase platform: it must neither throw nor hang.
    await expectLater(
      firebaseMessagingBackgroundHandler(
        const RemoteMessage(
          messageId: 'bg-1',
          data: {'type': 'order', 'id': '1'},
        ),
      ),
      completes,
    );
  });

  test('a data-only message is accepted too', () async {
    await expectLater(
      firebaseMessagingBackgroundHandler(const RemoteMessage()),
      completes,
    );
  });
}
