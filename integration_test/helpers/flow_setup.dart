import 'dart:ui' show PlatformDispatcher;

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:riverpod_core/core/bootstrap/bootstrap.dart';
import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_backend.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_source.dart';
import 'package:riverpod_core/core/remote_config/remote_config_provider.dart';
import 'package:riverpod_core/core/remote_config/remote_config_source.dart';
import 'package:riverpod_core/core/storage/hive_boxes.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';

import '../../test/helpers/fake_secure_storage.dart';

/// Env for the flow: no real values, no network. The mock sources (auth,
/// videos) are the template's own, selected in code.
const flowEnv = '''
APP_NAME=Template Flow
API_BASE_URL=https://api.example.invalid
CONNECT_TIMEOUT_MS=1000
RECEIVE_TIMEOUT_MS=1000
LOG_LEVEL=off
ENABLE_CRASH_REPORTING=false
ENABLE_ANALYTICS=false
''';

/// Set with `--dart-define=CAPTURE_SCREENS=true` (screenshots run under
/// `flutter drive`).
const captureScreens = bool.fromEnvironment('CAPTURE_SCREENS');

/// Empty settings and cache on every run, so onboarding and sign-in always
/// start from the same state.
Future<List<Override>> openFreshStorage() async {
  await Hive.initFlutter();
  await Hive.deleteBoxFromDisk(HiveBoxNames.settings);
  await Hive.deleteBoxFromDisk(HiveBoxNames.cache);
  return openAppStorage();
}

/// Starts the real app through [bootstrap] with the seams the flow needs:
/// mock remote config, a fake player, in-memory secure storage, and no
/// notification setup.
Future<void> startApp(WidgetTester tester) async {
  Widget? app;
  // Needed before EasyLocalization builds: production bootstrap does not call it
  // (a known gap), so the test does.
  await EasyLocalization.ensureInitialized();
  // bootstrap installs its own error handlers. Restore the test framework's
  // afterwards, so a failure fails the test with its real error.
  final flutterHandler = FlutterError.onError;
  final platformHandler = PlatformDispatcher.instance.onError;
  try {
    await _bootstrapInto((widget) => app = widget);
  } finally {
    FlutterError.onError = flutterHandler;
    PlatformDispatcher.instance.onError = platformHandler;
  }
  await tester.pumpWidget(app!);
  // The flow reads English labels. Pin the locale, so the device language or a
  // saved choice cannot change the screens under the test.
  final localization = EasyLocalization.of(
    tester.element(find.byType(MaterialApp)),
  );
  await tester.runAsync(() => localization!.setLocale(const Locale('en')));
  await tester.pump();
}

Future<void> _bootstrapInto(void Function(Widget) runner) async {
  await bootstrap(
    Flavor.dev,
    envReader: (_) async => flowEnv,
    openStorage: openFreshStorage,
    initNotifications: () async {},
    runner: runner,
    overrides: [
      remoteConfigSourceProvider.overrideWithValue(
        const MockRemoteConfigSource(),
      ),
      videoBackendFactoryProvider.overrideWithValue(
        (AppVideoSource source) => FlowVideoBackend(),
      ),
      secureStorageProvider.overrideWithValue(FakeSecureStorage()),
    ],
  );
}

/// A player that reports ready at once and draws a fixed surface, so the
/// detail page and its screenshots do not depend on a network or a codec.
class FlowVideoBackend extends ChangeNotifier implements AppVideoBackend {
  AppVideoBackendValue _value = const AppVideoBackendValue();

  @override
  AppVideoBackendValue get value => _value;

  @override
  Future<void> initialize() async {
    _value = const AppVideoBackendValue(
      isInitialized: true,
      duration: Duration(seconds: 8),
      aspectRatio: 16 / 9,
    );
    notifyListeners();
  }

  @override
  Future<void> play() async => _set(isPlaying: true);

  @override
  Future<void> pause() async => _set(isPlaying: false);

  @override
  Future<void> seekTo(Duration position) async => _set(position: position);

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> setPlaybackSpeed(double speed) async {}

  @override
  Future<void> setLooping(bool looping) async {}

  void _set({bool? isPlaying, Duration? position}) {
    _value = AppVideoBackendValue(
      isInitialized: _value.isInitialized,
      duration: _value.duration,
      aspectRatio: _value.aspectRatio,
      isPlaying: isPlaying ?? _value.isPlaying,
      position: position ?? _value.position,
    );
    notifyListeners();
  }

  @override
  Widget buildView(BuildContext context) => const DecoratedBox(
    key: ValueKey('flow-video'),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFF5B7DB1), Color(0xFFB07A5B)]),
    ),
  );

  @override
  Future<void> dispose() async => super.dispose();
}
