import 'package:cached_network_image/cached_network_image.dart';
// show: easy_localization re-exports intl's TextDirection, which clashes
// with dart:ui's in the gradient transform below.
import 'package:easy_localization/easy_localization.dart'
    show StringTranslateExtension;
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// The one image primitive. Network images are cached on disk and in memory
/// (cached_network_image, D-021); [AppImage.provider] shows any
/// [ImageProvider] (assets, memory, tests) through the same code path:
/// shimmer placeholder while loading, fade-in, error widget on failure.
class AppImage extends StatelessWidget {
  const AppImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.aspectRatio,
    this.rounded = false,
    this.borderRadius,
    this.placeholderBuilder,
    this.errorBuilder,
    this.semanticLabel,
  }) : provider = null;

  const AppImage.provider(
    ImageProvider this.provider, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.aspectRatio,
    this.rounded = false,
    this.borderRadius,
    this.placeholderBuilder,
    this.errorBuilder,
    this.semanticLabel,
  }) : url = null;

  final String? url;
  final ImageProvider? provider;
  final BoxFit fit;
  final double? width;
  final double? height;

  /// Width / height. Needs a bounded width (or [width]).
  final double? aspectRatio;

  /// Clips with the `md` radius token. [borderRadius] wins when both are set.
  final bool rounded;
  final BorderRadiusGeometry? borderRadius;
  final WidgetBuilder? placeholderBuilder;
  final WidgetBuilder? errorBuilder;

  /// Announced by screen readers. Without it the image is decorative.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final image = Image(
      image: provider ?? CachedNetworkImageProvider(url!),
      fit: fit,
      width: width,
      height: height,
      excludeFromSemantics: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        if (frame == null) {
          return placeholderBuilder?.call(context) ??
              AppImageShimmer(width: width, height: height);
        }
        return _FadeIn(duration: tokens.durations.normal, child: child);
      },
      errorBuilder: (context, error, stackTrace) =>
          errorBuilder?.call(context) ??
          _ImageError(width: width, height: height),
    );

    Widget result = image;
    if (aspectRatio != null) {
      result = AspectRatio(aspectRatio: aspectRatio!, child: result);
    }
    final radius =
        borderRadius ??
        (rounded ? BorderRadius.circular(tokens.radius.md) : null);
    if (radius != null) {
      result = ClipRRect(borderRadius: radius, child: result);
    }
    return Semantics(
      image: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: result,
    );
  }
}

class _FadeIn extends StatelessWidget {
  const _FadeIn({required this.duration, required this.child});

  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: child,
    );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: scheme.surfaceContainerHighest,
      child: Icon(
        Icons.broken_image_outlined,
        color: scheme.onSurfaceVariant,
        semanticLabel: LocaleKeys.ds_display_imageError.tr(),
      ),
    );
  }
}

/// Animated loading block used while an image loads. Sweeps a soft highlight
/// along the reading direction; static when animations are disabled.
class AppImageShimmer extends StatefulWidget {
  const AppImageShimmer({super.key, this.width, this.height});

  final double? width;
  final double? height;

  @override
  State<AppImageShimmer> createState() => _AppImageShimmerState();
}

class _AppImageShimmerState extends State<AppImageShimmer>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate = !MediaQuery.disableAnimationsOf(context);
    if (animate && _controller == null) {
      // Three slow steps make one calm sweep.
      _controller = AnimationController(
        vsync: this,
        duration: context.tokens.durations.slow * 3,
      )..repeat();
    } else if (!animate) {
      _controller?.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHigh;
    final highlight = scheme.surfaceContainerLowest;
    Widget box(double progress) => DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [base, highlight, base],
          stops: const [0.25, 0.5, 0.75],
          transform: _SlideGradient(progress),
        ),
      ),
      child: SizedBox(width: widget.width, height: widget.height),
    );
    final controller = _controller;
    if (controller == null) return box(0);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => box(controller.value * 2 - 1),
    );
  }
}

/// Slides a gradient across its bounds; flips with the text direction.
class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.progress);

  final double progress;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final sign = textDirection == TextDirection.rtl ? -1.0 : 1.0;
    return Matrix4.translationValues(bounds.width * progress * sign, 0, 0);
  }
}
