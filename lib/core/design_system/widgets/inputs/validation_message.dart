import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:riverpod_core/core/utils/validators.dart';
import 'package:riverpod_core/generated/locale_keys.g.dart';

/// Localized text for a core [ValidationError].
String validationMessage(ValidationError error) {
  return switch (error) {
    ValidationError.required => LocaleKeys.ds_inputs_errors_required.tr(),
    ValidationError.invalidEmail =>
      LocaleKeys.ds_inputs_errors_invalidEmail.tr(),
    ValidationError.passwordTooShort =>
      LocaleKeys.ds_inputs_errors_passwordTooShort.tr(
        args: ['${Validators.minPasswordLength}'],
      ),
    ValidationError.invalidPhone =>
      LocaleKeys.ds_inputs_errors_invalidPhone.tr(),
    ValidationError.phoneTooShort =>
      LocaleKeys.ds_inputs_errors_phoneTooShort.tr(),
  };
}

/// Turns a core rule (for example [Validators.email]) into a Form validator
/// that returns localized text. Use it as `validator:` on any input.
String? Function(String?) localizedValidator(
  ValidationError? Function(String?) rule,
) {
  return (value) {
    final error = rule(value);
    return error == null ? null : validationMessage(error);
  };
}
