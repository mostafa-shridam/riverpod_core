import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/config/flavor.dart';
import 'package:riverpod_core/core/design_system/responsive/text_scale.dart';
import 'package:riverpod_core/core/design_system/theme/app_theme.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_icon_button.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_app_bar.dart';
import 'package:riverpod_core/core/design_system/widgets/layout/app_scaffold.dart';
import 'package:riverpod_core/core/design_system/widgets/media/app_video_backend.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/buttons_section.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/display_section.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/inputs_section.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/media_section.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/overlays_section.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/selection_section.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_scale_bar.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/states_section.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/tokens_section.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// The component gallery (D-020): every design_system widget, live, with
/// light/dark, ar/en and text scale switches in the app bar.
///
/// Registered only in dev and staging (see [isEnabled]); nothing else in the
/// app imports this feature, so it can be deleted on its own (D-028).
class ShowcasePage extends StatefulWidget {
  const ShowcasePage({
    super.key,
    this.videoBackendFactory = createVideoPlayerBackend,
  });

  /// Route path of the gallery.
  static const routeName = '/showcase';

  /// Playback engine factory for the video samples; tests pass a fake.
  final AppVideoBackendFactory videoBackendFactory;

  /// The gallery exists in every flavor except production.
  static bool isEnabled(Flavor flavor) => flavor != Flavor.prod;

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  /// Null follows the app theme until the user toggles it.
  bool? _dark;

  /// Null keeps the system text scale until the slider is used.
  double? _scale;

  @override
  Widget build(BuildContext context) {
    // The gallery switches the theme for its own subtree only: the app has
    // no global theme controller, and the page must not change app settings.
    final theme = switch (_dark) {
      null => Theme.of(context),
      true => buildDarkTheme(),
      false => buildLightTheme(),
    };
    return Theme(
      data: theme,
      child: Builder(builder: (context) => _scaffold(context, theme)),
    );
  }

  Widget _scaffold(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';
    final media = MediaQuery.of(context);
    final scale = _scale ?? media.textScaler.scale(1);
    final spacing = context.tokens.spacing;
    final body = ListView(
      key: const ValueKey('showcase-list'),
      padding: EdgeInsetsDirectional.only(top: spacing.md, bottom: spacing.xxl),
      children: [
        const ButtonsSection(),
        const InputsSection(),
        const SelectionSection(),
        const OverlaysSection(),
        const DisplaySection(),
        MediaSection(backendFactory: widget.videoBackendFactory),
        const StatesSection(),
        const TokensSection(),
      ],
    );

    return AppScaffold(
      appBar: AppAppBar(
        title: LocaleKeys.showcase_title.tr(),
        actions: [
          AppIconButton(
            key: const ValueKey('toggle-theme'),
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            tooltip: LocaleKeys.showcase_toggleTheme.tr(),
            onPressed: () => setState(() => _dark = !isDark),
          ),
          AppButton(
            key: const ValueKey('toggle-locale'),
            label: LocaleKeys.showcase_toggleLocale.tr(),
            variant: AppButtonVariant.text,
            size: AppButtonSize.sm,
            onPressed: () => context.setLocale(Locale(isArabic ? 'en' : 'ar')),
          ),
        ],
      ),
      body: Column(
        children: [
          ShowcaseScaleBar(
            value: scale.clamp(minTextScale, maxTextScale),
            onChanged: (v) => setState(() => _scale = v),
          ),
          // Only the list is scaled, so the controls stay usable at 2.0x.
          Expanded(
            child: _scale == null
                ? body
                : MediaQuery(
                    data: media.copyWith(
                      textScaler: TextScaler.linear(_scale!),
                    ),
                    child: body,
                  ),
          ),
        ],
      ),
    );
  }
}
