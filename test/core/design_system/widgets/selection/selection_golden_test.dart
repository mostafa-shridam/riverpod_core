import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/design_system/widgets/bottom_sheets/app_selection_sheet.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_checkbox.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_chip_group.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_date_field.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_dropdown.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_radio_group.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_rating.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_segmented_control.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_slider.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_switch.dart';
import 'package:riverpod_core/core/design_system/widgets/selection/app_time_field.dart';

import '../display/ds_test_harness.dart';

Widget _gallery({required bool arabic}) {
  Widget gap() => const SizedBox(height: 12);
  final fruit = [
    AppSelectionOption(value: 1, label: arabic ? 'تفاح' : 'Apple'),
    AppSelectionOption(value: 2, label: arabic ? 'موز' : 'Banana'),
  ];
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsetsDirectional.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCheckbox(
            value: true,
            onChanged: (_) {},
            label: arabic ? 'أوافق على الشروط' : 'I accept the terms',
            subtitle: arabic ? 'مطلوب للمتابعة' : 'Required to continue',
          ),
          AppCheckbox(
            value: false,
            onChanged: (_) {},
            label: arabic ? 'غير محدد' : 'Unchecked',
            errorText: arabic ? 'هذا الحقل مطلوب' : 'This field is required',
          ),
          AppCheckbox(
            value: true,
            onChanged: null,
            label: arabic ? 'معطل' : 'Disabled',
          ),
          AppSwitch(
            value: true,
            onChanged: (_) {},
            label: arabic ? 'الإشعارات' : 'Notifications',
          ),
          AppSwitch(
            value: false,
            onChanged: (_) {},
            label: arabic ? 'الوضع الليلي' : 'Dark mode',
          ),
          gap(),
          AppRadioGroup<int>(
            label: arabic ? 'الخطة' : 'Plan',
            value: 2,
            onChanged: (_) {},
            options: [
              AppRadioOption(value: 1, label: arabic ? 'مجانية' : 'Free'),
              AppRadioOption(
                value: 2,
                label: arabic ? 'احترافية' : 'Pro',
                subtitle: arabic ? 'الأكثر شيوعا' : 'Most popular',
              ),
            ],
          ),
          gap(),
          AppDropdown<int>(
            label: arabic ? 'الفاكهة' : 'Fruit',
            options: fruit,
            value: 2,
            onChanged: (_) {},
          ),
          gap(),
          AppDropdown<int>(
            label: arabic ? 'الفاكهة' : 'Fruit',
            options: fruit,
            value: null,
            onChanged: (_) {},
            errorText: arabic ? 'هذا الحقل مطلوب' : 'This field is required',
          ),
          gap(),
          AppDateField(
            label: arabic ? 'تاريخ الميلاد' : 'Birthday',
            value: DateTime(2024, 5, 10),
            onChanged: (_) {},
            firstDate: DateTime(2000),
            lastDate: DateTime(2030),
          ),
          gap(),
          AppTimeField(
            label: arabic ? 'المنبه' : 'Alarm',
            value: const TimeOfDay(hour: 14, minute: 30),
            onChanged: (_) {},
          ),
          gap(),
          AppDropdown<int>(
            label: arabic ? 'معطل' : 'Disabled',
            options: fruit,
            value: 1,
            onChanged: null,
          ),
          gap(),
          AppSegmentedControl<int>(
            label: arabic ? 'العرض' : 'View',
            value: 2,
            onChanged: (_) {},
            segments: [
              AppSegment(value: 1, label: arabic ? 'يوم' : 'Day'),
              AppSegment(value: 2, label: arabic ? 'أسبوع' : 'Week'),
              AppSegment(value: 3, label: arabic ? 'شهر' : 'Month'),
            ],
          ),
          gap(),
          AppSlider(
            label: arabic ? 'الصوت' : 'Volume',
            value: 40,
            max: 100,
            onChanged: (_) {},
          ),
          AppRangeSlider(
            label: arabic ? 'السعر' : 'Price',
            values: const RangeValues(20, 70),
            max: 100,
            divisions: 10,
            onChanged: (_) {},
          ),
          gap(),
          AppRating(
            label: arabic ? 'التقييم' : 'Rating',
            value: 3,
            onChanged: (_) {},
          ),
          gap(),
          AppChipGroup<int>(
            label: arabic ? 'الوسوم' : 'Tags',
            multiSelect: true,
            selected: const [1, 3],
            onChanged: (_) {},
            options: [
              AppChipOption(value: 1, label: arabic ? 'جديد' : 'New'),
              AppChipOption(value: 2, label: arabic ? 'عروض' : 'Offers'),
              AppChipOption(
                value: 3,
                label: arabic ? 'شائع' : 'Popular',
                icon: Icons.local_fire_department_outlined,
              ),
              AppChipOption(value: 4, label: arabic ? 'قريبا' : 'Soon'),
            ],
          ),
        ],
      ),
    ),
  );
}

void main() {
  for (final scale in [1.0, 2.0]) {
    for (final mode in goldenModes) {
      testWidgets('selection gallery ${mode.name} x$scale', (tester) async {
        await pumpDs(
          tester,
          _gallery(arabic: mode.locale == 'ar'),
          locale: mode.locale,
          dark: mode.dark,
          textScale: scale,
          size: Size(400, scale > 1 ? 2400 : 1400),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byType(Scaffold),
          matchesGoldenFile(
            '../../../../goldens/selection/gallery_${mode.name}_x${scale.toInt()}.png',
          ),
        );
      });
    }
  }
}
