import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/security/secure_screen.dart';

import 'security_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannelSecureScreenBackend.channel;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  group('MethodChannelSecureScreenBackend', () {
    test('sends setSecure with the flag on Android and iOS', () async {
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        debugDefaultTargetPlatformOverride = platform;
        final calls = <MethodCall>[];
        messenger.setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });
        const backend = MethodChannelSecureScreenBackend();
        await backend.setSecure(secure: true);
        await backend.setSecure(secure: false);
        expect(calls.map((c) => c.method), everyElement('setSecure'));
        expect(calls.map((c) => c.arguments), [true, false]);
      }
    });

    test('is a no-op on unsupported platforms', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      var called = false;
      messenger.setMockMethodCallHandler(channel, (call) async {
        called = true;
        return null;
      });
      await const MethodChannelSecureScreenBackend().setSecure(secure: true);
      expect(called, isFalse);
    });

    test('a missing native handler is a no-op, not an error', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await const MethodChannelSecureScreenBackend().setSecure(secure: true);
    });

    test('a platform error is swallowed', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'boom');
      });
      await const MethodChannelSecureScreenBackend().setSecure(secure: true);
    });
  });

  group('SecureScreenGate', () {
    test('switches on with the first holder and off with the last', () async {
      final backend = FakeSecureScreenBackend();
      final gate = SecureScreenGate(backend);
      await gate.acquire();
      await gate.acquire();
      await gate.release();
      expect(backend.calls, [true], reason: 'one holder is still left');
      await gate.release();
      expect(backend.calls, [true, false]);
    });

    test('an extra release does nothing', () async {
      final backend = FakeSecureScreenBackend();
      final gate = SecureScreenGate(backend);
      await gate.release();
      expect(gate.holders, 0);
      expect(backend.calls, isEmpty);
    });
  });

  group('SecureScreen widget', () {
    testWidgets('protects while mounted and releases on dispose', (
      tester,
    ) async {
      final backend = FakeSecureScreenBackend();
      Widget app({required bool show}) => ProviderScope(
        overrides: [secureScreenBackendProvider.overrideWithValue(backend)],
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: show
              ? const SecureScreen(child: Text('secret'))
              : const SizedBox(),
        ),
      );

      await tester.pumpWidget(app(show: true));
      expect(find.text('secret'), findsOneWidget);
      expect(backend.calls, [true]);

      await tester.pumpWidget(app(show: false));
      expect(backend.calls, [true, false]);
    });
  });
}
