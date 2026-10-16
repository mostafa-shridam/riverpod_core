import 'package:flutter/material.dart';
import 'package:riverpod_core/app/router/routes.dart';
import 'package:riverpod_core/core/design_system/widgets/async/error_state.dart';

/// Shown for unknown locations and router errors.
class AppErrorPage extends StatelessWidget {
  const AppErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('error-page'),
      body: Center(
        child: ErrorState(onRetry: () => const HomeRoute().go(context)),
      ),
    );
  }
}
