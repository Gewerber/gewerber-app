/// Source exceptions raised by the infrastructure layer.
///
/// Each concrete exception type maps to a matching [Failure] in
/// `failures.dart` via `core/errors/error_handler.dart`.
library;

abstract base class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when the supplied credentials are invalid.
final class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException() : super('Invalid credentials');
}

/// Thrown when a user's account has been blocked.
final class UserBlockedException extends AppException {
  const UserBlockedException() : super('User account is blocked');
}

/// Thrown when login is blocked due to too many failed attempts.
final class TooManyAttemptsException extends AppException {
  const TooManyAttemptsException() : super('Too many failed attempts');
}

/// Thrown when the email address is already registered.
final class EmailAlreadyRegisteredException extends AppException {
  const EmailAlreadyRegisteredException() : super('Email already registered');
}

/// Thrown when a registration/reset verification code is invalid.
final class InvalidVerificationCodeException extends AppException {
  const InvalidVerificationCodeException() : super('Invalid verification code');
}

/// Thrown when a registration/reset request (or its code) has expired.
final class ExpiredVerificationCodeException extends AppException {
  const ExpiredVerificationCodeException() : super('Verification code expired');
}

/// Thrown when the password does not comply with the server policy.
final class PasswordPolicyViolationException extends AppException {
  const PasswordPolicyViolationException() : super('Password policy violation');
}

/// Thrown when the backend reports that the signed-in account has been
/// deleted (the server answers `NotFoundException` on every profile call).
final class AccountDeletedException extends AppException {
  const AccountDeletedException() : super('Account has been deleted');
}

/// Thrown when the backend could not be reached.
final class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error']);
}

/// Thrown when the server rejects the action because it conflicts with an
/// existing resource (e.g. a schedule already attached to an invoice).
final class ConflictException extends AppException {
  const ConflictException([super.message = 'Conflict']);
}

/// Thrown when the requested resource does not exist.
final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Not found']);
}

/// Thrown when a social identity provider is not configured for the app.
final class SocialAuthNotConfiguredException extends AppException {
  const SocialAuthNotConfiguredException()
    : super('Social sign-in is not configured');
}

/// Thrown when a social identity provider rejects the sign-in attempt.
final class SocialAuthFailureException extends AppException {
  const SocialAuthFailureException([super.message = 'Social sign-in failed']);
}
