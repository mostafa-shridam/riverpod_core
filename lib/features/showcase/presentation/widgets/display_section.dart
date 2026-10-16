import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/responsive/responsive_layout.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_accordion.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_avatar.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_badge.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_card.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_chip.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_divider.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_image.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_list_tile.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_stepper.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_tab_bar.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_group.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_samples.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_section.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Cards, avatars, badges, chips, images (working and broken), accordion,
/// tabs, stepper, list tile and divider.
class DisplaySection extends StatefulWidget {
  const DisplaySection({super.key});

  @override
  State<DisplaySection> createState() => _DisplaySectionState();
}

class _DisplaySectionState extends State<DisplaySection> {
  int _step = 0;
  int _tab = 0;
  bool _chipSelected = true;
  bool _deleted = false;

  String _toneLabel(AppChipTone tone) => switch (tone) {
    AppChipTone.neutral => LocaleKeys.showcase_display_neutral.tr(),
    AppChipTone.primary => LocaleKeys.showcase_display_primary.tr(),
    AppChipTone.success => LocaleKeys.showcase_overlays_success.tr(),
    AppChipTone.warning => LocaleKeys.showcase_overlays_warning.tr(),
    AppChipTone.error => LocaleKeys.showcase_overlays_error.tr(),
    AppChipTone.info => LocaleKeys.showcase_overlays_info.tr(),
  };

