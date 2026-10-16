import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/notifications/local/local_notification_service.dart';
import 'package:riverpod_core/core/notifications/models/notification_permission_state.dart';
import 'package:riverpod_core/core/notifications/models/notification_tap.dart';
import 'package:riverpod_core/core/notifications/models/notification_tap_source.dart';
import 'package:riverpod_core/core/notifications/models/push_message.dart';
import 'package:riverpod_core/core/notifications/push/push_service.dart';
import 'package:riverpod_core/core/notifications/settings/notification_settings.dart';

import '../../helpers/fake_notification_backends.dart';

void main() {
  late FakePushBackend backend;
  late FakeLocalNotificationBackend localBackend;
  late List<NotificationTap> taps;
  late List<String> logs;
  late NotificationSettings settings;

  PushService build({bool foregroundWithLocal = true}) {
    final logger = recordingLogger(logs);
    return PushService(
      backend: backend,
      local: LocalNotificationService(
        backend: localBackend,
        settings: () => settings,
        now: () => DateTime(2026, 1, 1),
        logger: logger,
      ),
      onTap: taps.add,
      settings: () => settings,
      logger: logger,
      showForegroundWithLocal: foregroundWithLocal,
    );
  }

  setUp(() {
    backend = FakePushBackend();
    localBackend = FakeLocalNotificationBackend();
    taps = [];
    logs = [];
    settings = const NotificationSettings();
  });

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  group('availability', () {
    test(
      'Firebase unavailable: disabled, logged once, calls are no-ops',
      () async {
        backend.available = false;
        final service = build();

        expect(await service.initialize(), isFalse);

        expect(service.isAvailable, isFalse);
        expect(logs, hasLength(1));
        expect(logs.single, contains('Push is disabled'));
        expect(await service.subscribeToTopic('news'), isFalse);
        expect(backend.subscribed, isEmpty);
        expect(
          await service.requestPermission(),
          NotificationPermissionState.denied,
        );
      },
    );

    test(
      'available: initialises and sets the foreground presentation',
      () async {
        final service = build();

        expect(await service.initialize(), isTrue);

        expect(service.isAvailable, isTrue);
        expect(backend.presentation, [true]);
      },
    );

    test('presentation follows the master switch', () async {
      final service = build();
      await service.initialize();

      settings = const NotificationSettings(masterEnabled: false);
      await service.applyForegroundPresentation();

      expect(backend.presentation, [true, false]);
    });
  });

  group('foreground messages', () {
    test('a notification message is shown as a local notification', () async {
      final service = build();
      await service.initialize();

      backend.messages.add(
        const PushMessage(
          id: 'm1',
          title: 'Hello',
          body: 'World',
          channelId: 'high_priority',
          data: {'type': 'order', 'id': '5'},
        ),
      );
      await flush();

      final shown = localBackend.shown.single;
      expect(shown.title, 'Hello');
      expect(shown.body, 'World');
      expect(shown.channelId, 'high_priority');
      expect(shown.payload?.type, 'order');
      expect(shown.payload?.id, '5');
    });

    test('an unknown or missing channel falls back to general', () async {
      final service = build();
      await service.initialize();

      backend.messages
        ..add(const PushMessage(id: 'a', title: 'A', channelId: 'made_up'))
        ..add(const PushMessage(id: 'b', title: 'B'));
      await flush();

      expect(localBackend.shown.map((n) => n.channelId), [
        'general',
        'general',
      ]);
    });

    test('the same message id is shown once', () async {
      final service = build();
      await service.initialize();

      backend.messages
        ..add(const PushMessage(id: 'dup', title: 'A'))
        ..add(const PushMessage(id: 'dup', title: 'A'));
      await flush();

      expect(localBackend.shown, hasLength(1));
    });

    test(
      'a data-only message is not shown and reaches silentMessages',
      () async {
        final service = build();
        await service.initialize();
        final silent = <PushMessage>[];
        service.silentMessages.listen(silent.add);

        backend.messages.add(const PushMessage(id: 's', data: {'sync': '1'}));
        await flush();

        expect(localBackend.shown, isEmpty);
        expect(silent.single.data['sync'], '1');
      },
    );

    test('a switched-off channel or master switch shows nothing', () async {
      final service = build();
      await service.initialize();

      settings = const NotificationSettings(disabledChannels: {'general'});
      backend.messages.add(const PushMessage(id: 'a', title: 'A'));
      settings = const NotificationSettings(masterEnabled: false);
      backend.messages.add(const PushMessage(id: 'b', title: 'B'));
      await flush();

      expect(localBackend.shown, isEmpty);
    });

    test('iOS: the system presents it, no local notification', () async {
      final service = build(foregroundWithLocal: false);
      await service.initialize();

      backend.messages.add(const PushMessage(id: 'a', title: 'A'));
      await flush();

      expect(localBackend.shown, isEmpty);
    });
  });

  group('taps', () {
    test('onMessageOpenedApp becomes a pushOpened tap', () async {
      final service = build();
      await service.initialize();

      backend.opened.add(
        const PushMessage(id: 'o', data: {'type': 'order', 'id': '1'}),
      );
      await flush();

      expect(taps.single.source, NotificationTapSource.pushOpened);
      expect(taps.single.payload.id, '1');
    });

    test(
      'the initial message (cold start) becomes a pushInitial tap',
      () async {
        backend.initial = const PushMessage(
          id: 'i',
          data: {'type': 'order', 'id': '2'},
        );
        final service = build();

        await service.initialize();

        expect(taps.single.source, NotificationTapSource.pushInitial);
        expect(taps.single.payload.id, '2');
      },
    );

    test('the same message opened twice is one tap', () async {
      backend.initial = const PushMessage(
        id: 'same',
        data: {'type': 'order', 'id': '2'},
      );
      final service = build();
      await service.initialize();

      backend.opened.add(
        const PushMessage(id: 'same', data: {'type': 'order', 'id': '2'}),
      );
      await flush();

      expect(taps, hasLength(1));
    });
  });

  group('topics', () {
    test('subscribe and unsubscribe reach the backend', () async {
      final service = build();
      await service.initialize();

      expect(await service.subscribeToTopic('news'), isTrue);
      expect(await service.unsubscribeFromTopic('news'), isTrue);

      expect(backend.subscribed, ['news']);
      expect(backend.unsubscribed, ['news']);
    });
  });
}
