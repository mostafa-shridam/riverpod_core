import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/async/error_state.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/progress/app_progress_indicator.dart';
import 'package:riverpod_core/core/errors/error_mapper.dart';
import 'package:riverpod_core/core/startup/startup_controller.dart';

/// Shown while the startup sequence runs. The router moves on by itself once
/// the sequence is done. A failed step shows retry here. The mark is a neutral
/// placeholder: an app replaces [_SplashMark] with its logo.
class SplashPage extends ConsumerWidget {
  static const routeName = '/splash';

  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startup = ref.watch(startupControllerProvider);
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      key: const ValueKey('splash-page'),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Center(
          child: startup.hasError
              ? Padding(
                  padding: EdgeInsets.all(tokens.spacing.lg),
                  child: ErrorState(
                    exception: mapError(
                      startup.error!,
                      startup.stackTrace ?? StackTrace.current,
                    ),
                    onRetry: () => ref.invalidate(startupControllerProvider),
                  ),
                )
              : TweenAnimationBuilder<double>(
                  tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
                  duration: tokens.durations.slow,
                  curve: tokens.durations.standardCurve,
                  builder: (context, t, child) => Opacity(
                    opacity: t,
                    child: Transform.scale(
                      scale: 0.92 + 0.08 * t,
                      child: child,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _SplashMark(),
                      SizedBox(height: tokens.spacing.xxl),
                      const AppProgressIndicator(size: AppProgressSize.sm),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _SplashMark extends StatelessWidget {
  const _SplashMark();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(tokens.radius.xl),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.xl),
          child: Icon(
            Icons.bolt_rounded,
            size: tokens.spacing.xxxl + tokens.spacing.xl,
            color: scheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
