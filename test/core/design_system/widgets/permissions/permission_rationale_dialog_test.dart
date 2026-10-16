import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/permissions/permission_rationale_dialog.dart';
import 'package:riverpod_core/core/permissions/app_permission.dart';
import 'package:riverpod_core/core/permissions/permission_rationale.dart';

import '../display/ds_test_harness.dart';

Widget _launcher(
  AppPermission permission,
  bool openSettings,
  void Function(bool?) onResult,
) {
  return Builder(
    builder: (context) => TextButton(
      onPressed: () async {
        onResult(
          await showPermissionRationale(
            context,
            PermissionRationaleRequest(
              permission: permission,
              openSettings: openSettings,
            ),
          ),
        );
      },
      child: const Text('open'),
    ),
  );
}

/// The English title each permission explains with (the copy is per
/// permission, so each one is checked by its exact text).
const _titles = {
  AppPermission.camera: 'Camera access',
  AppPermission.photos: 'Photos access',
  AppPermission.microphone: 'Microphone access',
  AppPermission.notifications: 'Turn on notifications',
};

void main() {
  for (final permission in AppPermission.values) {
    testWidgets('shows ${permission.name} texts and Allow in en', (
      tester,
    ) async {
      await pumpDs(
        tester,
        PermissionRationaleDialog(permission: permission),
        scaffold: false,
      );
      expect(find.text(_titles[permission]!), findsOneWidget);
      expect(find.text('Allow'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('openSettings variant shows hint and Open settings', (
    tester,
  ) async {
    await pumpDs(
      tester,
      const PermissionRationaleDialog(
        permission: AppPermission.camera,
        openSettings: true,
      ),
      scaffold: false,
    );
    expect(find.text('Open settings'), findsOneWidget);
    expect(find.text('Allow'), findsNothing);
    expect(find.textContaining('app settings'), findsOneWidget);
  });

  testWidgets('arabic locale resolves translated labels', (tester) async {
    await pumpDs(
      tester,
      const PermissionRationaleDialog(permission: AppPermission.photos),
      locale: 'ar',
      scaffold: false,
    );
    expect(find.text('سماح'), findsOneWidget);
    expect(find.text('ليس الآن'), findsOneWidget);
    expect(find.text('Allow'), findsNothing);
  });

  testWidgets('label overrides win over translations', (tester) async {
    await pumpDs(
      tester,
      const PermissionRationaleDialog(
        permission: AppPermission.camera,
        title: 'T',
        message: 'M',
        confirmLabel: 'Yes',
        cancelLabel: 'No',
      ),
      scaffold: false,
    );
    expect(find.text('T'), findsOneWidget);
    expect(find.text('M'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
  });

  testWidgets('accept pops true, decline pops false, dismiss is false', (
    tester,
  ) async {
    bool? result;
    await pumpDs(
      tester,
      _launcher(AppPermission.camera, false, (r) => result = r),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();
    expect(result, isTrue);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(result, isFalse);

    result = null;
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(2, 2));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('survives text scale 2.0 on phone in ar and en', (tester) async {
    for (final locale in ['en', 'ar']) {
      await pumpDs(
        tester,
        const PermissionRationaleDialog(
          permission: AppPermission.microphone,
          openSettings: true,
        ),
        locale: locale,
        textScale: 2,
        scaffold: false,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('buttons keep a 48 dp touch target', (tester) async {
    await pumpDs(
      tester,
      const PermissionRationaleDialog(permission: AppPermission.camera),
      scaffold: false,
    );
    expect(
      tester.getSize(find.byType(FilledButton)).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester.getSize(find.byType(TextButton)).height,
      greaterThanOrEqualTo(48),
    );
  });

  group('golden', () {
    for (final mode in goldenModes) {
      testWidgets(mode.name, (tester) async {
        await pumpDs(
          tester,
          const PermissionRationaleDialog(
            permission: AppPermission.camera,
            openSettings: true,
          ),
          locale: mode.locale,
          dark: mode.dark,
          scaffold: false,
        );
        await expectLater(
          find.byType(Dialog),
          matchesGoldenFile(
            '../../../../goldens/permissions/rationale_${mode.name}.png',
          ),
        );
      });
    }
  });
}
