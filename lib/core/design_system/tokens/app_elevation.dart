import 'package:flutter/foundation.dart';

/// Elevation levels mapped to M3 surface tint levels (`surfaceTintColor`).
@immutable
class AppElevation {
  const AppElevation({
    this.none = 0.0,
    this.low = 1.0,
    this.mid = 3.0,
    this.high = 6.0,
  });

  static const AppElevation standard = AppElevation();

  final double none;
  final double low;
  final double mid;
  final double high;
}
