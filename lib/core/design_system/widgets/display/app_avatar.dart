import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/display/app_image.dart';

/// Diameter classes of an [AppAvatar] (logical pixels).
enum AppAvatarSize {
  xs(24),
  sm(32),
  md(40),
  lg(56),
  xl(80);

  const AppAvatarSize(this.diameter);
  final double diameter;
}

/// Presence indicator drawn at the bottom-end corner of an [AppAvatar].
enum AppAvatarStatus { online, away, busy, offline }

/// Circular avatar: image, else initials of [name], else [icon].
/// An image that fails to load falls back to initials/icon.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.imageProvider,
    this.name,
    this.icon = Icons.person_outline,
    this.size = AppAvatarSize.md,
    this.status,
    this.semanticLabel,
  });

  final String? imageUrl;
  final ImageProvider? imageProvider;
  final String? name;
  final IconData icon;
  final AppAvatarSize size;
  final AppAvatarStatus? status;

  /// Defaults to [name]. Pass a status text here when [status] is set.
  final String? semanticLabel;

  /// Up to two initials from the first and last words of [name].
  static String initialsOf(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    String first(String w) => w.characters.first.toUpperCase();
    if (words.length == 1) return first(words.first);
    return first(words.first) + first(words.last);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final diameter = size.diameter;
    final initials = name == null ? '' : initialsOf(name!);
    final (background, foreground) = _palette(scheme, name ?? '');

    final fallback = ColoredBox(
      color: background,
      child: Center(
        child: initials.isEmpty
            ? Icon(icon, size: diameter * 0.55, color: foreground)
            : Padding(
                padding: EdgeInsets.all(diameter * 0.1),
                // Shrinks instead of overflowing at large text scales.
                child: FittedBox(
                  child: Text(
                    initials,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontSize: diameter * 0.38,
                      height: 1,
                    ),
                  ),
                ),
              ),
      ),
    );

    final Widget content;
    if (imageProvider != null) {
      content = AppImage.provider(
        imageProvider!,
        width: diameter,
        height: diameter,
        errorBuilder: (_) => fallback,
      );
    } else if (imageUrl != null) {
      content = AppImage(
        imageUrl,
        width: diameter,
        height: diameter,
        errorBuilder: (_) => fallback,
      );
    } else {
      content = fallback;
    }

    final dot = diameter * 0.28;
    return Semantics(
      label: semanticLabel ?? name,
      image: true,
      excludeSemantics: true,
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: ClipOval(child: content)),
            if (status != null)
              PositionedDirectional(
                bottom: 0,
                end: 0,
                child: Container(
                  width: dot,
                  height: dot,
                  decoration: BoxDecoration(
                    color: _statusColor(context, status!),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: scheme.surface,
                      width: tokens.spacing.xxs,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context, AppAvatarStatus status) {
    final colors = context.tokens.colors;
    final scheme = Theme.of(context).colorScheme;
    return switch (status) {
      AppAvatarStatus.online => colors.success,
      AppAvatarStatus.away => colors.warning,
      AppAvatarStatus.busy => scheme.error,
      AppAvatarStatus.offline => scheme.outline,
    };
  }

  /// Stable color pair per name so the same person always looks the same.
  static (Color, Color) _palette(ColorScheme s, String name) {
    final pairs = [
      (s.primaryContainer, s.onPrimaryContainer),
      (s.secondaryContainer, s.onSecondaryContainer),
      (s.tertiaryContainer, s.onTertiaryContainer),
    ];
    final hash = name.runes.fold<int>(0, (a, r) => (a * 31 + r) & 0x7fffffff);
    return pairs[hash % pairs.length];
  }
}
