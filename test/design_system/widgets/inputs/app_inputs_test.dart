import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/utils/validators.dart';
import 'package:riverpod_core/design_system/widgets/inputs/app_otp_field.dart';
import 'package:riverpod_core/design_system/widgets/inputs/app_password_field.dart';
import 'package:riverpod_core/design_system/widgets/inputs/app_phone_field.dart';
import 'package:riverpod_core/design_system/widgets/inputs/app_search_field.dart';
import 'package:riverpod_core/design_system/widgets/inputs/app_text_field.dart';
import 'package:riverpod_core/design_system/widgets/inputs/validation_message.dart';

import '../../../helpers/helpers.dart';

void main() {
  group('AppTextField', () {
    testWidgets('shows label and helper text', (tester) async {
      await pumpApp(
        tester,
        const AppTextField(label: 'Name', helper: 'As on your ID'),
      );
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('As on your ID'), findsOneWidget);
    });

    testWidgets('shows the server error and hides the helper', (tester) async {
      await pumpApp(
        tester,
        const AppTextField(
          label: 'Name',
          helper: 'As on your ID',
          errorText: 'Taken',
        ),
      );
      expect(find.text('Taken'), findsOneWidget);
      // Flutter replaces the helper with the error while an error is set.
      expect(find.text('As on your ID'), findsNothing);
    });

    testWidgets('localized validator shows the English message', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      await pumpApp(
        tester,
        Form(
          key: formKey,
          child: AppTextField(
            label: 'Email',
            validator: localizedValidator(Validators.email),
          ),
        ),
      );
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('This field is required'), findsOneWidget);
    });

    testWidgets('localized validator shows the Arabic message in ar', (
      tester,
    ) async {
      final formKey = GlobalKey<FormState>();
      await pumpApp(
        tester,
        locale: const Locale('ar'),
        Form(
          key: formKey,
          child: AppTextField(
            label: 'Email',
            validator: localizedValidator(Validators.email),
          ),
        ),
      );
      formKey.currentState!.validate();
      await tester.pump();
      expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
    });

    testWidgets('disabled field does not accept input', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpApp(
        tester,
        AppTextField(controller: controller, enabled: false),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);
    });

    testWidgets('multiline field grows to maxLines', (tester) async {
      await pumpApp(
        tester,
        const AppTextField(label: 'Notes', maxLines: null, minLines: 3),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.maxLines, isNull);
      expect(field.minLines, 3);
    });

    testWidgets('counter appears with maxLength', (tester) async {
      await pumpApp(tester, const AppTextField(maxLength: 10));
      expect(find.text('0/10'), findsOneWidget);
    });

    testWidgets('no overflow at text scale 2.0 in RTL', (tester) async {
      await pumpApp(
        tester,
        locale: const Locale('ar'),
        textScale: 2,
        const AppTextField(label: 'Full name', helper: 'Helper text'),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('AppPasswordField', () {
    testWidgets('hidden by default and toggles visibility', (tester) async {
      final semantics = tester.ensureSemantics();

      await pumpApp(tester, const AppPasswordField(label: 'Password'));
      expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText,
        isTrue,
      );
      expect(find.byTooltip('Show password'), findsOneWidget);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText,
        isFalse,
      );
      expect(find.byTooltip('Hide password'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('AppSearchField', () {
    testWidgets('debounces onChanged and fires at once on clear', (
      tester,
    ) async {
      final values = <String>[];
      await pumpApp(tester, AppSearchField(onChanged: values.add));

      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump(const Duration(milliseconds: 100));
      expect(values, isEmpty, reason: 'still inside the debounce window');

      await tester.pump(const Duration(milliseconds: 300));
      expect(values, ['abc']);

      await tester.tap(find.byTooltip('Clear'));
      await tester.pump();
      expect(values.last, '');
      expect(find.text('abc'), findsNothing);
    });

    testWidgets('cancels the pending search on dispose', (tester) async {
      final values = <String>[];
      await pumpApp(tester, AppSearchField(onChanged: values.add));
      await tester.enterText(find.byType(TextField), 'x');
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(values, isEmpty);
    });
  });

  group('AppOtpField', () {
    testWidgets('keeps only digits, truncates a paste, completes once', (
      tester,
    ) async {
      final completed = <String>[];
      final semantics = tester.ensureSemantics();

      await pumpApp(tester, AppOtpField(length: 4, onCompleted: completed.add));

      await tester.enterText(find.byType(TextField), '12-34-99');
      await tester.pump();
      expect(completed, ['1234']);
      expect(find.bySemanticsLabel('Digit 4 of 4'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('digits read left to right even in RTL', (tester) async {
      await pumpApp(
        tester,
        locale: const Locale('ar'),
        const AppOtpField(length: 3),
      );
      final directions = tester
          .widgetList<Directionality>(find.byType(Directionality))
          .map((d) => d.textDirection)
          .toList();
      expect(directions, contains(TextDirection.ltr));
    });

    testWidgets('shows the error text', (tester) async {
      await pumpApp(
        tester,
        const AppOtpField(length: 4, errorText: 'Wrong code'),
      );
      expect(find.text('Wrong code'), findsOneWidget);
    });
  });

  group('AppPhoneField', () {
    testWidgets('accepts digits only', (tester) async {
      final values = <String>[];
      await pumpApp(tester, AppPhoneField(onChanged: values.add));
      await tester.enterText(find.byType(TextField), 'a1+2 3');
      await tester.pump();
      expect(values, ['123']);
      expect(
        tester.widget<TextField>(find.byType(TextField)).keyboardType,
        TextInputType.phone,
      );
    });
  });

  test('validationMessage covers every core error', () {
    for (final error in ValidationError.values) {
      expect(validationMessage(error), isNotEmpty);
    }
  });
}
