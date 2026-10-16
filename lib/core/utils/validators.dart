/// Why a field value is invalid. Core stays free of UI text: the design
/// system maps each case to a localized message.
enum ValidationError {
  required,
  invalidEmail,
  passwordTooShort,
  invalidPhone,
  phoneTooShort,
}

/// Pure field rules. Each returns `null` when the value is valid.
class Validators {
  /// Minimum password length accepted by [password].
  static const int minPasswordLength = 6;

  /// Minimum digit count accepted by [phone].
  static const int minPhoneDigits = 9;

  static final RegExp _emailPattern = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );
  static final RegExp _phonePattern = RegExp(r'^[0-9+]+$');

  static ValidationError? required(String? value) {
    if (value == null || value.isEmpty) return ValidationError.required;
    return null;
  }

  static ValidationError? email(String? value) {
    final missing = required(value);
    if (missing != null) return missing;
    if (!_emailPattern.hasMatch(value!)) return ValidationError.invalidEmail;
    return null;
  }

  static ValidationError? password(String? value) {
    final missing = required(value);
    if (missing != null) return missing;
    if (value!.length < minPasswordLength) {
      return ValidationError.passwordTooShort;
    }
    return null;
  }

  static ValidationError? phone(String? value) {
    final missing = required(value);
    if (missing != null) return missing;
    if (!_phonePattern.hasMatch(value!)) return ValidationError.invalidPhone;
    if (value.length < minPhoneDigits) return ValidationError.phoneTooShort;
    return null;
  }
}
