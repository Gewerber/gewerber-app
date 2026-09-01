import 'package:equatable/equatable.dart';

import 'package:gewerber_app/core/utils/constants.dart';

/// A one-time verification code sent by e-mail.
///
/// Accepts codes whose length matches [AppConstants.verificationCodeLength].
/// Throws [FormatException] when the value does not match that shape.
class VerificationCode extends Equatable {
  VerificationCode(String value) : value = value.trim() {
    final pattern = '^\\d{${AppConstants.verificationCodeLength}}\$';
    if (!RegExp(pattern).hasMatch(this.value)) {
      throw FormatException(
        'Verification code must be ${AppConstants.verificationCodeLength} digits',
      );
    }
  }

  final String value;

  @override
  List<Object?> get props => [value];
}
