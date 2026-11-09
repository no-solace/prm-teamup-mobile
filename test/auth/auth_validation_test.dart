import 'package:flutter_test/flutter_test.dart';
import 'package:teamup_exe/services/app_error.dart';
import 'package:teamup_exe/services/auth_validation.dart';

void main() {
  test('email trims whitespace and rejects malformed input', () {
    expect(AuthValidation.email(' mentor@example.com '), 'mentor@example.com');
    for (final input in ['', 'mentor', '@example.com', 'a b@example.com']) {
      expect(() => AuthValidation.email(input), throwsA(isA<ValidationError>()));
    }
  });
  test('registration requires 6 characters; existing passwords are not trimmed', () {
    expect(() => AuthValidation.password('12345', registering: true), throwsA(isA<ValidationError>()));
    AuthValidation.password('      ', registering: true);
    AuthValidation.password('short');
    expect(() => AuthValidation.password(''), throwsA(isA<ValidationError>()));
  });
  test('phone requires E.164 and accepts common visual separators', () {
    expect(AuthValidation.phone(' +84 (912) 345-678 '), '+84912345678');
    for (final input in ['0912345678', '+0123456789', '+84', '+849123456789012345']) {
      expect(() => AuthValidation.phone(input), throwsA(isA<ValidationError>()));
    }
  });
  test('SMS code accepts exactly 6 digits', () {
    expect(AuthValidation.smsCode(' 123456 '), '123456');
    for (final input in ['', '12345', '1234567', '12a456']) {
      expect(() => AuthValidation.smsCode(input), throwsA(isA<ValidationError>()));
    }
  });
}
