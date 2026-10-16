import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_fab.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_icon_button.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_group.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_section.dart';

/// Every `AppButton` variant, size, loading and disabled state, plus icon
/// buttons and FABs.
class ButtonsSection extends StatefulWidget {
  const ButtonsSection({super.key});

  @override
  State<ButtonsSection> createState() => _ButtonsSectionState();
}

class _ButtonsSectionState extends State<ButtonsSection> {
  bool _loading = false;

  static void _noop() {}

  String _variantLabel(AppButtonVariant variant) => switch (variant) {
    AppButtonVariant.primary => 'showcase.buttons.primary'.tr(),
    AppButtonVariant.secondary => 'showcase.buttons.secondary'.tr(),
    AppButtonVariant.tonal => 'showcase.buttons.tonal'.tr(),
    AppButtonVariant.outlined => 'showcase.buttons.outlined'.tr(),
    AppButtonVariant.text => 'showcase.buttons.text'.tr(),
    AppButtonVariant.destructive => 'showcase.buttons.destructive'.tr(),
  };

  @override
  Widget build(BuildContext context) {
    return ShowcaseSection(
      sectionKey: const ValueKey('showcase-buttons'),
      title: 'showcase.sections.buttons'.tr(),
      children: [
        ShowcaseGroup(
          label: 'showcase.buttons.variants'.tr(),
          children: [
            for (final variant in AppButtonVariant.values)
              AppButton(
                label: _variantLabel(variant),
                variant: variant,
                onPressed: _noop,
              ),
          ],
        ),
        ShowcaseGroup(
          label: 'showcase.buttons.sizes'.tr(),
          children: [
            AppButton(
              label: 'showcase.buttons.small'.tr(),
              size: AppButtonSize.sm,
              onPressed: _noop,
            ),
            AppButton(label: 'showcase.buttons.medium'.tr(), onPressed: _noop),
            AppButton(
              label: 'showcase.buttons.large'.tr(),
              size: AppButtonSize.lg,
              onPressed: _noop,
            ),
          ],
        ),
        ShowcaseGroup(
          label: 'showcase.buttons.loading'.tr(),
          children: [
            AppButton(
              label: 'showcase.buttons.tapToLoad'.tr(),
              loadingLabel: 'showcase.buttons.loadingLabel'.tr(),
              isLoading: _loading,
              onPressed: () => setState(() => _loading = !_loading),
            ),
            AppButton(
              label: 'showcase.buttons.tonal'.tr(),
              variant: AppButtonVariant.tonal,
              isLoading: true,
              onPressed: _noop,
            ),
            AppButton(
              label: 'showcase.buttons.outlined'.tr(),
              variant: AppButtonVariant.outlined,
              isLoading: true,
              onPressed: _noop,
            ),
          ],
        ),
        ShowcaseGroup(
          label: 'showcase.buttons.disabled'.tr(),
          children: [
            AppButton(label: 'showcase.buttons.primary'.tr(), onPressed: null),
            AppButton(
              label: 'showcase.buttons.outlined'.tr(),
              variant: AppButtonVariant.outlined,
              onPressed: null,
            ),
            AppButton(
              label: 'showcase.buttons.text'.tr(),
              variant: AppButtonVariant.text,
              onPressed: null,
            ),
          ],
        ),
        ShowcaseGroup(
          label: 'showcase.buttons.icons'.tr(),
          children: [
            AppButton(
              label: 'showcase.buttons.leadingIcon'.tr(),
              icon: Icons.add_rounded,
              onPressed: _noop,
            ),
            AppButton(
              label: 'showcase.buttons.trailingIcon'.tr(),
              trailingIcon: Icons.arrow_forward_rounded,
              variant: AppButtonVariant.tonal,
              onPressed: _noop,
            ),
          ],
        ),
        AppButton(
          label: 'showcase.buttons.fullWidth'.tr(),
          fullWidth: true,
          onPressed: _noop,
        ),
        ShowcaseGroup(
          label: 'showcase.buttons.iconButtons'.tr(),
          children: [
            for (final variant in AppIconButtonVariant.values)
              AppIconButton(
                icon: Icons.favorite_rounded,
                tooltip: 'showcase.buttons.iconButton'.tr(),
                variant: variant,
                onPressed: _noop,
              ),
            AppIconButton(
              icon: Icons.favorite_rounded,
              tooltip: 'showcase.buttons.iconButton'.tr(),
              onPressed: null,
            ),
          ],
        ),
        ShowcaseGroup(
          label: 'showcase.buttons.fabs'.tr(),
          children: [
            AppFab(
              icon: Icons.add_rounded,
              tooltip: 'showcase.buttons.fab'.tr(),
              onPressed: _noop,
            ),
            AppFab(
              icon: Icons.edit_rounded,
              tooltip: 'showcase.buttons.fab'.tr(),
              label: 'showcase.buttons.fabLabel'.tr(),
              onPressed: _noop,
            ),
          ],
        ),
      ],
    );
  }
}
