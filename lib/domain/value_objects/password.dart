import 'package:equatable/equatable.dart';

/// A validated password.
///
/// Requires at least 8 characters. Throws [FormatException] when the value is
/// too short; the full policy is enforced server-side.
class Password extends Equatable {
  Password(String value) : value = value {
    if (value.length < 8) {
      throw const FormatException('Password must be at least 8 characters');
    }
  }

  final String value;

  @override
  List<Object?> get props => [value];
}
