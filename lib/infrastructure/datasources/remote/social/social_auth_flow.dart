import 'package:gewerber_app/core/errors/exceptions.dart';

/// A credential obtained from a social identity provider.
///
/// The variants mirror the payload of the corresponding generated backend
/// endpoint (`client.googleIdp`, `client.appleIdp`, `client.facebookIdp`,
/// `client.microsoftIdp`) so the repository can forward them without a second
/// translation step.
sealed class SocialCredential {
  const SocialCredential();
}

/// Google credential from the native SDK: the ID token is validated by the
/// backend, the access token is optional (only present on some platforms).
final class GoogleCredential extends SocialCredential {
  const GoogleCredential({required this.idToken, this.accessToken});

  final String idToken;
  final String? accessToken;
}

/// Google credential from the web OAuth 2.0 authorization-code flow with PKCE.
///
/// The backend holds the client secret, so it — not the app — exchanges
/// [code] for tokens (`client.googleIdp.loginWithCode`). [redirectUri] is the
/// same-origin callback page the code was issued for and must match the one
/// sent in the authorize request.
final class GoogleCodeCredential extends SocialCredential {
  const GoogleCodeCredential({
    required this.code,
    required this.codeVerifier,
    required this.redirectUri,
  });

  final String code;
  final String codeVerifier;
  final String redirectUri;
}

/// Apple credential. [isNativeApplePlatformSignIn] distinguishes the native
/// AuthenticationServices flow (iOS/macOS) from the browser redirect flow.
final class AppleCredential extends SocialCredential {
  const AppleCredential({
    required this.identityToken,
    required this.authorizationCode,
    required this.isNativeApplePlatformSignIn,
    this.firstName,
    this.lastName,
  });

  final String identityToken;
  final String authorizationCode;
  final bool isNativeApplePlatformSignIn;
  final String? firstName;
  final String? lastName;
}

/// Facebook credential: a short-lived user access token.
final class FacebookCredential extends SocialCredential {
  const FacebookCredential({required this.accessToken});

  final String accessToken;
}

/// Microsoft (Entra ID) credential: an authorization code plus the PKCE
/// verifier it was issued for.
final class MicrosoftCredential extends SocialCredential {
  const MicrosoftCredential({
    required this.code,
    required this.codeVerifier,
    required this.redirectUri,
    required this.isWebPlatform,
  });

  final String code;
  final String codeVerifier;
  final String redirectUri;
  final bool isWebPlatform;
}

/// A single provider sign-in flow.
///
/// Implementations are constructed with their SDK operations injected, so tests
/// can exercise the credential mapping and the error mapping without touching
/// a real provider SDK.
///
/// [isConfigured] is the single source of truth for "can this provider run in
/// this build": the UI asks [SocialAuthRemoteDataSource.isConfigured] rather
/// than re-deriving the same rules from the configuration alone.
abstract interface class SocialAuthFlow {
  /// Whether the provider has the credentials it needs for this build.
  ///
  /// A `false` value makes [authenticate] throw
  /// [SocialAuthNotConfiguredException].
  bool get isConfigured;

  /// Runs the provider sign-in and returns its credential.
  ///
  /// Throws [SocialAuthNotConfiguredException] when the provider is not
  /// configured for this build or platform, [SocialAuthCancelledException] when
  /// the user dismissed the provider UI, and [SocialAuthFailureException] for
  /// every other provider error.
  Future<SocialCredential> authenticate();
}
