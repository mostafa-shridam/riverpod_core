import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// FCM background and terminated-state handler.
///
/// It runs in its OWN isolate: no Riverpod, no providers, no UI, no state of
/// the main isolate. Notification messages are shown by the system; data-only
/// messages end up here, so this is the place for work that must not wait for
/// the app to open (write to a file or database, not to provider state).
///
/// It must be a top-level function with the entry-point pragma, and it never
/// throws: an exception in this isolate would only be lost.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();
  } on Object catch (error) {
    developer.log(
      'Push background handler: Firebase unavailable',
      name: 'push',
      error: error,
    );
    return;
  }
  // Intentionally no payload content in the log: it may hold personal data.
  developer.log(
    'Push background message received (${message.messageId})',
    name: 'push',
  );
}
