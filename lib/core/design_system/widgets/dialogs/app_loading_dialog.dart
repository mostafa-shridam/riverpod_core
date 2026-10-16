import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/dialogs/overlay_metrics.dart';
import 'package:riverpod_core/core/design_system/widgets/dialogs/overlays_strings.dart';

/// Blocking "please wait" card with a spinner and an optional message.
/// Not dismissible by the user: close it with the callback from [show].
class AppLoadingDialog extends StatelessWidget {
  const AppLoadingDialog({super.key, this.message});

  final String? message;

  /// Opens the blocking dialog on the root navigator and returns the function
  /// that closes it (safe to call more than once).
  static VoidCallback show({required BuildContext context, String? message}) {
    final navigator = Navigator.of(context, rootNavigator: true);
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: overlayScrimColor(context),
      builder: (_) =>
          PopScope(canPop: false, child: AppLoadingDialog(message: message)),
    );
    navigator.push(route);
    return () {
      if (!route.isActive) return;
      route.isCurrent ? navigator.pop() : navigator.removeRoute(route);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(child: AppLoadingCard(message: message)),
    );
  }
}

/// The spinner card shared by [AppLoadingDialog] and [AppLoadingOverlay].
class AppLoadingCard extends StatelessWidget {
  const AppLoadingCard({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final label = message ?? loadingKey.tr();
    return Semantics(
      liveRegion: true,
      label: label,
      child: Material(
        color: scheme.surfaceContainerHigh,
        elevation: tokens.elevation.high,
        surfaceTintColor: scheme.surfaceTint,
        borderRadius: BorderRadius.circular(tokens.radius.xl),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: tokens.spacing.xxxl * 2,
            maxWidth: overlayMaxWidth / 2,
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.all(tokens.spacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                  dimension: tokens.spacing.xxl,
                  child: const CircularProgressIndicator(),
                ),
                if (message != null) ...[
                  SizedBox(height: tokens.spacing.lg),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Blocks [child] with a scrim and a spinner card while [isLoading] is true.
/// Use it for page-level work; use [AppLoadingDialog] for a route-level block.
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    required this.isLoading,
    required this.child,
    super.key,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isLoading,
            child: AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : tokens.durations.normal,
              child: isLoading
                  ? Stack(
                      key: const ValueKey('loading'),
                      children: [
                        ModalBarrier(
                          dismissible: false,
                          color: overlayScrimColor(context),
                        ),
                        Center(child: AppLoadingCard(message: message)),
                      ],
                    )
                  : const SizedBox.shrink(key: ValueKey('idle')),
            ),
          ),
        ),
      ],
    );
  }
}
