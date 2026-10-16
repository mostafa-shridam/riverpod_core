import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Motion tokens: durations and the standard curve (DESIGN_SYSTEM.md).
@immutable
class AppDurations {
  const AppDurations({
    this.fast = const Duration(milliseconds: 150),
    this.normal = const Duration(milliseconds: 250),
    this.slow = const Duration(milliseconds: 400),
    this.searchDebounce = const Duration(milliseconds: 300),
    this.standardCurve = Curves.easeInOutCubicEmphasized,
  });

  static const AppDurations standard = AppDurations();

  final Duration fast;
  final Duration normal;
  final Duration slow;

  /// Pause after typing before a search runs.
  final Duration searchDebounce;
  final Curve standardCurve;
}
