import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_group.dart';
import 'package:riverpod_core/features/showcase/presentation/widgets/showcase_section.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Color roles, type scale, spacing, radius and elevation, all read from the
/// active theme so the page shows what widgets really get.
class TokensSection extends StatelessWidget {
  const TokensSection({super.key});

  // Role names are token identifiers, not user text.
  static List<(String, Color)> _schemeRoles(ColorScheme s) => [
    ('primary', s.primary),
    ('onPrimary', s.onPrimary),
    ('primaryContainer', s.primaryContainer),
    ('onPrimaryContainer', s.onPrimaryContainer),
    ('secondary', s.secondary),
    ('onSecondary', s.onSecondary),
    ('secondaryContainer', s.secondaryContainer),
    ('onSecondaryContainer', s.onSecondaryContainer),
    ('tertiary', s.tertiary),
    ('onTertiary', s.onTertiary),
    ('tertiaryContainer', s.tertiaryContainer),
    ('onTertiaryContainer', s.onTertiaryContainer),
    ('error', s.error),
    ('onError', s.onError),
    ('errorContainer', s.errorContainer),
    ('onErrorContainer', s.onErrorContainer),
    ('surface', s.surface),
    ('onSurface', s.onSurface),
    ('onSurfaceVariant', s.onSurfaceVariant),
    ('surfaceContainerLowest', s.surfaceContainerLowest),
    ('surfaceContainerLow', s.surfaceContainerLow),
    ('surfaceContainer', s.surfaceContainer),
    ('surfaceContainerHigh', s.surfaceContainerHigh),
    ('surfaceContainerHighest', s.surfaceContainerHighest),
    ('outline', s.outline),
    ('outlineVariant', s.outlineVariant),
    ('inverseSurface', s.inverseSurface),
    ('onInverseSurface', s.onInverseSurface),
    ('inversePrimary', s.inversePrimary),
    ('scrim', s.scrim),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final c = tokens.colors;
    final spacing = tokens.spacing;
    final radius = tokens.radius;
    final elevation = tokens.elevation;
    final semantic = <(String, Color)>[
      ('success', c.success),
      ('onSuccess', c.onSuccess),
      ('successContainer', c.successContainer),
      ('onSuccessContainer', c.onSuccessContainer),
      ('warning', c.warning),
      ('onWarning', c.onWarning),
      ('warningContainer', c.warningContainer),
      ('onWarningContainer', c.onWarningContainer),
      ('info', c.info),
      ('onInfo', c.onInfo),
      ('infoContainer', c.infoContainer),
      ('onInfoContainer', c.onInfoContainer),
    ];
    final spacings = <(String, double)>[
      ('xxs', spacing.xxs),
      ('xs', spacing.xs),
      ('sm', spacing.sm),
      ('md', spacing.md),
      ('lg', spacing.lg),
      ('xl', spacing.xl),
      ('xxl', spacing.xxl),
      ('xxxl', spacing.xxxl),
    ];
    final radii = <(String, double)>[
      ('sm', radius.sm),
      ('md', radius.md),
      ('lg', radius.lg),
      ('xl', radius.xl),
      ('full', radius.full),
    ];
    final elevations = <(String, double)>[
      ('none', elevation.none),
      ('low', elevation.low),
      ('mid', elevation.mid),
      ('high', elevation.high),
    ];
    final text = theme.textTheme;
    final styles = <(String, TextStyle?)>[
      ('displayLarge', text.displayLarge),
      ('displayMedium', text.displayMedium),
      ('displaySmall', text.displaySmall),
      ('headlineLarge', text.headlineLarge),
      ('headlineMedium', text.headlineMedium),
      ('headlineSmall', text.headlineSmall),
      ('titleLarge', text.titleLarge),
      ('titleMedium', text.titleMedium),
      ('titleSmall', text.titleSmall),
      ('bodyLarge', text.bodyLarge),
      ('bodyMedium', text.bodyMedium),
      ('bodySmall', text.bodySmall),
      ('labelLarge', text.labelLarge),
      ('labelMedium', text.labelMedium),
      ('labelSmall', text.labelSmall),
    ];

    return ShowcaseSection(
      sectionKey: const ValueKey('showcase-tokens'),
      title: LocaleKeys.showcase_sections_tokens.tr(),
      children: [
        ShowcaseGroup(
          label: LocaleKeys.showcase_tokens_colorRoles.tr(),
          children: [
            for (final (name, color) in _schemeRoles(theme.colorScheme))
              _Swatch(name: name, color: color),
          ],
        ),
        ShowcaseGroup(
          label: LocaleKeys.showcase_tokens_semanticColors.tr(),
          children: [
            for (final (name, color) in semantic)
              _Swatch(name: name, color: color),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.showcase_tokens_typeScale.tr(),
              style: theme.textTheme.labelLarge,
            ),
            for (final (name, style) in styles)
              Padding(
                padding: EdgeInsetsDirectional.only(top: spacing.xs),
                child: Text(
                  '$name · ${LocaleKeys.showcase_tokens_sample.tr()}',
                  style: style,
                ),
              ),
          ],
        ),
        ShowcaseGroup(
          label: LocaleKeys.showcase_tokens_spacing.tr(),
          children: [
            for (final (name, value) in spacings)
              _Sample(
                name: '$name ${value.toInt()}',
                child: Container(
                  width: value,
                  height: spacing.lg,
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
        ShowcaseGroup(
          label: LocaleKeys.showcase_tokens_radius.tr(),
          children: [
            for (final (name, value) in radii)
              _Sample(
                name: '$name ${value.toInt()}',
                child: Container(
                  width: spacing.xxxl,
                  height: spacing.xxxl,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(value),
                  ),
                ),
              ),
          ],
        ),
        ShowcaseGroup(
          label: LocaleKeys.showcase_tokens_elevation.tr(),
          children: [
            for (final (name, value) in elevations)
              _Sample(
                name: '$name ${value.toInt()}',
                child: Material(
                  elevation: value,
                  borderRadius: BorderRadius.circular(radius.md),
                  child: SizedBox.square(dimension: spacing.xxxl),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    return _Sample(
      name: name,
      child: Container(
        width: tokens.spacing.xxxl,
        height: tokens.spacing.xxl,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(tokens.radius.sm),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: tokens.sizes.outlineWidth,
          ),
        ),
      ),
    );
  }
}

class _Sample extends StatelessWidget {
  const _Sample({required this.name, required this.child});

  final String name;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spacing = context.tokens.spacing;
    return SizedBox(
      width: spacing.xxxl * 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          SizedBox(height: spacing.xs),
          Text(name, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
