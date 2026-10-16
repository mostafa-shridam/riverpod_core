import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

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
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_section.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Checkbox, switch, radio, dropdown, segmented control, sliders, date and
/// time fields, rating and chip group, all live.
class SelectionSection extends StatefulWidget {
  const SelectionSection({super.key});

  @override
  State<SelectionSection> createState() => _SelectionSectionState();
}

class _SelectionSectionState extends State<SelectionSection> {
  static final _firstDate = DateTime(2020);
  static final _lastDate = DateTime(2035);

  bool _checked = true;
  bool _switched = true;
  int _radio = 1;
  int? _dropdown;
  int _segment = 0;
  double _slider = 0.4;
  RangeValues _range = const RangeValues(0.2, 0.7);
  DateTime? _date;
  TimeOfDay? _time;
  int _rating = 3;
  List<int> _chips = const [0];

  @override
  Widget build(BuildContext context) {
    final options = [
      for (var i = 0; i < 3; i++)
        AppSelectionOption<int>(
          value: i,
          label: LocaleKeys.showcase_selection_option.tr(args: ['${i + 1}']),
        ),
    ];
    return ShowcaseSection(
      sectionKey: const ValueKey('showcase-selection'),
      title: LocaleKeys.showcase_sections_selection.tr(),
      children: [
        AppCheckbox(
          value: _checked,
          onChanged: (v) => setState(() => _checked = v),
          label: LocaleKeys.showcase_selection_checkbox.tr(),
          subtitle: LocaleKeys.showcase_selection_checkboxHint.tr(),
        ),
        AppCheckbox(
          value: false,
          onChanged: null,
          label: LocaleKeys.showcase_selection_disabled.tr(),
        ),
        AppSwitch(
          value: _switched,
          onChanged: (v) => setState(() => _switched = v),
          label: LocaleKeys.showcase_selection_switch.tr(),
        ),
        AppRadioGroup<int>(
          label: LocaleKeys.showcase_selection_radio.tr(),
          value: _radio,
          onChanged: (v) => setState(() => _radio = v),
          options: [
            for (final o in options)
              AppRadioOption<int>(value: o.value, label: o.label),
          ],
        ),
        AppDropdown<int>(
          label: LocaleKeys.showcase_selection_dropdown.tr(),
          hint: LocaleKeys.showcase_selection_dropdownHint.tr(),
          options: options,
          value: _dropdown,
          onChanged: (v) => setState(() => _dropdown = v),
        ),
        AppSegmentedControl<int>(
          label: LocaleKeys.showcase_selection_segmented.tr(),
          value: _segment,
          onChanged: (v) => setState(() => _segment = v),
          segments: [
            for (final o in options)
              AppSegment<int>(value: o.value, label: o.label),
          ],
        ),
        AppSlider(
          label: LocaleKeys.showcase_selection_slider.tr(),
          value: _slider,
          onChanged: (v) => setState(() => _slider = v),
        ),
        AppRangeSlider(
          label: LocaleKeys.showcase_selection_range.tr(),
          values: _range,
          onChanged: (v) => setState(() => _range = v),
        ),
        AppDateField(
          label: LocaleKeys.showcase_selection_date.tr(),
          value: _date,
          firstDate: _firstDate,
          lastDate: _lastDate,
          onChanged: (v) => setState(() => _date = v),
        ),
        AppTimeField(
          label: LocaleKeys.showcase_selection_time.tr(),
          value: _time,
          onChanged: (v) => setState(() => _time = v),
        ),
        AppRating(
          label: LocaleKeys.showcase_selection_rating.tr(),
          value: _rating,
          onChanged: (v) => setState(() => _rating = v),
        ),
        AppChipGroup<int>(
          label: LocaleKeys.showcase_selection_chips.tr(),
          multiSelect: true,
          selected: _chips,
          onChanged: (v) => setState(() => _chips = v),
          options: [
            for (final o in options)
              AppChipOption<int>(value: o.value, label: o.label),
          ],
        ),
      ],
    );
  }
}
