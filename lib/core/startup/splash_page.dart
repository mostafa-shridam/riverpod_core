import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/progress/app_progress_indicator.dart';

/// Shown while the session and onboarding state load. The router moves on by
/// itself once both are known. The mark is a neutral placeholder: an app
/// replaces [_SplashMark] with its logo.
class SplashPage extends ConsumerStatefulWidget {
  static const routeName = '/splash';

  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // After the first frame: restoring state notifies the router.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(sessionControllerProvider.notifier).restore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      key: const ValueKey('splash-page'),
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: reduceMotion ? 1 : 0, end: 1),
            duration: tokens.durations.slow,
            curve: tokens.durations.standardCurve,
            builder: (context, t, child) => Opacity(
              opacity: t,
              child: Transform.scale(scale: 0.92 + 0.08 * t, child: child),
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
