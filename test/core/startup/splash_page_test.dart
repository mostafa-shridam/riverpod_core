import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/async/error_state.dart';
import 'package:riverpod_core/core/startup/splash_page.dart';
import 'package:riverpod_core/core/startup/startup_controller.dart';
import 'package:riverpod_core/core/storage/secure_storage.dart';

import '../../features/auth/auth_harness.dart';
import '../../helpers/helpers.dart';

/// The sequence never finishes, so the splash stays in its loading state.
class _Hanging extends StartupController {
  @override
  Future<void> build() => Completer<void>().future;
}

/// Counts how many times the sequence ran.
class _Attempts {
  int count = 0;
}

/// The first run fails; a retry succeeds.
class _FailThenOk extends StartupController {
  _FailThenOk(this.attempts);

  final _Attempts attempts;

  @override
  Future<void> build() {
    attempts.count++;
    if (attempts.count == 1) return Future.error(StateError('keychain'));
    return Future.value();
  }
}

void main() {
  testWidgets('shows the mark and a spinner while starting', (tester) async {
    await pumpAuthPage(
      tester,
      const SplashPage(),
      settle: false,
      overrides: [
        startupControllerProvider.overrideWith(_Hanging.new),
        secureStorageProvider.overrideWithValue(FakeSecureStorage()),
      ],
    );

    expect(find.byKey(const ValueKey('splash-page')), findsOneWidget);
    expect(find.byType(ErrorState), findsNothing);
  });

  testWidgets('a failed step shows retry, and retry starts it again', (
    tester,
  ) async {
    final attempts = _Attempts();
    await pumpAuthPage(
      tester,
      const SplashPage(),
      settle: false,
      overrides: [
        startupControllerProvider.overrideWith(() => _FailThenOk(attempts)),
        secureStorageProvider.overrideWithValue(FakeSecureStorage()),
      ],
    );
    // The failed sequence reports after a microtask; pump once more for it.
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(ErrorState), findsNothing);
    expect(attempts.count, 2);
  });
}
