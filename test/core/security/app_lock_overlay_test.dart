import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/security/app_lock_controller.dart';
import 'package:riverpod_core/core/security/app_lock_overlay.dart';
import 'package:riverpod_core/core/security/biometric_service.dart';
import 'package:riverpod_core/core/storage/prefs_storage.dart';

import '../../helpers/helpers.dart';
import 'security_fakes.dart';

const _content = Text('secret content', key: ValueKey('content'));

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required FakeBiometricBackend biometric,
  bool locked = true,
  Locale locale = const Locale('en'),
}) async {
  final overrides = await securityOverrides(
    tester,
    biometric: biometric,
    prefs: locked
        ? {
            PrefKeys.appLock: ['1'],
          }
        : const {},
  );
  await pumpApp(
    tester,
    const AppLockOverlay(child: _content),
    overrides: overrides,
    locale: locale,
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(AppLockOverlay)));
}

void main() {
  testWidgets('an unlocked app shows only its content', (tester) async {
    await _pump(tester, biometric: FakeBiometricBackend(), locked: false);
    expect(find.byKey(const ValueKey('content')), findsOneWidget);
    expect(find.byKey(const ValueKey('app-lock-screen')), findsNothing);
  });

  testWidgets('a cold start with the lock on prompts and unlocks', (
    tester,
  ) async {
    final biometric = FakeBiometricBackend();
    await _pump(tester, biometric: biometric);

    expect(biometric.reasons, hasLength(1), reason: 'prompted on its own');
    expect(find.byKey(const ValueKey('app-lock-screen')), findsNothing);
    expect(find.byKey(const ValueKey('content')), findsOneWidget);
  });

  testWidgets('after a cancel the lock screen stays with an unlock button', (
    tester,
  ) async {
    final biometric = FakeBiometricBackend(result: BiometricResult.cancelled);
    await _pump(tester, biometric: biometric);

    expect(find.byKey(const ValueKey('app-lock-screen')), findsOneWidget);
    expect(find.text('App locked'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('app-lock-screen')),
        matching: find.byType(AppButton),
      ),
      findsOneWidget,
    );
    biometric.result = BiometricResult.success;
    await tester.tap(find.text('Unlock'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('app-lock-screen')), findsNothing);
    expect(biometric.reasons, hasLength(2));
  });

  testWidgets('a failed unlock shows a message', (tester) async {
    await _pump(
      tester,
      biometric: FakeBiometricBackend(result: BiometricResult.lockedOut),
    );
    expect(find.textContaining('Too many attempts'), findsOneWidget);
  });

  testWidgets('going to the background covers the content without a button', (
    tester,
  ) async {
    final biometric = FakeBiometricBackend();
    final container = await _pump(tester, biometric: biometric);
    expect(find.byKey(const ValueKey('app-lock-screen')), findsNothing);

    container
        .read(appLockControllerProvider.notifier)
        .onLifecycle(AppLifecycleState.inactive);
    await tester.pump();

    expect(find.byKey(const ValueKey('app-lock-screen')), findsOneWidget);
    expect(find.text('Unlock'), findsNothing);

    container
        .read(appLockControllerProvider.notifier)
        .onLifecycle(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.byKey(const ValueKey('app-lock-screen')), findsNothing);
  });

  testWidgets('arabic lock screen is translated', (tester) async {
    await _pump(
      tester,
      biometric: FakeBiometricBackend(result: BiometricResult.cancelled),
      locale: const Locale('ar'),
    );
    expect(find.text('التطبيق مقفل'), findsOneWidget);
    expect(find.text('فتح القفل'), findsOneWidget);
  });
}
