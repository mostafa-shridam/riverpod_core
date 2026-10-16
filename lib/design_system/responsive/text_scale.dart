import 'package:flutter/painting.dart';

/// Lowest text scale honored; below this text becomes hard to read.
const double minTextScale = 0.8;

/// Highest text scale honored; layouts are tested to survive 2.0x.
const double maxTextScale = 2.0;

/// Clamps the system text scale into [minTextScale]..[maxTextScale].
/// Never replace the system scale with a fixed value (CONVENTIONS.md).
TextScaler clampTextScale(TextScaler system) {
  return system.clamp(
    minScaleFactor: minTextScale,
    maxScaleFactor: maxTextScale,
  );
}
