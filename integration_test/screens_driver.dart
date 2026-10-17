import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

/// Run by `flutter drive` for the owner's screenshots. Each
/// `takeScreenshot` name is written to `$SCREENS_DIR/<name>.png`.
Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    final dir = Directory(Platform.environment['SCREENS_DIR'] ?? 'screens');
    await dir.create(recursive: true);
    final shots = (data?['screenshots'] as List<dynamic>?) ?? const [];
    for (final shot in shots) {
      final entry = shot as Map<String, dynamic>;
      final bytes = (entry['bytes'] as List<dynamic>).cast<int>();
      await File(
        '${dir.path}/${entry['screenshotName']}.png',
      ).writeAsBytes(bytes);
    }
  },
);
