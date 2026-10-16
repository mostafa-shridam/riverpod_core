import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Motion tokens: durations and the standard curve (DESIGN_SYSTEM.md).
@immutable
class AppDurations {
  const AppDurations({
    this.fast = const Duration(milliseconds: 150),
    this.normal = const Duration(milliseconds: 250),
    this.slow = const Duration(milliseconds: 400),
    this.standardCurve = Curves.easeInOutCubicEmphasized,
  });

  static const AppDurations standard = AppDurations();

  final Duration fast;
  final Duration normal;
  final Duration slow;
  final Curve standardCurve;
}
