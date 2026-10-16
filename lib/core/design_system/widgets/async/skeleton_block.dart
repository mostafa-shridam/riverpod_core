import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// A plain placeholder shape (rounded box or circle) for use inside a
/// `Skeleton`, e.g. an image or avatar slot.
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({super.key, this.width, this.height, this.radius})
    : circle = false;

  /// Circle of [size] logical pixels.
  const SkeletonBlock.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = null,
      circle = true;

  final double? width;
  final double? height;

  /// Corner radius; defaults to the `sm` radius token.
  final double? radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    if (circle) return Bone.circle(size: width);
    return Bone(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(radius ?? context.tokens.radius.sm),
    );
  }
}
