import 'package:flutter/material.dart';

/// Second tab of the app shell. Empty until an app fills it (settings, profile…).
class MorePage extends StatelessWidget {
  static const routeName = '/more';

  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(key: ValueKey('more-page'));
  }
}
