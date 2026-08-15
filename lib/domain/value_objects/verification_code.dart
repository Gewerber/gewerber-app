import 'package:equatable/equatable.dart';

/// A one-time verification code sent by e-mail.
///
/// Accepts the 6-digit codes the backend issues. Throws [FormatException]
/// when the value does not match that shape.
class VerificationCode extends Equatable {
  VerificationCode(String value) : value = value.trim() {
    if (!RegExp(r'^\d{6}$').hasMatch(this.value)) {
      throw const FormatException('Verification code must be 6 digits');
    }
  }

  final String value;

  @override
  List<Object?> get props => [value];
}
