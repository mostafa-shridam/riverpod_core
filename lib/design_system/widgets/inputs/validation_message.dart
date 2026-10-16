import 'package:easy_localization/easy_localization.dart' hide TextDirection;

import 'package:riverpod_core/core/utils/validators.dart';
import 'package:riverpod_core/design_system/widgets/inputs/inputs_strings.dart';

/// Localized text for a core [ValidationError].
String validationMessage(ValidationError error) {
  return switch (error) {
    ValidationError.required => errorRequiredKey.tr(),
    ValidationError.invalidEmail => errorInvalidEmailKey.tr(),
    ValidationError.passwordTooShort => errorPasswordTooShortKey.tr(
      args: ['${Validators.minPasswordLength}'],
    ),
    ValidationError.invalidPhone => errorInvalidPhoneKey.tr(),
    ValidationError.phoneTooShort => errorPhoneTooShortKey.tr(),
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