  Widget _cards() {
    Widget card(AppCardVariant variant, String label) =>
        AppCard(variant: variant, onTap: () {}, child: Text(label));
    final cards = [
      card(AppCardVariant.filled, LocaleKeys.showcase_display_cardFilled.tr()),
      card(
        AppCardVariant.outlined,
        LocaleKeys.showcase_display_cardOutlined.tr(),
      ),
      card(
        AppCardVariant.elevated,
        LocaleKeys.showcase_display_cardElevated.tr(),
      ),
    ];
    final gap = context.tokens.spacing.md;
    return ResponsiveLayout(
      phone: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final c in cards)
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: gap),
              child: c,
            ),
        ],
      ),
      tablet: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final c in cards)
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(end: gap),
                child: c,
              ),
            ),
        ],
      ),
    );
  }

  Widget _images() {
    final spacing = context.tokens.spacing;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppImage(
                showcaseImageUrl,
                aspectRatio: 4 / 3,
                rounded: true,
                semanticLabel: LocaleKeys.showcase_display_imageOk.tr(),
              ),
              SizedBox(height: spacing.xs),
              Text(LocaleKeys.showcase_display_imageOk.tr()),
            ],
          ),
        ),
        SizedBox(width: spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppImage(
                showcaseBrokenImageUrl,
                key: const ValueKey('showcase-broken-image'),
                aspectRatio: 4 / 3,
                rounded: true,
                semanticLabel: LocaleKeys.showcase_display_imageBroken.tr(),
              ),
              SizedBox(height: spacing.xs),
              Text(LocaleKeys.showcase_display_imageBroken.tr()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabs() {
    final tabs = [
      for (var i = 1; i <= 3; i++)
        AppTabItem(label: LocaleKeys.showcase_display_tab.tr(args: ['$i'])),
    ];
    Widget bar(AppTabBarStyle style) => DefaultTabController(
      length: tabs.length,
      child: AppTabBar(
        tabs: tabs,
        style: style,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        bar(AppTabBarStyle.underline),
        SizedBox(height: context.tokens.spacing.sm),
        bar(AppTabBarStyle.pill),
        Padding(
          padding: EdgeInsetsDirectional.only(top: context.tokens.spacing.sm),
          child: Text(
            LocaleKeys.showcase_display_tabBody.tr(args: ['${_tab + 1}']),
          ),
        ),
      ],
    );
  }

  Widget _stepper() {
    final steps = [
      for (var i = 1; i <= 3; i++)
        AppStep(
          title: LocaleKeys.showcase_display_step.tr(args: ['$i']),
          subtitle: LocaleKeys.showcase_display_stepHint.tr(),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppStepper(
          steps: steps,
          currentStep: _step,
          onStepTapped: (i) => setState(() => _step = i),
        ),
        SizedBox(height: context.tokens.spacing.sm),
        Wrap(
          spacing: context.tokens.spacing.sm,
          children: [
            AppButton(
              label: LocaleKeys.showcase_display_back.tr(),
              variant: AppButtonVariant.outlined,
              size: AppButtonSize.sm,
              onPressed: _step > 0 ? () => setState(() => _step--) : null,
            ),
            AppButton(
              label: LocaleKeys.showcase_display_next.tr(),
              size: AppButtonSize.sm,
              onPressed: _step < steps.length - 1
                  ? () => setState(() => _step++)
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseSection(
      sectionKey: const ValueKey('showcase-display'),
      title: LocaleKeys.showcase_sections_display.tr(),
      children: [
        _cards(),
        ShowcaseGroup(
          label: LocaleKeys.showcase_display_avatars.tr(),
          children: [
            for (final size in AppAvatarSize.values)
              AppAvatar(
                name: LocaleKeys.showcase_display_avatarName.tr(),
                size: size,
              ),
            const AppAvatar(status: AppAvatarStatus.online),
            const AppAvatar(status: AppAvatarStatus.busy),
          ],
        ),
        ShowcaseGroup(
          label: LocaleKeys.showcase_display_badges.tr(),
          children: [
            const AppBadge(count: 7, child: Icon(Icons.notifications_outlined)),
            const AppBadge(count: 120, child: Icon(Icons.mail_outline_rounded)),
            const AppBadge.dot(child: Icon(Icons.chat_bubble_outline_rounded)),
            const AppBadge(count: 3),
          ],
        ),
        ShowcaseGroup(
          label: LocaleKeys.showcase_display_chips.tr(),
          children: [
            for (final tone in AppChipTone.values)
              AppChip(label: _toneLabel(tone), tone: tone),
            AppChip(
              label: LocaleKeys.showcase_display_selectable.tr(),
              icon: Icons.check_rounded,
              selected: _chipSelected,
              onSelected: (v) => setState(() => _chipSelected = v),
            ),
            if (!_deleted)
              AppChip(
                label: LocaleKeys.showcase_display_deletable.tr(),
                deleteTooltip: LocaleKeys.showcase_display_delete.tr(),
                onDeleted: () => setState(() => _deleted = true),
              ),
          ],
        ),
        _images(),
        AppAccordion(
          title: LocaleKeys.showcase_display_accordionTitle.tr(),
          subtitle: LocaleKeys.showcase_display_accordionSubtitle.tr(),
          leading: const Icon(Icons.help_outline_rounded),
          child: Text(LocaleKeys.showcase_display_accordionBody.tr()),
        ),
        _tabs(),
        _stepper(),
        AppCard(
          variant: AppCardVariant.outlined,
          padding: EdgeInsetsDirectional.zero,
          child: Column(
            children: [
              AppListTile(
                leading: AppAvatar(
                  name: LocaleKeys.showcase_display_avatarName.tr(),
                  size: AppAvatarSize.sm,
                ),
                title: Text(LocaleKeys.showcase_display_tileTitle.tr()),
                subtitle: Text(LocaleKeys.showcase_display_tileSubtitle.tr()),
                showChevron: true,
                onTap: () {},
              ),
              const AppDivider(inset: AppDividerInset.start),
              AppListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(LocaleKeys.showcase_display_tileSelected.tr()),
                selected: true,
                onTap: () {},
              ),
              const AppDivider(inset: AppDividerInset.start),
              AppListTile(
                title: Text(LocaleKeys.showcase_display_tileDisabled.tr()),
                enabled: false,
              ),
            ],
          ),
        ),
        AppDivider(label: LocaleKeys.showcase_display_divider.tr()),
      ],
    );
  }
}
