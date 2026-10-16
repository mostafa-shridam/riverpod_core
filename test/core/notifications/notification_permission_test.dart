import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/notifications/models/notification_permission_state.dart';
import 'package:riverpod_core/core/notifications/permission/notification_permission_state.dart';
import 'package:riverpod_core/core/permissions/app_permission.dart';
import 'package:riverpod_core/core/permissions/permission_rationale.dart';
import 'package:riverpod_core/core/permissions/permission_service.dart';

import '../../helpers/fake_notification_backends.dart';

/// Notification permission goes through the shared [PermissionService]; these
/// tests pin what the notification UI sees from it.
void main() {
  late FakeNotificationPermissionBackend backend;
  late List<bool> rationaleCalls;
  late bool accept;

  Future<NotificationPermissionState> run(
    WidgetTester tester, {
    bool withPresenter = true,
  }) async {
    final service = PermissionService(
      backend: backend,
      presenter: withPresenter
          ? (context, PermissionRationaleRequest request) async {
              rationaleCalls.add(request.openSettings);
              return accept;
            }
          : null,
    );
    late BuildContext context;
    await tester.pumpWidget(
      Builder(
        builder: (c) {
          context = c;
          return const SizedBox();
        },
      ),
    );
    final result = (await tester.runAsync(
      () => service.ensure(AppPermission.notifications, context),
    ))!;
    return notificationStateOf(result);
  }

  setUp(() {
    backend = FakeNotificationPermissionBackend();
    rationaleCalls = [];
    accept = true;
  });

  testWidgets('granted: nothing shown, nothing requested', (tester) async {
    backend.state = AppPermissionResult.granted;

    final state = await run(tester);

    expect(state, NotificationPermissionState.granted);
    expect(rationaleCalls, isEmpty);
    expect(backend.requests, 0);
  });

  testWidgets('provisional counts as allowed and is not asked again', (
    tester,
  ) async {
    backend.state = AppPermissionResult.provisional;

    final state = await run(tester);

    expect(state, NotificationPermissionState.provisional);
    expect(state.isAllowed, isTrue);
    expect(backend.requests, 0);
  });

  testWidgets('denied, no rationale advised: straight to the prompt', (
    tester,
  ) async {
    final state = await run(tester);

    expect(rationaleCalls, isEmpty);
    expect(backend.requests, 1);
    expect(state, NotificationPermissionState.granted);
  });

  testWidgets('denied, rationale advised and accepted: rationale then prompt', (
    tester,
  ) async {
    backend.rationale = true;

    final state = await run(tester);

    expect(rationaleCalls, [false]);
    expect(backend.requests, 1);
    expect(state, NotificationPermissionState.granted);
  });

  testWidgets('denied, rationale advised and declined: no prompt', (
    tester,
  ) async {
    backend
      ..rationale = true
      ..requestResult = AppPermissionResult.granted;
    accept = false;

    final state = await run(tester);

    expect(backend.requests, 0);
    expect(state, NotificationPermissionState.denied);
  });

  testWidgets('denied, rationale advised but no presenter: prompt anyway', (
    tester,
  ) async {
    backend.rationale = true;

    await run(tester, withPresenter: false);

    expect(backend.requests, 1);
  });

  testWidgets('the user refuses the prompt: permanently denied is returned', (
    tester,
  ) async {
    backend.requestResult = AppPermissionResult.permanentlyDenied;

    final state = await run(tester);

    expect(state, NotificationPermissionState.permanentlyDenied);
  });

  testWidgets('permanently denied, accepted: settings open, no prompt', (
    tester,
  ) async {
    backend.state = AppPermissionResult.permanentlyDenied;

    final state = await run(tester);

    expect(rationaleCalls, [true]);
    expect(backend.settingsOpened, 1);
    expect(backend.requests, 0);
    expect(state, NotificationPermissionState.permanentlyDenied);
  });

  testWidgets('permanently denied, declined: nothing opens', (tester) async {
    backend.state = AppPermissionResult.permanentlyDenied;
    accept = false;

    await run(tester);

    expect(backend.settingsOpened, 0);
  });

  testWidgets('permanently denied without a presenter: nothing opens', (
    tester,
  ) async {
    backend.state = AppPermissionResult.permanentlyDenied;

    await run(tester, withPresenter: false);

    expect(backend.settingsOpened, 0);
  });

  group('state names for the notification UI', () {
    test('limited is granted, restricted is permanently denied', () {
      expect(
        notificationStateOf(AppPermissionResult.limited),
        NotificationPermissionState.granted,
      );
      expect(
        notificationStateOf(AppPermissionResult.restricted),
        NotificationPermissionState.permanentlyDenied,
      );
    });

    test('provisional stays provisional', () {
      expect(
        notificationStateOf(AppPermissionResult.provisional),
        NotificationPermissionState.provisional,
      );
    });
  });
}
