import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/notifications/channels/notification_channels.dart';
import 'package:riverpod_core/core/notifications/local/local_notification_service.dart';
import 'package:riverpod_core/core/notifications/local/notification_badge.dart';
import 'package:riverpod_core/core/notifications/models/notification_payload.dart';
import 'package:riverpod_core/core/notifications/models/schedule_repeat.dart';
import 'package:riverpod_core/core/notifications/models/schedule_result.dart';
import 'package:riverpod_core/core/notifications/settings/notification_settings.dart';

import '../../helpers/fake_notification_backends.dart';

void main() {
  late FakeLocalNotificationBackend backend;
  late NotificationSettings settings;
  late DateTime now;
  late LocalNotificationService service;

  setUp(() {
    backend = FakeLocalNotificationBackend();
    settings = const NotificationSettings();
    // Wednesday 2026-10-14 10:00.
    now = DateTime(2026, 10, 14, 10);
    service = LocalNotificationService(
      backend: backend,
      settings: () => settings,
      now: () => now,
      logger: recordingLogger([]),
    );
  });

  group('show', () {
    test('shows on the default channel with the payload', () async {
      final id = await service.show(
        title: 'T',
        body: 'B',
        payload: const NotificationPayload(type: 'order', id: '1'),
      );

      expect(id, isNotNull);
      final shown = backend.shown.single;
      expect(shown.id, id);
      expect(shown.channelId, NotificationChannels.defaultChannelId);
      expect(shown.payload?.type, 'order');
    });

    test('big text, picture, group and badge are passed through', () async {
      await service.show(
        title: 'T',
        body: 'B',
        bigText: 'long',
        bigPicturePath: '/tmp/a.png',
        groupKey: 'chat',
        badge: 3,
      );

      final shown = backend.shown.single;
      expect(shown.bigText, 'long');
      expect(shown.bigPicturePath, '/tmp/a.png');
      expect(shown.groupKey, 'chat');
      expect(shown.badge, 3);
    });

    test('a switched-off channel shows nothing and returns null', () async {
      settings = const NotificationSettings(disabledChannels: {'general'});

      expect(await service.show(title: 'T', body: 'B'), isNull);
      expect(backend.shown, isEmpty);
    });

    test('the master switch silences every channel', () async {
      settings = const NotificationSettings(masterEnabled: false);

      expect(
        await service.show(
          title: 'T',
          body: 'B',
          channelId: NotificationChannels.highPriority.id,
        ),
        isNull,
      );
    });

    test('ids are unique even within the same millisecond', () {
      final ids = {for (var i = 0; i < 50; i++) service.nextId()};

      expect(ids, hasLength(50));
    });

    test('a group summary is an inbox-style summary of its key', () async {
      await service.showGroupSummary(
        groupKey: 'chat',
        title: 'Chat',
        lines: ['a', 'b'],
        summaryText: '2 new',
      );

      final summary = backend.shown.single;
      expect(summary.isGroupSummary, isTrue);
      expect(summary.groupKey, 'chat');
      expect(summary.groupLines, ['a', 'b']);
    });
  });

  group('schedule', () {
    test('uses an exact alarm when the permission is granted', () async {
      backend.exactAllowed = true;

      final result = await service.schedule(
        title: 'T',
        body: 'B',
        when: now.add(const Duration(hours: 1)),
      );

      expect(result, ScheduleResult.exact);
      expect(backend.scheduled.single.exact, isTrue);
      expect(backend.scheduled.single.notification.channelId, 'reminders');
    });

    test('falls back to inexact when exact alarms are not allowed', () async {
      backend.exactAllowed = false;

      final result = await service.schedule(
        title: 'T',
        body: 'B',
        when: now.add(const Duration(hours: 1)),
      );

      expect(result, ScheduleResult.inexact);
      expect(backend.scheduled.single.exact, isFalse);
    });

    test('a time in the past is not scheduled', () async {
      final result = await service.schedule(
        title: 'T',
        body: 'B',
        when: now.subtract(const Duration(minutes: 1)),
      );

      expect(result, ScheduleResult.inThePast);
      expect(backend.scheduled, isEmpty);
    });

    test('a switched-off channel is not scheduled', () async {
      settings = const NotificationSettings(disabledChannels: {'reminders'});

      final result = await service.schedule(
        title: 'T',
        body: 'B',
        when: now.add(const Duration(hours: 1)),
      );

      expect(result, ScheduleResult.disabled);
      expect(backend.scheduled, isEmpty);
    });

    test('daily: later today when the time is still ahead', () async {
      await service.scheduleDaily(title: 'T', body: 'B', hour: 18, minute: 30);

      final scheduled = backend.scheduled.single;
      expect(scheduled.when, DateTime(2026, 10, 14, 18, 30));
      expect(scheduled.repeat, ScheduleRepeat.daily);
    });

    test('daily: tomorrow when the time has passed', () async {
      await service.scheduleDaily(title: 'T', body: 'B', hour: 9, minute: 0);

      expect(backend.scheduled.single.when, DateTime(2026, 10, 15, 9));
    });

    test('weekly: the next requested weekday', () async {
      await service.scheduleWeekly(
        title: 'T',
        body: 'B',
        weekday: DateTime.friday,
        hour: 8,
        minute: 0,
      );

      final scheduled = backend.scheduled.single;
      expect(scheduled.when, DateTime(2026, 10, 16, 8));
      expect(scheduled.repeat, ScheduleRepeat.weekly);
    });

    test('weekly: the same weekday but a passed time waits a week', () async {
      await service.scheduleWeekly(
        title: 'T',
        body: 'B',
        weekday: DateTime.wednesday,
        hour: 9,
        minute: 0,
      );

      expect(backend.scheduled.single.when, DateTime(2026, 10, 21, 9));
    });

    test('the exact-alarm request is forwarded', () async {
      backend.exactAllowed = true;

      expect(await service.requestExactAlarmPermission(), isTrue);
      expect(backend.exactRequests, 1);
    });
  });

  group('cancel and pending', () {
    test('cancel, cancelAll and pending reach the backend', () async {
      await service.schedule(
        title: 'T',
        body: 'B',
        when: now.add(const Duration(hours: 1)),
        id: 7,
      );

      expect((await service.pending()).single.id, 7);
      await service.cancel(7);
      await service.cancelAll();

      expect(backend.cancelled, [7]);
      expect(backend.cancelAllCalls, 1);
    });
  });

  group('badge', () {
    test(
      'set, increment and clear write absolute numbers, never below 0',
      () async {
        final badge = NotificationBadge(backend);

        await badge.set(2);
        await badge.increment();
        await badge.set(-5);
        await badge.increment(4);
        await badge.clear();

        expect(backend.badges, [2, 3, 0, 4, 0]);
        expect(badge.count, 0);
      },
    );
  });
}
