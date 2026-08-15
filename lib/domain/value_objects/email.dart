import 'package:equatable/equatable.dart';

/// A validated e-mail address.
///
/// Throws [FormatException] on construction when the value does not look like
/// an e-mail address.
class Email extends Equatable {
  Email(String value) : value = value.trim() {
    final isValid = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}'
      r'[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
    ).hasMatch(this.value);
    if (!isValid) {
      throw const FormatException('Invalid email address');
    }
  }

  final String value;

  @override
  List<Object?> get props => [value];
}
