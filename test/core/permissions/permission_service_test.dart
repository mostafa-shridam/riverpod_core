import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/permissions/app_permission.dart';
import 'package:riverpod_core/core/permissions/permission_rationale.dart';
import 'package:riverpod_core/core/permissions/permission_service.dart';

import '../../helpers/helpers.dart';

class FakePermissionBackend implements PermissionBackend {
  FakePermissionBackend({
    this.current = AppPermissionResult.denied,
    this.afterRequest = AppPermissionResult.granted,
    this.rationale = false,
  });

  AppPermissionResult current;
  AppPermissionResult afterRequest;
  bool rationale;
  int requests = 0;
  int settingsOpened = 0;

  @override
  Future<AppPermissionResult> status(AppPermission permission) async => current;

  @override
  Future<AppPermissionResult> request(AppPermission permission) async {
    requests++;
    return afterRequest;
  }

  @override
  Future<bool> shouldShowRationale(AppPermission permission) async => rationale;

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }
}

void main() {
  late BuildContext context;
  late List<PermissionRationaleRequest> shown;
  var accept = true;

  Future<bool> presenter(BuildContext _, PermissionRationaleRequest r) async {
    shown.add(r);
    return accept;
  }

  setUp(() {
    shown = [];
    accept = true;
  });

  Future<void> pumpContext(WidgetTester tester) async {
    await tester.pumpWidget(
      Builder(
        builder: (c) {
          context = c;
          return const SizedBox();
        },
      ),
    );
  }

  testWidgets('granted returns without prompting', (tester) async {
    await pumpContext(tester);
    final backend = FakePermissionBackend(current: AppPermissionResult.granted);
    final result = await PermissionService(
      backend: backend,
      presenter: presenter,
    ).ensure(AppPermission.camera, context);
    expect(result, AppPermissionResult.granted);
    expect(backend.requests, 0);
    expect(shown, isEmpty);
  });

  testWidgets('limited and restricted are returned untouched', (tester) async {
    await pumpContext(tester);
    for (final state in [
      AppPermissionResult.limited,
      AppPermissionResult.restricted,
    ]) {
      final backend = FakePermissionBackend(current: state);
      final result = await PermissionService(
        backend: backend,
        presenter: presenter,
      ).ensure(AppPermission.photos, context);
      expect(result, state);
      expect(backend.requests, 0);
    }
  });

  testWidgets('denied without rationale requests directly', (tester) async {
    await pumpContext(tester);
    final backend = FakePermissionBackend();
    final result = await PermissionService(
      backend: backend,
      presenter: presenter,
    ).ensure(AppPermission.camera, context);
    expect(result, AppPermissionResult.granted);
    expect(backend.requests, 1);
    expect(shown, isEmpty);
  });

  testWidgets('denied with rationale explains then requests', (tester) async {
    await pumpContext(tester);
    final backend = FakePermissionBackend(rationale: true);
    final result = await PermissionService(
      backend: backend,
      presenter: presenter,
    ).ensure(AppPermission.microphone, context);
    expect(result, AppPermissionResult.granted);
    expect(shown.single.permission, AppPermission.microphone);
    expect(shown.single.openSettings, isFalse);
    expect(backend.requests, 1);
  });

  testWidgets('declined rationale does not request', (tester) async {
    await pumpContext(tester);
    accept = false;
    final backend = FakePermissionBackend(rationale: true);
    final result = await PermissionService(
      backend: backend,
      presenter: presenter,
    ).ensure(AppPermission.camera, context);
    expect(result, AppPermissionResult.denied);
    expect(backend.requests, 0);
  });

  testWidgets('request outcome is returned (denied again)', (tester) async {
    await pumpContext(tester);
    final backend = FakePermissionBackend(
      afterRequest: AppPermissionResult.permanentlyDenied,
    );
    final result = await PermissionService(
      backend: backend,
      presenter: presenter,
    ).ensure(AppPermission.camera, context);
    expect(result, AppPermissionResult.permanentlyDenied);
  });

  testWidgets('permanently denied offers settings and opens them', (
    tester,
  ) async {
    await pumpContext(tester);
    final backend = FakePermissionBackend(
      current: AppPermissionResult.permanentlyDenied,
    );
    final result = await PermissionService(
      backend: backend,
      presenter: presenter,
    ).ensure(AppPermission.camera, context);
    expect(result, AppPermissionResult.permanentlyDenied);
    expect(shown.single.openSettings, isTrue);
    expect(backend.settingsOpened, 1);
    expect(backend.requests, 0);
  });

  testWidgets('permanently denied declined keeps settings closed', (
    tester,
  ) async {
    await pumpContext(tester);
    accept = false;
    final backend = FakePermissionBackend(
      current: AppPermissionResult.permanentlyDenied,
    );
    await PermissionService(
      backend: backend,
      presenter: presenter,
    ).ensure(AppPermission.camera, context);
    expect(backend.settingsOpened, 0);
  });

  testWidgets('without a presenter denied still requests', (tester) async {
    await pumpContext(tester);
    final backend = FakePermissionBackend(rationale: true);
    final result = await PermissionService(
      backend: backend,
    ).ensure(AppPermission.camera, context);
    expect(result, AppPermissionResult.granted);
    expect(backend.requests, 1);
  });

  test('isUsable is true only for granted and limited', () {
    expect(AppPermissionResult.granted.isUsable, isTrue);
    expect(AppPermissionResult.limited.isUsable, isTrue);
    expect(AppPermissionResult.denied.isUsable, isFalse);
    expect(AppPermissionResult.restricted.isUsable, isFalse);
  });

  test('provider wires the overridden backend', () async {
    final backend = FakePermissionBackend(current: AppPermissionResult.granted);
    final container = createContainer(
      overrides: [permissionBackendProvider.overrideWithValue(backend)],
    );
    expect(
      await container
          .read(permissionServiceProvider)
          .status(AppPermission.camera),
      AppPermissionResult.granted,
    );
  });
}
