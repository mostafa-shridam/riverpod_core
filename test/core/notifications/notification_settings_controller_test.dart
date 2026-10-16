import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/notifications/settings/notification_settings.dart';
import 'package:riverpod_core/core/notifications/settings/notification_settings_controller.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

import '../../helpers/helpers.dart';

ProviderContainer _containerFor(PrefsStorage prefs) => createContainer(
  overrides: [prefsStorageProvider.overrideWith((ref) => Future.value(prefs))],
);

void main() {
  test('defaults: everything on', () async {
    final container = _containerFor(await fakePrefsStorage());

    final settings = await container.read(
      notificationSettingsControllerProvider.future,
    );

    expect(settings.masterEnabled, isTrue);
    expect(settings.disabledChannels, isEmpty);
    expect(settings.isChannelEnabled('general'), isTrue);
  });

  test('the master flag lives in PrefsStorage.notificationsEnabled', () async {
    final prefs = await fakePrefsStorage();
    final container = _containerFor(prefs);
    await container.read(notificationSettingsControllerProvider.future);

    await container
        .read(notificationSettingsControllerProvider.notifier)
        .setMasterEnabled(value: false);

    expect(prefs.notificationsEnabled, isFalse);
    expect(
      container
          .read(notificationSettingsControllerProvider)
          .value
          ?.masterEnabled,
      isFalse,
    );
  });

  test('channel switches persist under user.notifications.*', () async {
    final prefs = await fakePrefsStorage();
    final container = _containerFor(prefs);
    await container.read(notificationSettingsControllerProvider.future);
    final controller = container.read(
      notificationSettingsControllerProvider.notifier,
    );

    await controller.setChannelEnabled('silent', value: false);
    await controller.setChannelEnabled('general', value: false);
    await controller.setChannelEnabled('silent', value: true);

    expect(notificationDisabledChannelsKey, startsWith('user.notifications.'));
    expect(prefs.getStringList(notificationDisabledChannelsKey), ['general']);
  });

  test('settings survive a restart', () async {
    final prefs = await fakePrefsStorage();
    final first = _containerFor(prefs);
    await first.read(notificationSettingsControllerProvider.future);
    final controller = first.read(
      notificationSettingsControllerProvider.notifier,
    );
    await controller.setMasterEnabled(value: false);
    await controller.setChannelEnabled('reminders', value: false);

    final second = _containerFor(prefs);
    final settings = await second.read(
      notificationSettingsControllerProvider.future,
    );

    expect(settings.masterEnabled, isFalse);
    expect(settings.disabledChannels, {'reminders'});
  });

  test('logout (clearUserScoped) resets the channel switches', () async {
    final prefs = await fakePrefsStorage();
    final container = _containerFor(prefs);
    await container.read(notificationSettingsControllerProvider.future);
    await container
        .read(notificationSettingsControllerProvider.notifier)
        .setChannelEnabled('general', value: false);

    await prefs.clearUserScoped();

    expect(prefs.getStringList(notificationDisabledChannelsKey), isEmpty);
  });

  test('the master switch silences every channel', () {
    const settings = NotificationSettings(masterEnabled: false);

    expect(settings.isChannelEnabled('general'), isFalse);
    expect(settings.isChannelSwitchOn('general'), isTrue);
  });
}
