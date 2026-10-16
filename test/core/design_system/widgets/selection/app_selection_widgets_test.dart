import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/bottom_sheets/app_selection_sheet.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_checkbox.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_chip_group.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_date_field.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_dropdown.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_form_field.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_radio_group.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_rating.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_segmented_control.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_slider.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_switch.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_time_field.dart';

import '../display/ds_test_harness.dart';

/// Holds one piece of state so controlled widgets can be exercised.
class _Host<T> extends StatefulWidget {
  const _Host({required this.initial, required this.builder});

  final T initial;
  final Widget Function(T value, ValueChanged<T> set) builder;

  @override
  State<_Host<T>> createState() => _HostState<T>();
}

class _HostState<T> extends State<_Host<T>> {
  late T _value = widget.initial;

  @override
  Widget build(BuildContext context) =>
      widget.builder(_value, (v) => setState(() => _value = v));
}

const _fruit = [
  AppSelectionOption(value: 'a', label: 'Apple'),
  AppSelectionOption(value: 'b', label: 'Banana'),
  AppSelectionOption(value: 'c', label: 'Cherry'),
];

void main() {
  group('AppCheckbox', () {
    testWidgets('toggles and meets the 48 dp target', (tester) async {
      await pumpDs(
        tester,
        _Host<bool>(
          initial: false,
          builder: (v, set) =>
              AppCheckbox(value: v, onChanged: set, label: 'Accept'),
        ),
      );
      expect(
        tester.getSize(find.byType(CheckboxListTile)).height,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(find.text('Accept'));
      await tester.pump();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    });

    testWidgets('disabled does not change', (tester) async {
      var calls = 0;
      await pumpDs(
        tester,
        AppCheckbox(
          value: false,
          onChanged: (_) => calls++,
          label: 'Accept',
          enabled: false,
        ),
      );
      await tester.tap(find.text('Accept'));
      expect(calls, 0);
    });

    testWidgets('validator error shows and clears', (tester) async {
      final key = GlobalKey<FormState>();
      await pumpDs(
        tester,
        Form(
          key: key,
          child: _Host<bool>(
            initial: false,
            builder: (v, set) => AppCheckbox(
              value: v,
              onChanged: set,
              label: 'Accept',
              validator: (v) => v == true ? null : 'Must accept',
            ),
          ),
        ),
      );
      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Must accept'), findsOneWidget);
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();
      expect(key.currentState!.validate(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Must accept'), findsNothing);
    });
  });

  group('AppSwitch', () {
    testWidgets('toggles', (tester) async {
      await pumpDs(
        tester,
        _Host<bool>(
          initial: false,
          builder: (v, set) => AppSwitch(
            value: v,
            onChanged: set,
            label: 'Alerts',
            subtitle: 'Push',
          ),
        ),
      );
      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect(find.text('Push'), findsOneWidget);
    });

    testWidgets('null onChanged disables', (tester) async {
      await pumpDs(
        tester,
        const AppSwitch(value: true, onChanged: null, label: 'Alerts'),
      );
      expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
    });
  });

  group('AppRadioGroup', () {
    Widget group({FormFieldValidator<String>? validator}) => _Host<String?>(
      initial: null,
      builder: (v, set) => AppRadioGroup<String>(
        label: 'Plan',
        value: v,
        onChanged: set,
        validator: validator,
        options: const [
          AppRadioOption(value: 'free', label: 'Free'),
          AppRadioOption(value: 'pro', label: 'Pro', subtitle: 'Paid'),
          AppRadioOption(value: 'x', label: 'Locked', enabled: false),
        ],
      ),
    );

    testWidgets('selects one at a time', (tester) async {
      await pumpDs(tester, group());
      await tester.tap(find.text('Pro'));
      await tester.pump();
      await tester.tap(find.text('Free'));
      await tester.pump();
      final radios = tester.widget<RadioGroup<String>>(
        find.byType(RadioGroup<String>),
      );
      expect(radios.groupValue, 'free');
      expect(find.text('Plan'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
    });

    testWidgets('disabled option is ignored; validator reports', (
      tester,
    ) async {
      final key = GlobalKey<FormState>();
      await pumpDs(
        tester,
        Form(
          key: key,
          child: group(validator: (v) => v == null ? 'Pick' : null),
        ),
      );
      await tester.tap(find.text('Locked'));
      await tester.pump();
      expect(key.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Pick'), findsOneWidget);
    });
  });

  group('AppDropdown', () {
    testWidgets('opens the sheet and picks', (tester) async {
      String? changed;
      await pumpDs(
        tester,
        _Host<String?>(
          initial: null,
          builder: (v, set) => AppDropdown<String>(
            label: 'Fruit',
            options: _fruit,
            value: v,
            onChanged: (x) {
              changed = x;
              set(x);
            },
          ),
        ),
      );
      await tester.tap(find.byType(AppDropdown<String>));
      await tester.pumpAndSettle();
      expect(find.byType(AppSelectionSheet<String>), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();
      expect(changed, 'b');
      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('searchable filters the options', (tester) async {
      await pumpDs(
        tester,
        AppDropdown<String>(
          options: _fruit,
          value: null,
          onChanged: (_) {},
          searchable: true,
        ),
      );
      await tester.tap(find.byType(AppDropdown<String>));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'ch');
      await tester.pumpAndSettle();
      expect(find.text('Cherry'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
    });

    testWidgets('dismissed sheet keeps value; disabled does not open', (
      tester,
    ) async {
      var calls = 0;
      await pumpDs(
        tester,
        Column(
          children: [
            AppDropdown<String>(
              options: _fruit,
              value: 'a',
              onChanged: (_) => calls++,
              label: 'On',
            ),
            AppDropdown<String>(
              options: _fruit,
              value: 'a',
              onChanged: (_) => calls++,
              label: 'Off',
              enabled: false,
            ),
          ],
        ),
      );
      await tester.tap(find.byType(AppDropdown<String>).last);
      await tester.pumpAndSettle();
      expect(find.byType(AppSelectionSheet<String>), findsNothing);
      await tester.tap(find.byType(AppDropdown<String>).first);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(200, 20));
      await tester.pumpAndSettle();
      expect(calls, 0);
    });

    testWidgets('validator and server error text show in the field', (
      tester,
    ) async {
      final key = GlobalKey<FormState>();
      await pumpDs(
        tester,
        Form(
          key: key,
          child: AppDropdown<String>(
            options: _fruit,
            value: null,
            onChanged: (_) {},
            validator: (v) => v == null ? 'Required' : null,
          ),
        ),
      );
      key.currentState!.validate();
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('has button semantics with the chosen value', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        AppDropdown<String>(
          label: 'Fruit',
          options: _fruit,
          value: 'c',
          onChanged: (_) {},
        ),
      );
      final node = tester.getSemantics(find.byType(InkWell).first);
      expect(node.label, contains('Fruit'));
      expect(node.value, 'Cherry');
      handle.dispose();
    });
  });

  group('AppSegmentedControl', () {
    testWidgets('selects a segment, shows a check', (tester) async {
      await pumpDs(
        tester,
        _Host<String>(
          initial: 'day',
          builder: (v, set) => AppSegmentedControl<String>(
            value: v,
            onChanged: set,
            segments: const [
              AppSegment(value: 'day', label: 'Day'),
              AppSegment(value: 'week', label: 'Week'),
              AppSegment(value: 'off', label: 'Off', enabled: false),
            ],
          ),
        ),
      );
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      await tester.tap(find.text('Week'));
      await tester.pump();
      expect(
        find.descendant(
          of: find.widgetWithText(InkWell, 'Week'),
          matching: find.byIcon(Icons.check_rounded),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Off'));
      await tester.pump();
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('long labels wrap at text scale 2.0', (tester) async {
      await pumpDs(
        tester,
        AppSegmentedControl<int>(
          value: 1,
          onChanged: (_) {},
          segments: const [
            AppSegment(value: 1, label: 'Daily'),
            AppSegment(value: 2, label: 'Weekly'),
            AppSegment(value: 3, label: 'Monthly'),
          ],
        ),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('AppSlider', () {
    testWidgets('drag changes value, value text shown', (tester) async {
      double? last;
      await pumpDs(
        tester,
        _Host<double>(
          initial: 0,
          builder: (v, set) => AppSlider(
            label: 'Volume',
            value: v,
            max: 100,
            onChanged: (x) {
              last = x;
              set(x);
            },
          ),
        ),
      );
      expect(find.text('0'), findsOneWidget);
      await tester.drag(find.byType(Slider), const Offset(150, 0));
      await tester.pump();
      expect(last, greaterThan(0));
    });

    testWidgets('validator and disabled', (tester) async {
      final key = GlobalKey<FormState>();
      await pumpDs(
        tester,
        Form(
          key: key,
          child: AppSlider(
            value: 0,
            onChanged: null,
            validator: (v) => (v ?? 0) > 0 ? null : 'Too low',
          ),
        ),
      );
      expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
      key.currentState!.validate();
      await tester.pump();
      expect(find.text('Too low'), findsOneWidget);
    });

    testWidgets('range slider reports both ends', (tester) async {
      RangeValues? last;
      await pumpDs(
        tester,
        _Host<RangeValues>(
          initial: const RangeValues(20, 80),
          builder: (v, set) => AppRangeSlider(
            values: v,
            max: 100,
            onChanged: (x) {
              last = x;
              set(x);
            },
          ),
        ),
      );
      expect(find.text('20 - 80'), findsOneWidget);
      final start = tester.getTopLeft(find.byType(RangeSlider));
      await tester.dragFrom(start + const Offset(80, 24), const Offset(-40, 0));
      await tester.pump();
      expect(last, isNotNull);
      expect(last!.end, 80);
    });
  });

  group('AppDateField / AppTimeField', () {
    testWidgets('date picker returns a localized value', (tester) async {
      await pumpDs(
        tester,
        _Host<DateTime?>(
          initial: null,
          builder: (v, set) => AppDateField(
            label: 'Birthday',
            value: v,
            onChanged: set,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            initialDate: DateTime(2024, 5, 10),
          ),
        ),
      );
      await tester.tap(find.byType(AppDateField));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.textContaining('May 10'), findsOneWidget);
    });

    testWidgets('date picker cancel keeps null', (tester) async {
      var calls = 0;
      await pumpDs(
        tester,
        AppDateField(
          value: null,
          onChanged: (_) => calls++,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          initialDate: DateTime(2024, 5, 10),
        ),
      );
      await tester.tap(find.byType(AppDateField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(calls, 0);
    });

    testWidgets('time picker returns a value', (tester) async {
      await pumpDs(
        tester,
        _Host<TimeOfDay?>(
          initial: null,
          builder: (v, set) =>
              AppTimeField(label: 'Alarm', value: v, onChanged: set),
        ),
      );
      await tester.tap(find.byType(AppTimeField));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.textContaining('9:00'), findsOneWidget);
    });

    testWidgets('formats in Arabic and honors validators', (tester) async {
      final key = GlobalKey<FormState>();
      await pumpDs(
        tester,
        Form(
          key: key,
          child: AppDateField(
            value: DateTime(2024, 5, 10),
            onChanged: (_) {},
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            validator: (d) => 'Bad date',
          ),
        ),
        locale: 'ar',
      );
      expect(find.textContaining('2024'), findsNothing); // Arabic digits
      key.currentState!.validate();
      await tester.pump();
      expect(find.text('Bad date'), findsOneWidget);
    });
  });

  group('AppRating', () {
    testWidgets('tap sets, tap again clears, read-only ignores', (
      tester,
    ) async {
      await pumpDs(
        tester,
        _Host<int>(
          initial: 0,
          builder: (v, set) =>
              AppRating(label: 'Rate', value: v, onChanged: set),
        ),
      );
      expect(find.byIcon(Icons.star_rounded), findsNothing);
      await tester.tap(find.byIcon(Icons.star_outline_rounded).at(2));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      await tester.tap(find.byIcon(Icons.star_rounded).at(2));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.star_rounded), findsNothing);
    });

    testWidgets('read-only does not react; semantics expose value', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpDs(tester, const AppRating(value: 4, onChanged: null));
      await tester.tap(find.byIcon(Icons.star_outline_rounded));
      await tester.pump();
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
      expect(find.bySemanticsLabel(RegExp('')), findsWidgets);
      handle.dispose();
    });

    testWidgets('semantic increase', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        _Host<int>(
          initial: 2,
          builder: (v, set) =>
              AppRating(label: 'Rate', value: v, onChanged: set),
        ),
      );
      final node = find.semantics.byValue('2 of 5').evaluate().single;
      expect(node.label, 'Rate');
      tester.semantics.increase(find.semantics.byValue('2 of 5'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      handle.dispose();
    });

    testWidgets('validator requires a rating', (tester) async {
      final key = GlobalKey<FormState>();
      await pumpDs(
        tester,
        Form(
          key: key,
          child: AppRating(
            value: 0,
            onChanged: (_) {},
            validator: (v) => (v ?? 0) == 0 ? 'Rate us' : null,
          ),
        ),
      );
      key.currentState!.validate();
      await tester.pump();
      expect(find.text('Rate us'), findsOneWidget);
    });
  });

  group('AppChipGroup', () {
    const options = [
      AppChipOption(value: 1, label: 'One'),
      AppChipOption(value: 2, label: 'Two'),
      AppChipOption(value: 3, label: 'Three', enabled: false),
    ];

    testWidgets('single select replaces and clears', (tester) async {
      List<int>? last;
      await pumpDs(
        tester,
        _Host<List<int>>(
          initial: const [],
          builder: (v, set) => AppChipGroup<int>(
            options: options,
            selected: v,
            onChanged: (x) {
              last = x;
              set(x);
            },
          ),
        ),
      );
      await tester.tap(find.text('One'));
      await tester.pump();
      await tester.tap(find.text('Two'));
      await tester.pump();
      expect(last, [2]);
      await tester.tap(find.text('Two'));
      await tester.pump();
      expect(last, <int>[]);
    });

    testWidgets('multi select keeps option order; disabled ignored', (
      tester,
    ) async {
      List<int>? last;
      await pumpDs(
        tester,
        _Host<List<int>>(
          initial: const [],
          builder: (v, set) => AppChipGroup<int>(
            options: options,
            selected: v,
            multiSelect: true,
            onChanged: (x) {
              last = x;
              set(x);
            },
          ),
        ),
      );
      await tester.tap(find.text('Two'));
      await tester.pump();
      await tester.tap(find.text('One'));
      await tester.pump();
      await tester.tap(find.text('Three'));
      await tester.pump();
      expect(last, [1, 2]);
    });

    testWidgets('validator and label', (tester) async {
      final key = GlobalKey<FormState>();
      await pumpDs(
        tester,
        Form(
          key: key,
          child: AppChipGroup<int>(
            label: 'Tags',
            options: options,
            selected: const [],
            onChanged: (_) {},
            validator: (v) => (v ?? []).isEmpty ? 'Pick one' : null,
          ),
        ),
      );
      key.currentState!.validate();
      await tester.pump();
      expect(find.text('Tags'), findsOneWidget);
      expect(find.text('Pick one'), findsOneWidget);
    });
  });

  group('AppFormField', () {
    testWidgets('label, helper, error and save/reset in a Form', (
      tester,
    ) async {
      final key = GlobalKey<FormState>();
      int? saved;
      await pumpDs(
        tester,
        Form(
          key: key,
          child: AppFormField<int>(
            value: 3,
            label: 'Custom',
            helper: 'Help text',
            validator: (v) => v == 3 ? 'Three is bad' : null,
            onSaved: (v) => saved = v,
            builder: (state) => TextButton(
              onPressed: () => state.didChange(4),
              child: const Text('bump'),
            ),
          ),
        ),
      );
      expect(find.text('Custom'), findsOneWidget);
      expect(find.text('Help text'), findsOneWidget);
      expect(key.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('Three is bad'), findsOneWidget);
      expect(find.text('Help text'), findsNothing);
      await tester.tap(find.text('bump'));
      await tester.pumpAndSettle();
      expect(find.text('Three is bad'), findsNothing);
      key.currentState!.save();
      expect(saved, 4);
      key.currentState!.reset();
      await tester.pumpAndSettle();
      expect(find.text('Help text'), findsOneWidget);
    });

    testWidgets('controlled value updates the validated value', (tester) async {
      final key = GlobalKey<FormState>();
      await pumpDs(
        tester,
        Form(
          key: key,
          child: _Host<bool>(
            initial: false,
            builder: (v, set) => Column(
              children: [
                AppCheckbox(
                  value: v,
                  onChanged: set,
                  label: 'Accept',
                  validator: (v) => v == true ? null : 'No',
                ),
                TextButton(onPressed: () => set(true), child: const Text('go')),
              ],
            ),
          ),
        ),
      );
      expect(key.currentState!.validate(), isFalse);
      await tester.tap(find.text('go'));
      await tester.pump();
      expect(key.currentState!.validate(), isTrue);
    });
  });
}
