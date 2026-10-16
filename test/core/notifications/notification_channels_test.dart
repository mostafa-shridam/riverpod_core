import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/notifications/channels/notification_channels.dart';
import 'package:riverpod_core/core/notifications/models/notification_importance.dart';

void main() {
  test('the table has the four documented channels', () {
    expect(NotificationChannels.all.map((c) => c.id), [
      'general',
      'high_priority',
      'silent',
      'reminders',
    ]);
  });

  test('channel ids are unique', () {
    final ids = NotificationChannels.all.map((c) => c.id).toList();

    expect(ids.toSet(), hasLength(ids.length));
  });

  test('every channel belongs to a defined group', () {
    final groups = NotificationChannels.groups.map((g) => g.id).toSet();

    for (final channel in NotificationChannels.all) {
      expect(groups, contains(channel.groupId), reason: channel.id);
    }
  });

  test('sensible defaults per channel', () {
    expect(
      NotificationChannels.highPriority.importance,
      NotificationImportance.max,
    );
    expect(NotificationChannels.silent.importance, NotificationImportance.low);
    expect(NotificationChannels.silent.playSound, isFalse);
    expect(NotificationChannels.silent.enableVibration, isFalse);
    expect(NotificationChannels.silent.showBadge, isFalse);
    expect(NotificationChannels.general.playSound, isTrue);
    expect(NotificationChannels.reminders.id, NotificationChannels.remindersId);
  });

  test('byId falls back to general for unknown or null ids', () {
    expect(NotificationChannels.byId('silent').id, 'silent');
    expect(NotificationChannels.byId('nope').id, 'general');
    expect(NotificationChannels.byId(null).id, 'general');
    expect(NotificationChannels.isKnown('silent'), isTrue);
    expect(NotificationChannels.isKnown('nope'), isFalse);
  });

  test('the default channel id matches the AndroidManifest meta-data', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    final meta = RegExp(
      r'default_notification_channel_id"\s+android:value="([^"]+)"',
    ).firstMatch(manifest);

    expect(meta?.group(1), NotificationChannels.defaultChannelId);
  });

  test('every channel and group text exists in both languages', () {
    final keys = [
      for (final c in NotificationChannels.all) ...[
        c.nameKey,
        c.descriptionKey,
      ],
      for (final g in NotificationChannels.groups) g.nameKey,
    ];

    for (final language in ['en', 'ar']) {
      final json =
          jsonDecode(
                File('assets/translations/$language.json').readAsStringSync(),
              )
              as Map<String, Object?>;
      for (final key in keys) {
        final parts = key.split('.');
        final group = json[parts.first]! as Map<String, Object?>;
        expect(group[parts.last], isA<String>(), reason: '$language $key');
      }
    }
  });
}
