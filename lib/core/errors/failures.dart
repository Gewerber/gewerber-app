/// Abstract failure type used as the error arm of [Either]-style results.
///
/// Concrete failure classes are added together with the domain logic they
/// describe (see `core/errors/exceptions.dart` for source exceptions).
abstract base class Failure {
  const Failure([this.message]);

  /// Human-readable description of the failure.
  final String? message;

  @override
  String toString() => '$runtimeType${message == null ? '' : ': $message'}';
}

/// The supplied credentials were rejected.
final class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure() : super('Invalid credentials');
}

/// Client-side validation of the submitted value failed.
final class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input']);
}

/// The login was blocked due to too many failed attempts.
final class TooManyAttemptsFailure extends Failure {
  const TooManyAttemptsFailure() : super('Too many failed attempts');
}

/// The user's account is blocked.
final class UserBlockedFailure extends Failure {
  const UserBlockedFailure() : super('User account is blocked');
}

/// The email address is already registered.
final class EmailAlreadyRegisteredFailure extends Failure {
  const EmailAlreadyRegisteredFailure() : super('Email already registered');
}

/// A verification code was invalid.
final class InvalidVerificationCodeFailure extends Failure {
  const InvalidVerificationCodeFailure() : super('Invalid verification code');
}

/// A verification code or request expired.
final class ExpiredVerificationCodeFailure extends Failure {
  const ExpiredVerificationCodeFailure() : super('Verification code expired');
}

/// The password violates the password policy.
final class PasswordPolicyViolationFailure extends Failure {
  const PasswordPolicyViolationFailure() : super('Password policy violation');
}

/// The backend could not be reached.
final class NetworkFailure extends Failure {
  const NetworkFailure() : super('Network error');
}

/// A social identity provider is not configured.
final class SocialAuthNotConfiguredFailure extends Failure {
  const SocialAuthNotConfiguredFailure() : super('Social sign-in unavailable');
}

/// A social identity provider rejected the sign-in attempt.
final class SocialAuthFailure extends Failure {
  const SocialAuthFailure([super.message = 'Social sign-in failed']);
}
