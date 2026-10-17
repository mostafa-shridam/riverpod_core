import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/config/app_config.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/config/log_level.dart';
import 'package:riverpod_core/core/remote_config/remote_config.dart';
import 'package:riverpod_core/core/remote_config/remote_config_provider.dart';
import 'package:riverpod_core/features/app_gate/presentation/pages/force_update_page.dart';
import 'package:riverpod_core/features/app_gate/presentation/pages/maintenance_page.dart';
import 'package:riverpod_core/features/app_gate/providers/app_gate_providers.dart';

import '../../features/auth/auth_harness.dart';

const _config = RemoteConfig(
  minVersion: '1.2.0',
  latestVersion: '1.2.0',
  storeUrl: 'https://store.example.test/app',
  maintenance: RemoteMaintenance(enabled: true),
);

List<Override> _overrides() => [
  appConfigProvider.overrideWithValue(
    const AppConfig(
      flavor: Flavor.dev,
      appName: 'Test',
      apiBaseUrl: 'https://api.example.test',
      connectTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 30),
      logLevel: LogLevel.off,
      enableCrashReporting: false,
      enableAnalytics: false,
    ),
  ),
  remoteConfigProvider.overrideWith((ref) => Stream.value(_config)),
  storeOpenerProvider.overrideWithValue((uri) async => true),
];

void main() {
  final cases = <(ThemeMode, String)>[
    (ThemeMode.light, 'en'),
    (ThemeMode.dark, 'en'),
    (ThemeMode.light, 'ar'),
    (ThemeMode.dark, 'ar'),
  ];

  for (final (mode, lang) in cases) {
    testWidgets('force update ${mode.name} $lang', (tester) async {
      await pumpAuthPage(
        tester,
        const ForceUpdatePage(),
        themeMode: mode,
        locale: Locale(lang),
        size: const Size(390, 760),
        overrides: _overrides(),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('force_update_${mode.name}_$lang.png'),
      );
    });

    testWidgets('maintenance ${mode.name} $lang', (tester) async {
      await pumpAuthPage(
        tester,
        const MaintenancePage(),
        themeMode: mode,
        locale: Locale(lang),
        size: const Size(390, 760),
        overrides: _overrides(),
      );
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('maintenance_${mode.name}_$lang.png'),
      );
    });
  }
}
