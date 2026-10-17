import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// easy_localization keeps the saved locale in shared_preferences, which has no
/// platform implementation under `flutter test`. Answer that channel here, for
/// every test, so no test file imports the package (D-034).
const _preferencesChannel = MethodChannel(
  'plugins.flutter.io/shared_preferences',
);

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger
      .setMockMethodCallHandler(
        _preferencesChannel,
        (call) async => call.method == 'getAll' ? <String, Object>{} : true,
      );
  await testMain();
}
