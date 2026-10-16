import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:riverpod_core/core/enum/alert_type.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

mixin AlertUtils {
  // Info Alert - معلومات
  void showInfoAlert({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    _showAlert(
      context: context,
      title: title,
      message: message,
      type: AlertType.info,
      confirmText: confirmText ?? LocaleKeys.confirmButton.tr(),
      onConfirm: onConfirm,
    );
  }

  // Danger Alert - خطر
  void showDangerAlert({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    _showAlert(
      context: context,
      title: title,
      message: message,
      type: AlertType.error,
      confirmText: confirmText ?? LocaleKeys.confirmButton.tr(),
      cancelText: cancelText ?? LocaleKeys.cancelButton.tr(),
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  // Success Alert - نجاح
  void showSuccessAlert({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    _showAlert(
      context: context,
      title: title,
      message: message,
      type: AlertType.success,
      confirmText: confirmText ?? LocaleKeys.confirmButton.tr(),
      onConfirm: onConfirm,
    );
  }

  // Warning Alert - تحذير
  void showWarningAlert({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    _showAlert(
      context: context,
      title: title,
      message: message,
      type: AlertType.warning,
      confirmText: confirmText ?? LocaleKeys.confirmButton.tr(),
      cancelText: cancelText ?? LocaleKeys.cancelButton.tr(),
      onConfirm: onConfirm,
      onCancel: onCancel,
    );
  }

  // Private method to show alert
  void _showAlert({
    required BuildContext context,
    required String title,
    required String message,
    required AlertType type,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    final alertConfig = _getAlertConfig(type);
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    showDialog<void>(
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha(120),

      context: context,
      builder: (context) => Center(
        child: Container(
          margin: isDesktop
              ? const EdgeInsets.symmetric(horizontal: 400, vertical: 160)
              : const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: alertConfig.gradient,
            boxShadow: [
              BoxShadow(
                color: alertConfig.shadowColor,
                blurRadius: 25,
                spreadRadius: 5,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white.withAlpha(10), Colors.white.withAlpha(5)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Decorative top border
                Container(
                  height: 4,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(60),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 24),

                // Icon with enhanced design
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(40),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: alertConfig.iconBackgroundColor.withAlpha(80),
                        blurRadius: 20,
                        spreadRadius: 3,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.white.withAlpha(30),
                        blurRadius: 15,
                        spreadRadius: 1,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Icon(alertConfig.icon, size: 40, color: Colors.white),
                ),

                const SizedBox(height: 28),

                // Title with enhanced styling
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Message with enhanced styling
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Enhanced buttons
                Row(
                  children: [
                    if (cancelText != null) ...[
                      Expanded(
                        child: _buildEnhancedButton(
                          text: cancelText,
                          context: context,
                          backgroundColor: Colors.white.withAlpha(20),
                          textColor: Colors.white,
                          borderColor: Colors.white.withAlpha(40),
                          onPressed: () {
                            onCancel?.call();
                            context.pop();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: _buildEnhancedButton(
                        context: context,
                        text: confirmText ?? LocaleKeys.confirmButton.tr(),
                        backgroundColor: Colors.white,
                        textColor: Colors.black,
                        borderColor: Colors.white,
                        onPressed: () {
                          onConfirm?.call();
                          context.pop();
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced button widget
  Widget _buildEnhancedButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    return Container(
      height: 50,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );
  }

  // Get alert configuration based on type
  _AlertConfig _getAlertConfig(AlertType type) {
    switch (type) {
      case AlertType.info:
        return _AlertConfig(
          icon: Icons.info_outline,
          iconColor: Colors.white,
          iconBackgroundColor: const Color(0xFF4F46E5),
          textColor: Colors.white,
          borderColor: const Color(0xFF4F46E5),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4F46E5), // Indigo
              Color(0xFF7C3AED), // Purple
              Color(0xFF1E40AF), // Dark Blue
            ],
            stops: [0.0, 0.5, 1.0],
          ),
          shadowColor: const Color(0xFF4F46E5).withAlpha(40),
          confirmButtonColor: Colors.white,
          confirmTextColor: const Color(0xFF4F46E5),
          cancelButtonColor: Colors.white.withAlpha(50),
          cancelTextColor: Colors.white,
        );

      case AlertType.error:
        return _AlertConfig(
          icon: Icons.error_outline,
          iconColor: Colors.white,
          iconBackgroundColor: const Color(0xFFDC2626),
          textColor: Colors.white,
          borderColor: const Color(0xFFDC2626),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF87171), // Light Red
              Color(0xFFEF4444), // Red
              Color(0xFFDC2626), // Dark Red
            ],
            stops: [0.0, 0.5, 1.0],
          ),
          shadowColor: const Color(0xFFEF4444).withAlpha(40),
          confirmButtonColor: Colors.white,
          confirmTextColor: const Color(0xFFDC2626),
          cancelButtonColor: Colors.white.withAlpha(50),
          cancelTextColor: Colors.white,
        );

      case AlertType.success:
        return _AlertConfig(
          icon: Icons.check_circle_outline,
          iconColor: Colors.white,
          iconBackgroundColor: const Color(0xFF059669),
          textColor: Colors.white,
          borderColor: const Color(0xFF059669),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF34D399), // Light Green
              Color(0xFF10B981), // Green
              Color(0xFF059669), // Dark Green
            ],
            stops: [0.0, 0.5, 1.0],
          ),
          shadowColor: const Color(0xFF10B981).withAlpha(40),
          confirmButtonColor: Colors.white,
          confirmTextColor: const Color(0xFF059669),
          cancelButtonColor: Colors.white.withAlpha(50),
          cancelTextColor: Colors.white,
        );

      case AlertType.warning:
        return _AlertConfig(
          icon: Icons.warning_outlined,
          iconColor: Colors.white,
          iconBackgroundColor: const Color(0xFFD97706),
          textColor: Colors.white,
          borderColor: const Color(0xFFD97706),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFBBF24), // Light Amber
              Color(0xFFF59E0B), // Amber
              Color(0xFFD97706), // Dark Amber
            ],
            stops: [0.0, 0.5, 1.0],
          ),
          shadowColor: const Color(0xFFF59E0B).withAlpha(40),
          confirmButtonColor: Colors.white,
          confirmTextColor: const Color(0xFFD97706),
          cancelButtonColor: Colors.white.withAlpha(50),
          cancelTextColor: Colors.white,
        );
    }
  }
}

// Alert configuration class
class _AlertConfig {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color textColor;
  final Color borderColor;
  final LinearGradient gradient;
  final Color shadowColor;
  final Color confirmButtonColor;
  final Color confirmTextColor;
  final Color cancelButtonColor;
  final Color cancelTextColor;

  _AlertConfig({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.textColor,
    required this.borderColor,
    required this.gradient,
    required this.shadowColor,
    required this.confirmButtonColor,
    required this.confirmTextColor,
    required this.cancelButtonColor,
    required this.cancelTextColor,
  });
}
