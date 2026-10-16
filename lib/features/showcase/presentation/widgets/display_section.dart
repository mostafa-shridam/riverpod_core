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
    AppChipTone.neutral => 'showcase.display.neutral'.tr(),
    AppChipTone.primary => 'showcase.display.primary'.tr(),
    AppChipTone.success => 'showcase.overlays.success'.tr(),
    AppChipTone.warning => 'showcase.overlays.warning'.tr(),
    AppChipTone.error => 'showcase.overlays.error'.tr(),
    AppChipTone.info => 'showcase.overlays.info'.tr(),
  };

  Widget _cards() {
    Widget card(AppCardVariant variant, String label) => AppCard(
      variant: variant,
      onTap: () {},
      child: Text(label),
    );
    final cards = [
      card(AppCardVariant.filled, 'showcase.display.cardFilled'.tr()),
      card(AppCardVariant.outlined, 'showcase.display.cardOutlined'.tr()),
      card(AppCardVariant.elevated, 'showcase.display.cardElevated'.tr()),
    ];
    final gap = context.tokens.spacing.md;
    return ResponsiveLayout(
      phone: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final c in cards)
            Padding(padding: EdgeInsetsDirectional.only(bottom: gap), child: c),
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
                semanticLabel: 'showcase.display.imageOk'.tr(),
              ),
              SizedBox(height: spacing.xs),
              Text('showcase.display.imageOk'.tr()),
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
                semanticLabel: 'showcase.display.imageBroken'.tr(),
              ),
              SizedBox(height: spacing.xs),
              Text('showcase.display.imageBroken'.tr()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabs() {
    final tabs = [
      for (var i = 1; i <= 3; i++)
        AppTabItem(label: 'showcase.display.tab'.tr(args: ['$i'])),
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
          child: Text('showcase.display.tabBody'.tr(args: ['${_tab + 1}'])),
        ),
      ],
    );
  }

  Widget _stepper() {
    final steps = [
      for (var i = 1; i <= 3; i++)
        AppStep(
          title: 'showcase.display.step'.tr(args: ['$i']),
          subtitle: 'showcase.display.stepHint'.tr(),
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
              label: 'showcase.display.back'.tr(),
              variant: AppButtonVariant.outlined,
              size: AppButtonSize.sm,
              onPressed: _step > 0 ? () => setState(() => _step--) : null,
            ),
            AppButton(
              label: 'showcase.display.next'.tr(),
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
      title: 'showcase.sections.display'.tr(),
      children: [
        _cards(),
        ShowcaseGroup(
          label: 'showcase.display.avatars'.tr(),
          children: [
            for (final size in AppAvatarSize.values)
              AppAvatar(name: 'showcase.display.avatarName'.tr(), size: size),
            const AppAvatar(status: AppAvatarStatus.online),
            const AppAvatar(status: AppAvatarStatus.busy),
          ],
        ),
        ShowcaseGroup(
          label: 'showcase.display.badges'.tr(),
          children: [
            const AppBadge(
              count: 7,
              child: Icon(Icons.notifications_outlined),
            ),
            const AppBadge(
              count: 120,
              child: Icon(Icons.mail_outline_rounded),
            ),
            const AppBadge.dot(child: Icon(Icons.chat_bubble_outline_rounded)),
            const AppBadge(count: 3),
          ],
        ),
        ShowcaseGroup(
          label: 'showcase.display.chips'.tr(),
          children: [
            for (final tone in AppChipTone.values)
              AppChip(label: _toneLabel(tone), tone: tone),
            AppChip(
              label: 'showcase.display.selectable'.tr(),
              icon: Icons.check_rounded,
              selected: _chipSelected,
              onSelected: (v) => setState(() => _chipSelected = v),
            ),
            if (!_deleted)
              AppChip(
                label: 'showcase.display.deletable'.tr(),
                deleteTooltip: 'showcase.display.delete'.tr(),
                onDeleted: () => setState(() => _deleted = true),
              ),
          ],
        ),
        _images(),
        AppAccordion(
          title: 'showcase.display.accordionTitle'.tr(),
          subtitle: 'showcase.display.accordionSubtitle'.tr(),
          leading: const Icon(Icons.help_outline_rounded),
          child: Text('showcase.display.accordionBody'.tr()),
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
                  name: 'showcase.display.avatarName'.tr(),
                  size: AppAvatarSize.sm,
                ),
                title: Text('showcase.display.tileTitle'.tr()),
                subtitle: Text('showcase.display.tileSubtitle'.tr()),
                showChevron: true,
                onTap: () {},
              ),
              const AppDivider(inset: AppDividerInset.start),
              AppListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text('showcase.display.tileSelected'.tr()),
                selected: true,
                onTap: () {},
              ),
              const AppDivider(inset: AppDividerInset.start),
              AppListTile(
                title: Text('showcase.display.tileDisabled'.tr()),
                enabled: false,
              ),
            ],
          ),
        ),
        AppDivider(label: 'showcase.display.divider'.tr()),
      ],
    );
  }
}
