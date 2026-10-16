import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/widgets/bottom_sheets/app_sheet_frame.dart';
import 'package:riverpod_core/design_system/widgets/dialogs/overlay_metrics.dart';

/// Shows the one modal bottom sheet of the app: rounded top, drag handle,
/// themed scrim, safe-area and keyboard aware, max width 560 on tablets.
///
/// [builder] provides the body; it scrolls when taller than the screen.
/// Returns what the sheet pops with, or null when dismissed.
/// [isDismissible] controls tap-on-scrim, [enableDrag] controls swipe-down.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
  bool showCloseButton = false,
  String? closeLabel,
  Widget? footer,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = true,
}) {
  return _present<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    builder: (sheetContext) => AppSheetFrame(
      title: title,
      showCloseButton: showCloseButton,
      closeLabel: closeLabel,
      footer: footer,
      body: builder(sheetContext),
    ),
  );
}

/// Draggable, scrollable variant: the sheet opens at [initialSize] of the
/// screen height and can be dragged between [minSize] and [maxSize].
/// [builder] must attach the given controller to its scrollable.
Future<T?> showAppDraggableSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context, ScrollController controller)
  builder,
  String? title,
  bool showCloseButton = false,
  String? closeLabel,
  Widget? footer,
  double initialSize = 0.6,
  double minSize = 0.35,
  double maxSize = 0.95,
  bool isDismissible = true,
  bool useRootNavigator = true,
}) {
  return _present<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: true,
    useRootNavigator: useRootNavigator,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: initialSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      builder: (sheetContext, controller) => AppSheetFrame(
        title: title,
        showCloseButton: showCloseButton,
        closeLabel: closeLabel,
        footer: footer,
        scrollable: false,
        expand: true,
        scrollController: controller,
        body: builder(sheetContext, controller),
      ),
    ),
  );
}

Future<T?> _present<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required bool isDismissible,
  required bool enableDrag,
  required bool useRootNavigator,
}) {
  return showModalBottomSheet<T>(
    context: context,
    builder: builder,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    // The frame paints its own rounded surface.
    backgroundColor: Colors.transparent,
    elevation: 0,
    barrierColor: overlayScrimColor(context),
    constraints: const BoxConstraints(maxWidth: overlayMaxWidth),
  );
}
