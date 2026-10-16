import 'package:flutter/foundation.dart';

/// Corner radius scale (DESIGN_SYSTEM.md). `full` makes pills and circles.
@immutable
class AppRadius {
  const AppRadius({
    this.sm = 8.0,
    this.md = 12.0,
    this.lg = 16.0,
    this.xl = 24.0,
    this.full = 999.0,
  });

  static const AppRadius standard = AppRadius();

  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double full;
}
