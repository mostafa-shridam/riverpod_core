import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/notifications/models/notification_permission_state.dart';
import 'package:riverpod_core/core/notifications/permission/notification_permission_flow.dart';

import '../../helpers/fake_notification_backends.dart';

void main() {
  late FakeNotificationPermissionBackend backend;
  late List<bool> rationaleCalls;
  late bool accept;

  Future<NotificationPermissionState> run(
    WidgetTester tester, {
    bool withPresenter = true,
  }) async {
    final flow = NotificationPermissionFlow(
      backend: backend,
      presenter: withPresenter
          ? (context, {required openSettings}) async {
              rationaleCalls.add(openSettings);
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
    return (await tester.runAsync(() => flow.ensure(context)))!;
  }

  setUp(() {
    backend = FakeNotificationPermissionBackend();
    rationaleCalls = [];
    accept = true;
  });

  testWidgets('granted: nothing shown, nothing requested', (tester) async {
    backend.state = NotificationPermissionState.granted;

    final state = await run(tester);

    expect(state, NotificationPermissionState.granted);
    expect(rationaleCalls, isEmpty);
    expect(backend.requests, 0);
  });

  testWidgets('provisional counts as allowed', (tester) async {
    backend.state = NotificationPermissionState.provisional;

    final state = await run(tester);

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
      ..requestResult = NotificationPermissionState.granted;
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

  testWidgets('the user refuses the prompt: denied is returned', (
    tester,
  ) async {
    backend.requestResult = NotificationPermissionState.permanentlyDenied;

    final state = await run(tester);

    expect(state, NotificationPermissionState.permanentlyDenied);
  });

  testWidgets('permanently denied, accepted: settings open, no prompt', (
    tester,
  ) async {
    backend.state = NotificationPermissionState.permanentlyDenied;

    final state = await run(tester);

    expect(rationaleCalls, [true]);
    expect(backend.settingsOpened, 1);
    expect(backend.requests, 0);
    expect(state, NotificationPermissionState.permanentlyDenied);
  });

  testWidgets('permanently denied, declined: nothing opens', (tester) async {
    backend.state = NotificationPermissionState.permanentlyDenied;
    accept = false;

    await run(tester);

    expect(backend.settingsOpened, 0);
  });

  testWidgets('permanently denied without a presenter: nothing opens', (
    tester,
  ) async {
    backend.state = NotificationPermissionState.permanentlyDenied;

    await run(tester, withPresenter: false);

    expect(backend.settingsOpened, 0);
  });
}
