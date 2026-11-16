import 'package:gewerber_backend_client/gewerber_backend_client.dart';
import 'package:injectable/injectable.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/infrastructure/core/serverpod_client_factory.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/social_auth_flow.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/user_profile_remote_data_source.dart';

/// Outcome of a successful social sign-in.
///
/// Carries the session ([success]) together with the profile attribute the
/// backend derives from the linked identity providers and that the session
/// itself does not carry, so the repository can map a complete user.
class SocialSignInResult {
  const SocialSignInResult({required this.success, required this.primaryEmail});

  /// Session returned by the backend's identity-provider endpoint.
  final AuthSuccess success;

  /// Address the backend resolved for the caller, or `null` when no provider
  /// supplied one (e.g. a phone-number-only account) *or* when the profile read
  /// failed. Callers must not read `null` as "this account has no address": a
  /// transient `me()` failure yields `null` as well, and the repository keeps
  /// the previously stored address in that case.
  final String? primaryEmail;
}

/// Transport-level authentication calls against the Serverpod backend.
///
/// Every serverpod exception is translated into an [AppException] so higher
/// layers stay free of transport details.
@LazySingleton(env: [AppEnvironment.authLive])
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._clientFactory, this._userProfileDataSource);

  final ServerpodClientFactory _clientFactory;
  final UserProfileRemoteDataSource _userProfileDataSource;

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

  /// Exchanges a provider [credential] for a session.
  ///
  /// The backend verifies the credential with the identity provider, creates
  /// the account on first sign-in and answers with the session. The caller's
  /// profile is read afterwards so the repository can map a single, complete
  /// result (the profile is the only place the backend reports the primary
  /// e-mail).
  ///
  /// A failing profile read does not discard the session: sign-in succeeded and
  /// the session manager already holds the session, so the caller gets a result
  /// with an empty e-mail instead of a spurious error.
  Future<SocialSignInResult> socialLogin(SocialCredential credential) async {
    final AuthSuccess success;
    try {
      success = await _loginWith(credential);
      await _client.auth.updateSignedInUser(success);
    } on AuthUserBlockedException {
      throw const UserBlockedException();
    } on GoogleIdTokenVerificationException {
      // The backend could not verify the Google ID token (expired, wrong
      // audience, replayed nonce, ...). A user-facing error, not a transport
      // one.
      throw const SocialAuthFailureException(
        'Google could not verify the sign-in',
      );
    } on FacebookAccessTokenVerificationException {
      throw const SocialAuthFailureException(
        'Facebook could not verify the sign-in',
      );
    } on MicrosoftAccessTokenVerificationException {
      throw const SocialAuthFailureException(
        'Microsoft could not verify the sign-in',
      );
    } on ServerpodClientException catch (e) {
      // A disabled provider answers 500, not 404: every IdP endpoint is
      // registered unconditionally and the provider lookup inside it throws a
      // StateError, which Serverpod turns into an internal server error. A 404
      // is still mapped for older deployments that did not register the
      // endpoint at all.
      //
      // The backend fix is to not register the endpoints of disabled providers
      // (or to answer a dedicated serializable exception), which would let this
      // be narrowed to the real condition. Until then a genuine 500 from a
      // provider is indistinguishable from "provider disabled" and surfaces the
      // "unavailable" snackbar.
      if (e is ServerpodClientInternalServerError ||
          e is ServerpodClientNotFound) {
        throw const SocialAuthNotConfiguredException();
      }
      throw const NetworkException();
    }

    return SocialSignInResult(
      success: success,
      primaryEmail: await resolvePrimaryEmail(),
    );
  }

  /// Resolves the primary e-mail address of the signed-in user, or `null` when
  /// the backend has none (or the profile cannot be read).
  ///
  /// Best-effort by design: registration and session restore already hold a
  /// valid session at this point, so a failed lookup must not fail the flow —
  /// the UI simply falls back to an empty address.
  Future<String?> resolvePrimaryEmail() async {
    try {
      final identity = await _userProfileDataSource.me();
      return identity.primaryEmail;
    } on AppException {
      return null;
    }
  }

  Future<AuthSuccess> _loginWith(SocialCredential credential) {
    return switch (credential) {
      GoogleCredential(:final idToken, :final accessToken) =>
        _client.googleIdp.login(idToken: idToken, accessToken: accessToken),
      // Web build: the backend exchanges the authorization code with the
      // client secret it holds (`GoogleIdpConfigFromPasswords`).
      GoogleCodeCredential(
        :final code,
        :final codeVerifier,
        :final redirectUri,
      ) =>
        _client.googleIdp.loginWithCode(
          code: code,
          codeVerifier: codeVerifier,
          redirectUri: redirectUri,
        ),
      AppleCredential(
        :final identityToken,
        :final authorizationCode,
        :final isNativeApplePlatformSignIn,
        :final firstName,
        :final lastName,
      ) =>
        _client.appleIdp.login(
          identityToken: identityToken,
          authorizationCode: authorizationCode,
          isNativeApplePlatformSignIn: isNativeApplePlatformSignIn,
          firstName: firstName,
          lastName: lastName,
        ),
      FacebookCredential(:final accessToken) => _client.facebookIdp.login(
        accessToken: accessToken,
      ),
      MicrosoftCredential(
        :final code,
        :final codeVerifier,
        :final redirectUri,
        :final isWebPlatform,
      ) =>
        _client.microsoftIdp.login(
          code: code,
          codeVerifier: codeVerifier,
          redirectUri: redirectUri,
          isWebPlatform: isWebPlatform,
        ),
    };
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
