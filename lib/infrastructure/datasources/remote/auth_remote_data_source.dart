import 'package:gewerber_backend_client/gewerber_backend_client.dart';
import 'package:injectable/injectable.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/infrastructure/core/serverpod_client_factory.dart';

/// Transport-level authentication calls against the Serverpod backend.
///
/// Every serverpod exception is translated into an [AppException] so higher
/// layers stay free of transport details.
@LazySingleton(env: [AppEnvironment.authLive])
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._clientFactory);

  final ServerpodClientFactory _clientFactory;

  Client get _client => _clientFactory.client;

  /// Signs the user in and registers the session with the session manager.
  Future<AuthSuccess> login({
    required String email,
    required String password,
  }) async {
    try {
      final success = await _client.emailIdp.login(
        email: email,
        password: password,
      );
      await _client.auth.updateSignedInUser(success);
      return success;
    } on EmailAccountLoginException catch (e) {
      throw switch (e.reason) {
        EmailAccountLoginExceptionReason.invalidCredentials =>
          const InvalidCredentialsException(),
        EmailAccountLoginExceptionReason.tooManyAttempts =>
          const TooManyAttemptsException(),
        EmailAccountLoginExceptionReason.unknown => const NetworkException(),
      };
    } on AuthUserBlockedException {
      throw const UserBlockedException();
    } on ServerpodClientException {
      throw const NetworkException();
    }
  }

  /// Requests a verification code to register a new account.
  Future<UuidValue> startRegistration({required String email}) async {
    try {
      return await _client.emailIdp.startRegistration(email: email);
    } on EmailAccountRequestException catch (e) {
      throw _mapRequestError(e);
    } on ServerpodClientException {
      throw const NetworkException();
    }
  }

  /// Verifies the registration code and returns a registration token.
  Future<String> verifyRegistrationCode({
    required UuidValue accountRequestId,
    required String code,
  }) async {
    try {
      return await _client.emailIdp.verifyRegistrationCode(
        accountRequestId: accountRequestId,
        verificationCode: code,
      );
    } on EmailAccountRequestException catch (e) {
      throw _mapRequestError(e);
    } on AuthUserBlockedException {
      throw const UserBlockedException();
    } on ServerpodClientException {
      throw const NetworkException();
    }
  }

  /// Completes registration by setting a password and signs the user in.
  Future<AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) async {
    try {
      final success = await _client.emailIdp.finishRegistration(
        registrationToken: registrationToken,
        password: password,
      );
      await _client.auth.updateSignedInUser(success);
      return success;
    } on EmailAccountRequestException catch (e) {
      throw _mapRequestError(e);
    } on AuthUserBlockedException {
      throw const UserBlockedException();
    } on ServerpodClientException {
      throw const NetworkException();
    }
  }

  /// Requests a verification code to reset the password.
  Future<UuidValue> startPasswordReset({required String email}) async {
    try {
      return await _client.emailIdp.startPasswordReset(email: email);
    } on EmailAccountPasswordResetException catch (e) {
      throw _mapPasswordResetError(e);
    } on ServerpodClientException {
      throw const NetworkException();
    }
  }

  /// Verifies the reset code and returns a finish-reset token.
  Future<String> verifyPasswordResetCode({
    required UuidValue passwordResetRequestId,
    required String code,
  }) async {
    try {
      return await _client.emailIdp.verifyPasswordResetCode(
        passwordResetRequestId: passwordResetRequestId,
        verificationCode: code,
      );
    } on EmailAccountPasswordResetException catch (e) {
      throw _mapPasswordResetError(e);
    } on ServerpodClientException {
      throw const NetworkException();
    }
  }

  /// Completes the password reset with a new password.
  Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) async {
    try {
      await _client.emailIdp.finishPasswordReset(
        finishPasswordResetToken: finishPasswordResetToken,
        newPassword: newPassword,
      );
    } on EmailAccountPasswordResetException catch (e) {
      throw _mapPasswordResetError(e);
    } on AuthUserBlockedException {
      throw const UserBlockedException();
    } on ServerpodClientException {
      throw const NetworkException();
    }
  }

  /// Restores the persisted session and validates it with the server.
  ///
  /// Returns the session when signed in, or `null` otherwise.
  Future<AuthSuccess?> restoreSession() async {
    await _clientFactory.initialize();
    return _client.auth.authInfo;
  }

  /// Signs the current user out of this device.
  Future<void> signOut() async {
    // The session manager always clears the local session, even when the
    // server cannot be reached.
    await _client.auth.signOutDevice();
  }

  AppException _mapRequestError(EmailAccountRequestException e) {
    return switch (e.reason) {
      EmailAccountRequestExceptionReason.expired =>
        const ExpiredVerificationCodeException(),
      EmailAccountRequestExceptionReason.invalid =>
        const InvalidVerificationCodeException(),
      EmailAccountRequestExceptionReason.policyViolation =>
        const PasswordPolicyViolationException(),
      EmailAccountRequestExceptionReason.tooManyAttempts =>
        const TooManyAttemptsException(),
      EmailAccountRequestExceptionReason.unknown => const NetworkException(),
    };
  }

  AppException _mapPasswordResetError(EmailAccountPasswordResetException e) {
    return switch (e.reason) {
      EmailAccountPasswordResetExceptionReason.expired =>
        const ExpiredVerificationCodeException(),
      EmailAccountPasswordResetExceptionReason.invalid =>
        const InvalidVerificationCodeException(),
      EmailAccountPasswordResetExceptionReason.policyViolation =>
        const PasswordPolicyViolationException(),
      EmailAccountPasswordResetExceptionReason.tooManyAttempts =>
        const TooManyAttemptsException(),
      EmailAccountPasswordResetExceptionReason.unknown =>
        const NetworkException(),
    };
  }
}
