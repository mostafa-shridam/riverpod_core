import 'package:flutter/foundation.dart';

/// 4-pt spacing scale (DESIGN_SYSTEM.md). Values in logical pixels.
@immutable
class AppSpacing {
  const AppSpacing({
    this.xxs = 2.0,
    this.xs = 4.0,
    this.sm = 8.0,
    this.md = 12.0,
    this.lg = 16.0,
    this.xl = 24.0,
    this.xxl = 32.0,
    this.xxxl = 48.0,
  });

  static const AppSpacing standard = AppSpacing();

  final double xxs;
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;
  final double xxxl;
}
