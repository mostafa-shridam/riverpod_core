import 'package:flutter/material.dart';

/// Primary floating action. Pass [label] for the extended form.
/// [tooltip] is the accessible name and is required.
class AppFab extends StatelessWidget {
  const AppFab({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.label,
  });

  final IconData icon;
  final String tooltip;

  /// Null disables the button.
  final VoidCallback? onPressed;

  /// When set, the button is extended and shows this text next to the icon.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final text = label;
    if (text == null) {
      return FloatingActionButton(
        heroTag: null,
        tooltip: tooltip,
        onPressed: onPressed,
        child: Icon(icon),
      );
    }
    return FloatingActionButton.extended(
      heroTag: null,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
    );
  }
}
