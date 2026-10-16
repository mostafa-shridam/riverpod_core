import 'package:flutter/material.dart';

/// Max width of dialogs, sheets and toasts on wide screens (DESIGN_SYSTEM.md).
const double overlayMaxWidth = 560;

/// Scrim opacity behind dialogs and sheets (DESIGN_SYSTEM.md: 40% of `scrim`).
const double overlayScrimOpacity = 0.4;

/// Themed barrier color shared by every modal overlay.
Color overlayScrimColor(BuildContext context) =>
    Theme.of(context).colorScheme.scrim.withValues(alpha: overlayScrimOpacity);
