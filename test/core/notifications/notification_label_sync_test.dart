import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/analytics/analytics_service.dart';
import 'package:riverpod_core/core/device/device_info_provider.dart';
import 'package:riverpod_core/core/logger/app_logger.dart';
import 'package:riverpod_core/core/notifications/local/local_notification_backend.dart';
import 'package:riverpod_core/core/notifications/models/app_notification_channel.dart';
import 'package:riverpod_core/core/notifications/models/app_notification_channel_group.dart';
import 'package:riverpod_core/core/notifications/notification_label_sync.dart';
import 'package:riverpod_core/core/notifications/notification_providers.dart';
import 'package:riverpod_core/core/notifications/notification_service_provider.dart';
import 'package:riverpod_core/core/permissions/permission_service.dart';
import 'package:riverpod_core/core/storage/database/app_database.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

import '../../helpers/fake_notification_backends.dart';
import '../../helpers/helpers.dart';

/// Resolves the labels the way the real backend does, at creation time, and
/// records every batch plus the order against `initialize`.
class _RecordingBackend extends FakeLocalNotificationBackend {
  final events = <String>[];
  final batches = <List<String>>[];

  @override
  Future<void> initialize({
    required String timezoneName,
    required NotificationTapCallback onTap,
  }) async {
    events.add('initialize');
    return super.initialize(timezoneName: timezoneName, onTap: onTap);
  }

  @override
  Future<void> createChannels({
    required List<AppNotificationChannel> channels,
    required List<AppNotificationChannelGroup> groups,
    required NotificationLabelResolver label,
  }) async {
    events.add('createChannels');
    batches.add([
      for (final g in groups) label(g.nameKey),
      for (final c in channels) ...[label(c.nameKey), label(c.descriptionKey)],
    ]);
    return super.createChannels(
      channels: channels,
      groups: groups,
      label: label,
    );
  }
}

Future<List<Override>> _overrides(
  _RecordingBackend local,
  List<String> unresolved,
) async {
  final prefs = await fakePrefsStorage();
  return [
    prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
    secureStorageProvider.overrideWithValue(FakeSecureStorage()),
    appDatabaseProvider.overrideWithValue(AppDatabase.inMemory()),
    analyticsServiceProvider.overrideWithValue(const NoopAnalyticsService()),
    loggerProvider.overrideWithValue(recordingLogger(<String>[])),
    localNotificationBackendProvider.overrideWithValue(local),
    pushBackendProvider.overrideWithValue(FakePushBackend()),
    permissionBackendProvider.overrideWithValue(
      FakeNotificationPermissionBackend(),
    ),
    timezoneBackendProvider.overrideWithValue(FakeTimezoneBackend()),
    pushTokenRegistrarProvider.overrideWithValue(FakePushTokenRegistrar()),
    deviceInfoSourceProvider.overrideWithValue(FakeDeviceInfoSource()),
    // The real resolver, plus a check that nothing resolves to a raw key
    // (easy_localization returns the key itself when it is not found).
    notificationLabelResolverProvider.overrideWithValue((key) {
      final text = key.tr();
      if (text == key) unresolved.add(key);
      return text;
    }),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
  }

  testWidgets('channels are created after initialize, translated, never as '
      'raw keys', (tester) async {
    final local = _RecordingBackend();
    final unresolved = <String>[];

    await pumpApp(
      tester,
      const NotificationLabelSync(child: SizedBox()),
      overrides: await _overrides(local, unresolved),
    );
    await settle(tester);

    expect(local.events, ['initialize', 'createChannels']);
    expect(unresolved, isEmpty);
    final names = local.batches.single;
    expect(names, contains(LocaleKeys.notifications_groupUpdates.tr()));
    expect(names, isNot(contains(LocaleKeys.notifications_groupUpdates)));
  });

  testWidgets('switching language re-registers the same channel ids with '
      'the new names', (tester) async {
    final local = _RecordingBackend();
    final unresolved = <String>[];

    await pumpApp(
      tester,
      const NotificationLabelSync(child: SizedBox()),
      overrides: await _overrides(local, unresolved),
    );
    await settle(tester);
    final ids = local.channels.map((c) => c.id).toList();

    final context = tester.element(find.byType(NotificationLabelSync));
    await tester.runAsync(() => context.setLocale(const Locale('ar')));
    await tester.pump();
    await settle(tester);

    expect(local.batches, hasLength(2));
    expect(local.batches.last, isNot(equals(local.batches.first)));
    expect(local.channels.map((c) => c.id).toList(), ids);
    expect(unresolved, isEmpty);
  });

  test('NotificationService.initialize alone registers no channels', () async {
    final local = _RecordingBackend();
    final container = createContainer(
      overrides: await _overrides(local, <String>[]),
    );

    await container.read(notificationServiceProvider).initialize();

    expect(local.batches, isEmpty);
  });
}
