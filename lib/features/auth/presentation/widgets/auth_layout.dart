import 'package:flutter/material.dart';
import 'package:riverpod_core/core/design_system/responsive/breakpoints.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';

/// Shared frame of the auth pages: a title bar and one centered column that
/// never grows past [maxContentWidth] on large screens.
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacing = context.tokens.spacing;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.all(spacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
