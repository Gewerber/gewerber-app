import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/domain/value_objects/verification_code.dart';

void main() {
  test('accepts an 8-digit code', () {
    final code = VerificationCode(' 12345678 ');

    expect(code.value, '12345678');
  });

  test('rejects a 7-digit code', () {
    expect(() => VerificationCode('1234567'), throwsFormatException);
  });

  test('rejects codes with non-digit characters', () {
    expect(() => VerificationCode('1234 678'), throwsFormatException);
    expect(() => VerificationCode('abcdefgh'), throwsFormatException);
  });
}
