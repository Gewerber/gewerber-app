import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:gewerber_app/core/config/social_provider_availability.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/social_auth_flow.dart';

/// Result of an Apple sign-in, reduced to the fields the app needs.
class AppleSignInResult {
  const AppleSignInResult({
    required this.identityToken,
    required this.authorizationCode,
    this.givenName,
    this.familyName,
  });

  final String? identityToken;
  final String authorizationCode;
  final String? givenName;
  final String? familyName;
}

/// The subset of `sign_in_with_apple` used by [AppleSocialAuthFlow].
///
/// Injected so tests can drive the flow without the Apple SDK.
abstract interface class AppleSignInOperations {
  Future<AppleSignInResult> getAppleIDCredential({
    required bool isWeb,
    String? clientId,
    Uri? redirectUri,
  });
}

/// Sign in with Apple.
///
/// On iOS/macOS this uses the native AuthenticationServices sheet
/// ([AppleCredential.isNativeApplePlatformSignIn] is `true`); on the web it uses
/// the JavaScript SDK redirect flow, which needs the service id and a redirect
/// URI registered in the Apple developer portal. The backend receives the
/// identity token (verified against Apple's JWKS) and the authorization code.
class AppleSocialAuthFlow implements SocialAuthFlow {
  AppleSocialAuthFlow({
    required this.clientId,
    required this.redirectUri,
    AppleSignInOperations? operations,
    bool? isWeb,
    TargetPlatform? platform,
  }) : _operations = operations ?? const _SignInWithAppleOperationsImpl(),
       _isWeb = isWeb ?? kIsWeb,
       _platform = platform ?? defaultTargetPlatform;

  /// Apple service id / client id (`--dart-define=APPLE_CLIENT_ID`).
  final String clientId;

  /// Redirect URI registered for the web flow
  /// (`--dart-define=APPLE_REDIRECT_URI`).
  final String redirectUri;

  final AppleSignInOperations _operations;
  final bool _isWeb;
  final TargetPlatform _platform;

  @override
  bool get isConfigured {
    if (clientId.isEmpty) {
      return false;
    }
    if (!SocialProviderAvailability.isAvailable(
      SocialAuthProvider.apple,
      isWeb: _isWeb,
      platform: _platform,
    )) {
      return false;
    }
    // The web flow cannot complete without a redirect URI.
    return !_isWeb || redirectUri.isNotEmpty;
  }

  @override
  Future<SocialCredential> authenticate() async {
    if (!isConfigured) {
      throw const SocialAuthNotConfiguredException();
    }

    final AppleSignInResult result;
    try {
      result = await _operations.getAppleIDCredential(
        isWeb: _isWeb,
        clientId: clientId,
        redirectUri: _isWeb ? Uri.tryParse(redirectUri) : null,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw const SocialAuthCancelledException();
      }
      throw SocialAuthFailureException(error.message);
    } on SignInWithAppleNotSupportedException catch (error) {
      throw SocialAuthFailureException(error.message);
    } on AppException {
      rethrow;
    }

    final identityToken = result.identityToken;
    if (identityToken == null || identityToken.isEmpty) {
      throw const SocialAuthFailureException(
        'Apple did not return an identity token',
      );
    }
    return AppleCredential(
      identityToken: identityToken,
      authorizationCode: result.authorizationCode,
      isNativeApplePlatformSignIn: !_isWeb,
      firstName: result.givenName,
      lastName: result.familyName,
    );
  }
}

class _SignInWithAppleOperationsImpl implements AppleSignInOperations {
  const _SignInWithAppleOperationsImpl();

  @override
  Future<AppleSignInResult> getAppleIDCredential({
    required bool isWeb,
    String? clientId,
    Uri? redirectUri,
  }) async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      // Required on web (and Android); must be null on Apple platforms.
      webAuthenticationOptions: isWeb && clientId != null && redirectUri != null
          ? WebAuthenticationOptions(
              clientId: clientId,
              redirectUri: redirectUri,
            )
          : null,
    );
    return AppleSignInResult(
      identityToken: credential.identityToken,
      authorizationCode: credential.authorizationCode,
      givenName: credential.givenName,
      familyName: credential.familyName,
    );
  }
}
