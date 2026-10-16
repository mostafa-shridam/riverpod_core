import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:riverpod_core/core/design_system/widgets/async/async_strings.dart';
import 'package:riverpod_core/core/design_system/widgets/async/state_illustration.dart';
import 'package:riverpod_core/core/design_system/widgets/async/state_message.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/errors/error_messages.dart';

/// Failure with no data to show. The text comes from [exception] through
/// `errorMessageKey` (never `toString()`); [isOffline] switches to the
/// offline variant. Retry shows only when [onRetry] is set.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.exception,
    this.isOffline = false,
    this.title,
    this.message,
    this.onRetry,
    this.retryLabel,
  });

  /// Source of the localized message; null falls back to the generic text.
  final AppException? exception;

  /// Offline variant: wifi icon and "check your connection" copy.
  final bool isOffline;

  /// Overrides the localized title.
  final String? title;

  /// Overrides the message derived from [exception].
  final String? message;
  final VoidCallback? onRetry;

  /// Overrides the localized "try again" label.
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final type = isOffline ? AppStatusType.warning : AppStatusType.error;
    final colors = type.colorsOf(context);
    final exception = this.exception;
    final derived = exception == null
        ? errorMessageKey(const UnknownException()).tr()
        : (errorServerMessage(exception) ?? errorMessageKey(exception).tr());
    return StateMessage(
      illustration: StateIllustration(
        icon: isOffline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded,
        accent: colors.accent,
        container: colors.container,
        onContainer: colors.onContainer,
      ),
      title:
          title ??
          (isOffline ? asyncOfflineTitleKey.tr() : asyncErrorTitleKey.tr()),
      message: message ?? (isOffline ? asyncOfflineMessageKey.tr() : derived),
      action: onRetry == null
          ? null
          : AppButton(
              label: retryLabel ?? asyncRetryKey.tr(),
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
    );
  }
}
