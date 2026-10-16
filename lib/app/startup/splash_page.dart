import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_core/core/auth/session_controller.dart';

/// Shown while the session and onboarding state load. The router moves on by
/// itself once both are known.
class SplashPage extends ConsumerStatefulWidget {
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
    return const Scaffold(
      key: ValueKey('splash-page'),
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
