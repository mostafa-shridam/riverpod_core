import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_fab.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_icon_button.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_group.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_section.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

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
    AppButtonVariant.primary => LocaleKeys.showcase_buttons_primary.tr(),
    AppButtonVariant.secondary => LocaleKeys.showcase_buttons_secondary.tr(),
    AppButtonVariant.tonal => LocaleKeys.showcase_buttons_tonal.tr(),
    AppButtonVariant.outlined => LocaleKeys.showcase_buttons_outlined.tr(),
    AppButtonVariant.text => LocaleKeys.showcase_buttons_text.tr(),
    AppButtonVariant.destructive =>
      LocaleKeys.showcase_buttons_destructive.tr(),
  };

  @override
  Widget build(BuildContext context) {
    return ShowcaseSection(
      sectionKey: const ValueKey('showcase-buttons'),
      title: LocaleKeys.showcase_sections_buttons.tr(),
      children: [
        ShowcaseGroup(
          label: LocaleKeys.showcase_buttons_variants.tr(),
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
          label: LocaleKeys.showcase_buttons_sizes.tr(),
          children: [
            AppButton(
              label: LocaleKeys.showcase_buttons_small.tr(),
              size: AppButtonSize.sm,
              onPressed: _noop,
            ),
            AppButton(
              label: LocaleKeys.showcase_buttons_medium.tr(),
              onPressed: _noop,
            ),
            AppButton(
              label: LocaleKeys.showcase_buttons_large.tr(),
              size: AppButtonSize.lg,
              onPressed: _noop,
            ),
          ],
        ),
        ShowcaseGroup(
          label: LocaleKeys.showcase_buttons_loading.tr(),
          children: [
            AppButton(
              label: LocaleKeys.showcase_buttons_tapToLoad.tr(),
              loadingLabel: LocaleKeys.showcase_buttons_loadingLabel.tr(),
              isLoading: _loading,
              onPressed: () => setState(() => _loading = !_loading),
            ),
            AppButton(
              label: LocaleKeys.showcase_buttons_tonal.tr(),
              variant: AppButtonVariant.tonal,
              isLoading: true,
              onPressed: _noop,
            ),
            AppButton(
              label: LocaleKeys.showcase_buttons_outlined.tr(),
              variant: AppButtonVariant.outlined,
              isLoading: true,
              onPressed: _noop,
            ),
          ],
        ),
        ShowcaseGroup(
          label: LocaleKeys.showcase_buttons_disabled.tr(),
          children: [
            AppButton(
              label: LocaleKeys.showcase_buttons_primary.tr(),
              onPressed: null,
            ),
            AppButton(
              label: LocaleKeys.showcase_buttons_outlined.tr(),
              variant: AppButtonVariant.outlined,
              onPressed: null,
            ),
            AppButton(
              label: LocaleKeys.showcase_buttons_text.tr(),
              variant: AppButtonVariant.text,
              onPressed: null,
            ),
          ],
        ),
        ShowcaseGroup(
          label: LocaleKeys.showcase_buttons_icons.tr(),
          children: [
            AppButton(
              label: LocaleKeys.showcase_buttons_leadingIcon.tr(),
              icon: Icons.add_rounded,
              onPressed: _noop,
            ),
            AppButton(
              label: LocaleKeys.showcase_buttons_trailingIcon.tr(),
              trailingIcon: Icons.arrow_forward_rounded,
              variant: AppButtonVariant.tonal,
              onPressed: _noop,
            ),
          ],
        ),
        AppButton(
          label: LocaleKeys.showcase_buttons_fullWidth.tr(),
          fullWidth: true,
          onPressed: _noop,
        ),
        ShowcaseGroup(
          label: LocaleKeys.showcase_buttons_iconButtons.tr(),
          children: [
            for (final variant in AppIconButtonVariant.values)
              AppIconButton(
                icon: Icons.favorite_rounded,
                tooltip: LocaleKeys.showcase_buttons_iconButton.tr(),
                variant: variant,
                onPressed: _noop,
              ),
            AppIconButton(
              icon: Icons.favorite_rounded,
              tooltip: LocaleKeys.showcase_buttons_iconButton.tr(),
              onPressed: null,
            ),
          ],
        ),
        ShowcaseGroup(
          label: LocaleKeys.showcase_buttons_fabs.tr(),
          children: [
            AppFab(
              icon: Icons.add_rounded,
              tooltip: LocaleKeys.showcase_buttons_fab.tr(),
              onPressed: _noop,
            ),
            AppFab(
              icon: Icons.edit_rounded,
              tooltip: LocaleKeys.showcase_buttons_fab.tr(),
              label: LocaleKeys.showcase_buttons_fabLabel.tr(),
              onPressed: _noop,
            ),
          ],
        ),
      ],
    );
  }
}
