import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/notifications/models/notification_payload.dart';
import 'package:riverpod_core/core/notifications/models/push_message.dart';

void main() {
  group('NotificationPayload.fromData', () {
    test('reads type, id and url and keeps the rest as extra', () {
      final payload = NotificationPayload.fromData({
        'type': 'order',
        'id': 42,
        'url': 'https://example.com/a',
        'campaign': 'spring',
      });

      expect(payload.type, 'order');
      expect(payload.id, '42');
      expect(payload.url, 'https://example.com/a');
      expect(payload.extra, {'campaign': 'spring'});
      expect(payload.hasRoute, isTrue);
      expect(payload.hasUrl, isTrue);
      expect(payload.isEmpty, isFalse);
    });

    test('blank and missing values count as missing', () {
      final payload = NotificationPayload.fromData({'type': '  ', 'id': ''});

      expect(payload.type, isNull);
      expect(payload.id, isNull);
      expect(payload.hasRoute, isFalse);
      expect(payload.isEmpty, isTrue);
    });

    test('a type without an id is not a route', () {
      final payload = NotificationPayload.fromData({'type': 'order'});

      expect(payload.hasRoute, isFalse);
      expect(payload.isEmpty, isTrue);
    });
  });

  group('NotificationPayload.tryParse', () {
    test('round trips through toJson', () {
      const payload = NotificationPayload(
        type: 'order',
        id: '7',
        extra: {'k': 'v'},
      );

      expect(NotificationPayload.tryParse(payload.toJson()), payload);
    });

    test('returns null for empty, invalid or non-object payloads', () {
      expect(NotificationPayload.tryParse(null), isNull);
      expect(NotificationPayload.tryParse(''), isNull);
      expect(NotificationPayload.tryParse('not json'), isNull);
      expect(NotificationPayload.tryParse('[1,2]'), isNull);
    });
  });

  group('PushMessage', () {
    test('data-only has no notification', () {
      const message = PushMessage(data: {'type': 'order', 'id': '1'});

      expect(message.hasNotification, isFalse);
      expect(message.payload.hasRoute, isTrue);
    });

    test('notification+data has both', () {
      const message = PushMessage(
        title: 'Hi',
        data: {'type': 'order', 'id': '1'},
      );

      expect(message.hasNotification, isTrue);
      expect(message.payload.type, 'order');
    });
  });
}
