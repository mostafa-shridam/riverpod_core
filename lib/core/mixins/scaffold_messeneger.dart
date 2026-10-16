import 'package:flutter/material.dart';

import 'package:riverpod_core/core/themes/app_colors.dart';

mixin ScaffoldMessengerMixin {
  void showSnackBar({
    required BuildContext context,
    required String message,
    int? color,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        backgroundColor: Color(
          color ?? AppColors.primary.toARGB32(),
        ).withValues(alpha: 0.8),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
