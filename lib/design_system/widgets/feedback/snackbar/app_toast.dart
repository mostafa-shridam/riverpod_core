import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/design_system/widgets/dialogs/overlay_metrics.dart';
import 'package:riverpod_core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/design_system/widgets/feedback/feedback_strings.dart';
import 'package:riverpod_core/design_system/widgets/feedback/snackbar/app_message.dart';

String _typeLabel(AppStatusType type) => switch (type) {
  AppStatusType.info => infoLabelKey.tr(),
  AppStatusType.success => successLabelKey.tr(),
  AppStatusType.warning => warningLabelKey.tr(),
  AppStatusType.error => errorLabelKey.tr(),
};

/// The floating pill: rounded, tinted by type, status icon, optional action.
class AppToast extends StatelessWidget {
  const AppToast({required this.message, super.key, this.onAction});

  final AppMessage message;

  /// Called after the action button is tapped (host dismisses the toast).
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final colors = message.type.colorsOf(context);
    final hasAction = message.actionLabel != null && message.onAction != null;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: overlayMaxWidth),
      child: Material(
        color: colors.container,
        elevation: tokens.elevation.mid,
        shadowColor: theme.colorScheme.shadow,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            tokens.spacing.lg,
            tokens.spacing.sm,
            hasAction ? tokens.spacing.sm : tokens.spacing.lg,
            tokens.spacing.sm,
          ),
          child: Row(
            children: [
              Icon(message.icon ?? message.type.icon, color: colors.accent),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(
                    vertical: tokens.spacing.sm,
                  ),
                  child: Semantics(
                    label: '${_typeLabel(message.type)}: ${message.message}',
                    child: ExcludeSemantics(
                      child: Text(
                        message.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onContainer,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (hasAction)
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: colors.onContainer,
                    minimumSize: const Size(0, kMinInteractiveDimension),
                  ),
                  onPressed: onAction,
                  child: Text(message.actionLabel!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Positions an [AppToast] in the overlay, animates it in/out, auto-dismisses
/// it and lets the user swipe it away. Created by `AppMessenger`.
class AppToastHost extends StatefulWidget {
  const AppToastHost({
    required this.message,
    required this.onClosed,
    super.key,
  });

  final AppMessage message;

  /// Called once, after the toast is fully gone.
  final VoidCallback onClosed;

  @override
  State<AppToastHost> createState() => AppToastHostState();
}

class AppToastHostState extends State<AppToastHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  Timer? _timer;
  bool _closing = false;

  bool get _isTop => widget.message.position == AppToastPosition.top;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final durations = context.tokens.durations;
    final still = MediaQuery.disableAnimationsOf(context);
    _controller
      ..duration = still ? Duration.zero : durations.normal
      ..reverseDuration = still ? Duration.zero : durations.fast;
    if (_controller.status == AnimationStatus.dismissed && !_closing) {
      unawaited(_controller.forward());
      _startTimer(durations.slow);
    }
  }

  void _startTimer(Duration slow) {
    final m = widget.message;
    // Display time is not a token: ten (fifteen with an action) slow steps.
    final shown = m.duration ?? slow * (m.actionLabel == null ? 10 : 15);
    _timer = Timer(shown, dismiss);
  }

  /// Animates out, then reports closure. Safe to call repeatedly.
  Future<void> dismiss() async {
    if (_closing) return;
    _closing = true;
    _timer?.cancel();
    if (mounted) await _controller.reverse();
    widget.onClosed();
  }

  void _swiped() {
    if (_closing) return;
    _closing = true;
    _timer?.cancel();
    widget.onClosed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final media = MediaQuery.of(context);
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    final bottomInset = media.viewInsets.bottom > 0
        ? media.viewInsets.bottom
        : media.padding.bottom;
    final m = widget.message;

    return Positioned.fill(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          tokens.spacing.lg,
          media.padding.top + tokens.spacing.lg,
          tokens.spacing.lg,
          bottomInset + tokens.spacing.lg,
        ),
        child: Align(
          alignment: _isTop
              ? AlignmentDirectional.topCenter
              : AlignmentDirectional.bottomCenter,
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, _isTop ? -0.4 : 0.4),
                end: Offset.zero,
              ).animate(animation),
              child: Semantics(
                liveRegion: true,
                onDismiss: dismiss,
                child: Dismissible(
                  key: ObjectKey(m),
                  resizeDuration: null,
                  onDismissed: (_) => _swiped(),
                  child: AppToast(
                    message: m,
                    onAction: () {
                      m.onAction?.call();
                      unawaited(dismiss());
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
