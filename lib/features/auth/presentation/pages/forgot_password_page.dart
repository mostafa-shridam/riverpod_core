import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_snackbar.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/app_text_field.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/validation_message.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/errors/error_messages.dart';
import 'package:riverpod_core/core/utils/validators.dart';
import 'package:riverpod_core/features/auth/presentation/widgets/auth_layout.dart';
import 'package:riverpod_core/features/auth/providers/forgot_password_controller.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  static const routeName = '/forgot-password';

  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(forgotPasswordControllerProvider.notifier)
        .submit(_email.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);
    final busy = state.isLoading;
    final error = state.error;
    final fieldErrors = error is ValidationException ? error : null;
    final spacing = context.tokens.spacing;

    ref.listen(forgotPasswordControllerProvider, (previous, next) {
      final error = next.error;
      if (error is AppException && error is! ValidationException) {
        showAppSnackbar(
          context,
          message: errorMessageKey(error).tr(),
          type: AppStatusType.error,
        );
        return;
      }
      // Accepted: say so and go back to sign-in.
      if (previous?.isLoading == true && next.hasValue && !next.isLoading) {
        showAppSnackbar(
          context,
          message: LocaleKeys.auth_forgot_done.tr(),
          type: AppStatusType.success,
        );
        if (context.canPop()) context.pop();
      }
    });

    return AuthLayout(
      key: const ValueKey('forgot-password-page'),
      title: LocaleKeys.auth_forgot_title.tr(),
      children: [
        Form(
          key: _formKey,
          child: AppTextField(
            controller: _email,
            label: LocaleKeys.auth_fields_email.tr(),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            validator: localizedValidator(Validators.email),
            errorText: fieldErrors?.firstMessageFor('email'),
            enabled: !busy,
          ),
        ),
        SizedBox(height: spacing.lg),
        AppButton(
          label: LocaleKeys.auth_forgot_submit.tr(),
          isLoading: busy,
          fullWidth: true,
          onPressed: busy ? null : _submit,
        ),
      ],
    );
  }
}
