import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_core/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('required rejects null and empty', () {
      expect(Validators.required(null), ValidationError.required);
      expect(Validators.required(''), ValidationError.required);
      expect(Validators.required('x'), isNull);
    });

    test('email accepts a normal address and rejects others', () {
      expect(Validators.email('a@b.co'), isNull);
      expect(Validators.email(''), ValidationError.required);
      expect(Validators.email('nope'), ValidationError.invalidEmail);
      expect(Validators.email('a@b'), ValidationError.invalidEmail);
    });

    test('password enforces the minimum length', () {
      expect(Validators.password(null), ValidationError.required);
      expect(Validators.password('12345'), ValidationError.passwordTooShort);
      expect(Validators.password('123456'), isNull);
    });

    test(
      'phone accepts digits and a plus, rejects letters and short numbers',
      () {
        expect(Validators.phone(''), ValidationError.required);
        expect(Validators.phone('+20123456789'), isNull);
        expect(Validators.phone('12ab'), ValidationError.invalidPhone);
        expect(Validators.phone('12345'), ValidationError.phoneTooShort);
      },
    );
  });
}
