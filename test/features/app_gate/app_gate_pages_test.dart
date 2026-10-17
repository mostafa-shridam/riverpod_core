import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/remote_config/remote_config.dart';
import 'package:riverpod_core/core/remote_config/remote_config_provider.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';
import 'package:riverpod_core/features/app_gate/presentation/pages/force_update_page.dart';
import 'package:riverpod_core/features/app_gate/presentation/pages/maintenance_page.dart';
import 'package:riverpod_core/features/app_gate/presentation/widgets/soft_update_banner.dart';
import 'package:riverpod_core/features/app_gate/providers/app_gate_providers.dart';

import '../../helpers/helpers.dart';
import '../auth/auth_harness.dart';

AppConfig _config() => const AppConfig(
  flavor: Flavor.dev,
  appName: 'Test',
  apiBaseUrl: 'https://api.example.test',
  connectTimeout: Duration(seconds: 15),
  receiveTimeout: Duration(seconds: 30),
  logLevel: LogLevel.off,
  enableCrashReporting: false,
  enableAnalytics: false,
  appVersion: '1.0.0',
);

List<Override> _overrides({
  required RemoteConfig config,
  required List<Uri> opened,
  PrefsStorage? prefs,
  void Function()? onBuild,
}) => [
  appConfigProvider.overrideWithValue(_config()),
  remoteConfigProvider.overrideWith((ref) {
    onBuild?.call();
    return Stream.value(config);
  }),
  storeOpenerProvider.overrideWithValue((uri) async {
    opened.add(uri);
    return true;
  }),
  if (prefs != null)
    prefsStorageProvider.overrideWith((ref) => Future.value(prefs)),
];

const _store = 'https://store.example.test/app';

void main() {
  group('force update', () {
    testWidgets('shows the copy and opens the store', (tester) async {
      final opened = <Uri>[];
      await pumpAuthPage(
        tester,
        const ForceUpdatePage(),
        overrides: _overrides(
          config: const RemoteConfig(
            minVersion: '1.2.0',
            latestVersion: '1.2.0',
            storeUrl: _store,
          ),
          opened: opened,
        ),
      );

      expect(find.text('Update required'), findsOneWidget);
      await tester.tap(find.widgetWithText(AppButton, 'Update now'));
      await tester.pumpAndSettle();

      expect(opened, [Uri.parse(_store)]);
    });

    testWidgets('retry asks the server again', (tester) async {
      var builds = 0;
      await pumpAuthPage(
        tester,
        const ForceUpdatePage(),
        overrides: _overrides(
          config: const RemoteConfig(
            minVersion: '1.2.0',
            latestVersion: '1.2.0',
          ),
          opened: [],
          onBuild: () => builds++,
        ),
      );
      final before = builds;

      await tester.tap(find.widgetWithText(AppButton, 'Try again'));
      await tester.pumpAndSettle();

      expect(builds, greaterThan(before));
    });

    testWidgets('no store url: the store action is disabled', (tester) async {
      await pumpAuthPage(
        tester,
        const ForceUpdatePage(),
        overrides: _overrides(
          config: const RemoteConfig(
            minVersion: '1.2.0',
            latestVersion: '1.2.0',
          ),
          opened: [],
        ),
      );

      final button = tester.widget<AppButton>(
        find.widgetWithText(AppButton, 'Update now'),
      );
      expect(button.onPressed, isNull);
    });
  });

  group('maintenance', () {
    testWidgets('shows the server message when it sends one', (tester) async {
      await pumpAuthPage(
        tester,
        const MaintenancePage(),
        overrides: _overrides(
          config: const RemoteConfig(
            minVersion: '0.0.0',
            latestVersion: '0.0.0',
            maintenance: RemoteMaintenance(
              enabled: true,
              message: 'Back at noon',
            ),
          ),
          opened: [],
        ),
      );

      expect(find.text('Back at noon'), findsOneWidget);
    });

    testWidgets('falls back to the default copy', (tester) async {
      await pumpAuthPage(
        tester,
        const MaintenancePage(),
        overrides: _overrides(
          config: const RemoteConfig(
            minVersion: '0.0.0',
            latestVersion: '0.0.0',
            maintenance: RemoteMaintenance(enabled: true),
          ),
          opened: [],
        ),
      );

      expect(
        find.text('The app is under maintenance. Please try again shortly.'),
        findsOneWidget,
      );
    });
  });

  group('soft update banner', () {
    const behind = RemoteConfig(
      minVersion: '0.0.0',
      latestVersion: '1.5.0',
      storeUrl: _store,
    );

    testWidgets('shows for a newer version and "later" hides it for good', (
      tester,
    ) async {
      final prefs = await tester.runAsync(() => fakePrefsStorage());
      await pumpAuthPage(
        tester,
        const Scaffold(body: SoftUpdateBanner()),
        overrides: _overrides(config: behind, opened: [], prefs: prefs),
      );

      expect(
        find.text('A new version of the app is available.'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(AppButton, 'Later'));
      await tester.pumpAndSettle();

      expect(find.text('A new version of the app is available.'), findsNothing);
      expect(prefs!.dismissedUpdateVersions, ['1.5.0']);
    });

    testWidgets('a version the user already dismissed stays hidden', (
      tester,
    ) async {
      final prefs = await tester.runAsync(() => fakePrefsStorage({}));
      await tester.runAsync(() => prefs!.setDismissedUpdateVersions(['1.5.0']));
      await pumpAuthPage(
        tester,
        const Scaffold(body: SoftUpdateBanner()),
        overrides: _overrides(config: behind, opened: [], prefs: prefs),
      );

      expect(find.text('A new version of the app is available.'), findsNothing);
    });
  });
}
