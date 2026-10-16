import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_core/core/design_system/theme/theme_context.dart';
import 'package:riverpod_core/core/design_system/widgets/buttons/app_button.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/app_status_type.dart';
import 'package:riverpod_core/core/design_system/widgets/feedback/snackbar/app_snackbar.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/app_password_field.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/app_text_field.dart';
import 'package:riverpod_core/core/design_system/widgets/inputs/validation_message.dart';
import 'package:riverpod_core/core/errors/app_exception.dart';
import 'package:riverpod_core/core/errors/error_messages.dart';
import 'package:riverpod_core/core/utils/validators.dart';
import 'package:riverpod_core/features/auth/presentation/widgets/auth_layout.dart';
import 'package:riverpod_core/features/auth/providers/register_controller.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

class RegisterPage extends ConsumerStatefulWidget {
  static const routeName = '/register';

  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ref
        .read(registerControllerProvider.notifier)
        .submit(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);
    final busy = state.isLoading;
    final error = state.error;
    final fieldErrors = error is ValidationException ? error : null;
    final spacing = context.tokens.spacing;

    ref.listen(registerControllerProvider, (previous, next) {
      final error = next.error;
      if (error is AppException && error is! ValidationException) {
        showAppSnackbar(
          context,
          message: errorMessageKey(error).tr(),
          type: AppStatusType.error,
        );
      }
    });

    return AuthLayout(
      key: const ValueKey('register-page'),
      title: LocaleKeys.auth_register_title.tr(),
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _name,
                label: LocaleKeys.auth_fields_name.tr(),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                validator: localizedValidator(Validators.required),
                errorText: fieldErrors?.firstMessageFor('name'),
                enabled: !busy,
              ),
              SizedBox(height: spacing.md),
              AppTextField(
                controller: _email,
                label: LocaleKeys.auth_fields_email.tr(),
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                validator: localizedValidator(Validators.email),
                errorText: fieldErrors?.firstMessageFor('email'),
                enabled: !busy,
              ),
              SizedBox(height: spacing.md),
              AppPasswordField(
                controller: _password,
                label: LocaleKeys.auth_fields_password.tr(),
                textInputAction: TextInputAction.done,
                validator: localizedValidator(Validators.password),
                onSubmitted: (_) => _submit(),
                errorText: fieldErrors?.firstMessageFor('password'),
                enabled: !busy,
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.lg),
        AppButton(
          label: LocaleKeys.auth_register_submit.tr(),
          isLoading: busy,
          fullWidth: true,
          onPressed: busy ? null : _submit,
        ),
        AppButton(
          label: LocaleKeys.auth_register_login.tr(),
          variant: AppButtonVariant.text,
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
