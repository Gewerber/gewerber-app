import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/user.dart';
import 'package:gewerber_app/domain/value_objects/email.dart';
import 'package:gewerber_app/domain/value_objects/password.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';
import 'package:gewerber_app/domain/value_objects/verification_code.dart';

/// Contract for authentication operations used by the application layer.
///
/// Implementations live in the infrastructure layer and must never leak
/// framework or transport details into the domain.
abstract interface class AuthRepository {
  /// Signs the user in with email and password.
  Future<User> login({required Email email, required Password password});

  /// Starts a registration: requests a verification code for [email].
  ///
  /// Returns an opaque account-request id to be used with
  /// [verifyRegistrationCode]. Throws [EmailAlreadyRegisteredFailure] when the
  /// address is already taken.
  Future<String> startRegistration({required Email email});

  /// Verifies the code sent during registration.
  ///
  /// Returns a registration token to be passed to [finishRegistration].
  Future<String> verifyRegistrationCode({
    required String accountRequestId,
    required VerificationCode code,
  });

  /// Completes registration by setting a password.
  ///
  /// The returned user is authenticated (the session is persisted).
  Future<User> finishRegistration({
    required String registrationToken,
    required Password password,
  });

  /// Requests a password reset code for [email].
  ///
  /// Returns an opaque request id to be used with [verifyPasswordResetCode].
  Future<String> startPasswordReset({required Email email});

  /// Verifies the code sent during a password reset.
  ///
  /// Returns a reset token to be passed to [finishPasswordReset].
  Future<String> verifyPasswordResetCode({
    required String passwordResetRequestId,
    required VerificationCode code,
  });

  /// Completes a password reset by setting a new password.
  Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required Password newPassword,
  });

  /// Signs the user in through a social identity provider.
  ///
  /// Throws [SocialAuthNotConfiguredFailure] when the provider is not
  /// configured for the current build.
  Future<User> socialLogin(SocialAuthProvider provider);

  /// Restores a previously persisted session, or `null` when no session
  /// exists (first launch, signed out or expired).
  Future<User?> restoreSession();

  /// Logs the current user out.
  Future<void> logOut();
}

/// Represents the outcome of an authentication attempt.
sealed class AuthResult {
  const AuthResult();
}

class AuthSuccess extends AuthResult {
  const AuthSuccess(this.user);

  final User user;
}

class AuthFailed extends AuthResult {
  const AuthFailed(this.failure);

  final Failure failure;
}
