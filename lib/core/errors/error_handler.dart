import 'exceptions.dart';
import 'failures.dart';

/// Translates infrastructure [AppException]s into domain [Failure]s.
///
/// Unknown exceptions map to a generic [NetworkFailure] so that callers can
/// treat every source error uniformly.
Failure mapAppException(AppException exception) {
  return switch (exception) {
    InvalidCredentialsException() => const InvalidCredentialsFailure(),
    TooManyAttemptsException() => const TooManyAttemptsFailure(),
    UserBlockedException() => const UserBlockedFailure(),
    EmailAlreadyRegisteredException() => const EmailAlreadyRegisteredFailure(),
    InvalidVerificationCodeException() =>
      const InvalidVerificationCodeFailure(),
    ExpiredVerificationCodeException() =>
      const ExpiredVerificationCodeFailure(),
    PasswordPolicyViolationException() =>
      const PasswordPolicyViolationFailure(),
    SocialAuthNotConfiguredException() =>
      const SocialAuthNotConfiguredFailure(),
    SocialAuthFailureException(:final message) => SocialAuthFailure(message),
    AccountDeletedException() => const AccountDeletedFailure(),
    NetworkException() => const NetworkFailure(),
    ConflictException() => const ConflictFailure(),
    NotFoundException() => const NotFoundFailure(),
    AppException() => const NetworkFailure(),
  };
}
