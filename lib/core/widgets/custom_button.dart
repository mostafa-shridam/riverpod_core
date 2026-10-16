import 'package:flutter/material.dart';

import 'package:riverpod_core/core/themes/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.color,
    this.textColor,
    this.withDeafultTextColor = false,
    this.grideantColor,
    this.width = double.infinity,
  });
  final double width;
  final Color? grideantColor;
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? color, textColor;
  final bool withDeafultTextColor;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        width: width,
        height: 50,
        decoration: BoxDecoration(
          gradient: color != null
              ? null
              : LinearGradient(
                  colors: grideantColor != null
                      ? [grideantColor!, grideantColor!.withValues(alpha: 0.2)]
                      : [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.3),
                        ],
                ),
          color: color ?? AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: withDeafultTextColor
                        ? null
                        : textColor ?? Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
