import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:gewerber_app/core/config/social_provider_availability.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/pkce.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/social_auth_flow.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/web_authentication_operations.dart';

/// Result of a Google sign-in, reduced to the fields the app needs.
class GoogleSignInResult {
  const GoogleSignInResult({required this.idToken, this.accessToken});

  final String idToken;
  final String? accessToken;
}

/// The subset of `google_sign_in` used by the native branch of
/// [GoogleSocialAuthFlow].
///
/// Injected so tests can drive the flow without a platform channel. Only ever
/// used off the web: `google_sign_in_web` does not implement `authenticate()`.
abstract interface class GoogleSignInOperations {
  Future<void> initialize({String? clientId, String? serverClientId});

  Future<GoogleSignInResult> authenticate();
}

/// Google sign-in.
///
/// Two transports, picked by platform:
///
/// * **Web** — the OAuth 2.0 authorization-code flow with PKCE against
///   `accounts.google.com`, opened by `flutter_web_auth_2`. `google_sign_in`'s
///   `authenticate()` is not implemented on the web (it needs the rendered GIS
///   button), so the web build runs the redirect flow itself and hands the
///   authorization code to the backend, which exchanges it for tokens
///   (`client.googleIdp.loginWithCode`).
/// * **Native (Android, iOS, macOS)** — `google_sign_in`, whose ID token is
///   validated by the backend (`client.googleIdp.login`).
///
/// Both branches need the *web/server* client id (`GOOGLE_CLIENT_ID`): it is
/// the ID-token audience the backend validates and the OAuth client for the web
/// code exchange. iOS/macOS additionally need the platform client id
/// (`GOOGLE_IOS_CLIENT_ID`) because the native SDK signs in with it. Windows and
/// Linux have no Google flow at all (see [SocialProviderAvailability]) and
/// therefore need neither.
class GoogleSocialAuthFlow implements SocialAuthFlow {
  GoogleSocialAuthFlow({
    required this.clientId,
    required this.iosClientId,
    this.redirectUri = '',
    GoogleSignInOperations? operations,
    WebAuthenticationOperations? webOperations,
    bool? isWeb,
    TargetPlatform? platform,
  }) : _operations = operations ?? _GoogleSignInOperationsImpl(),
       _webOperations = webOperations ?? const FlutterWebAuth2Operations(),
       _isWeb = isWeb ?? kIsWeb,
       _platform = platform ?? defaultTargetPlatform;

  /// The web / server OAuth client id (`--dart-define=GOOGLE_CLIENT_ID`).
  final String clientId;

  /// The iOS/macOS OAuth client id (`--dart-define=GOOGLE_IOS_CLIENT_ID`).
  final String iosClientId;

  /// Same-origin callback page of the web build
  /// (`--dart-define=AUTH_REDIRECT_URI`, defaults to
  /// `Uri.base.origin + '/auth.html'` on the web). Unused on native.
  final String redirectUri;

  final GoogleSignInOperations _operations;
  final WebAuthenticationOperations _webOperations;
  final bool _isWeb;
  final TargetPlatform _platform;

  static const String _authorizeOrigin = 'accounts.google.com';
  static const String _authorizePath = '/o/oauth2/v2/auth';
  static const String _scope = 'openid email profile';

  bool get _isApplePlatform =>
      _platform == TargetPlatform.iOS || _platform == TargetPlatform.macOS;

  @override
  bool get isConfigured {
    if (!SocialProviderAvailability.isAvailable(
      SocialAuthProvider.google,
      isWeb: _isWeb,
      platform: _platform,
    )) {
      return false;
    }
    if (clientId.isEmpty) {
      return false;
    }
    if (_isWeb) {
      // The web flow needs the same-origin callback page.
      return redirectUri.isNotEmpty;
    }
    // iOS/macOS additionally need the platform client id because the SDK
    // signs in with it; Android only needs the server client id.
    return !_isApplePlatform || iosClientId.isNotEmpty;
  }

  @override
  Future<SocialCredential> authenticate() async {
    if (!isConfigured) {
      throw const SocialAuthNotConfiguredException();
    }
    return _isWeb ? _authenticateOnWeb() : _authenticateOnNative();
  }

  /// OAuth 2.0 authorization-code flow with PKCE, driven by
  /// `flutter_web_auth_2`.
  ///
  /// The backend performs the code-for-token exchange (it holds the client
  /// secret), so only the code, its verifier and the redirect URI travel back.
  Future<SocialCredential> _authenticateOnWeb() async {
    final codeVerifier = Pkce.generateCodeVerifier();
    final state = Pkce.generateState();
    final redirect = Uri.parse(redirectUri);

    final authorizeUrl = Uri.https(_authorizeOrigin, _authorizePath, {
      'client_id': clientId,
      'response_type': 'code',
      'redirect_uri': redirectUri,
      'response_mode': 'query',
      'scope': _scope,
      'code_challenge': Pkce.codeChallengeS256(codeVerifier),
      'code_challenge_method': 'S256',
      'state': state,
      'access_type': 'offline',
    }).toString();

    final String callbackUrl;
    try {
      callbackUrl = await _webOperations.authenticate(
        url: authorizeUrl,
        // `flutter_web_auth_2` matches the callback by origin on the web; the
        // scheme/host pair is what the native https redirect would need.
        callbackUrlScheme: 'https',
        httpsHost: redirect.host,
        httpsPath: redirect.path,
      );
    } on PlatformException catch (error) {
      if (error.code == 'CANCELED') {
        throw const SocialAuthCancelledException();
      }
      throw SocialAuthFailureException(
        error.message ?? 'Google sign-in failed',
      );
    } on AppException {
      rethrow;
    }

    final callback = Uri.parse(callbackUrl);
    final error = callback.queryParameters['error'];
    if (error != null) {
      // Google answers `access_denied` when the user declines consent.
      if (error == 'access_denied') {
        throw const SocialAuthCancelledException();
      }
      throw SocialAuthFailureException(
        callback.queryParameters['error_description'] ?? error,
      );
    }

    // CSRF protection: the state we sent must come back unchanged.
    if (callback.queryParameters['state'] != state) {
      throw const SocialAuthFailureException(
        'Google sign-in returned an unexpected state',
      );
    }

    final code = callback.queryParameters['code'];
    if (code == null || code.isEmpty) {
      throw const SocialAuthFailureException(
        'Google sign-in did not return an authorization code',
      );
    }

    return GoogleCodeCredential(
      code: code,
      codeVerifier: codeVerifier,
      redirectUri: redirectUri,
    );
  }

  Future<SocialCredential> _authenticateOnNative() async {
    try {
      if (_isApplePlatform) {
        await _operations.initialize(
          clientId: iosClientId,
          serverClientId: clientId,
        );
      } else {
        await _operations.initialize(serverClientId: clientId);
      }

      final result = await _operations.authenticate();
      if (result.idToken.isEmpty) {
        throw const SocialAuthFailureException(
          'Google did not return an ID token',
        );
      }
      return GoogleCredential(
        idToken: result.idToken,
        accessToken: result.accessToken,
      );
    } on AppException {
      rethrow;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const SocialAuthCancelledException();
      }
      throw SocialAuthFailureException(
        error.description ?? 'Google sign-in failed',
      );
    }
  }
}

class _GoogleSignInOperationsImpl implements GoogleSignInOperations {
  /// `GoogleSignIn.initialize` may only be called once per app run; the
  /// plugin throws a [StateError] on a second call.
  static bool _initialized = false;

  @override
  Future<void> initialize({String? clientId, String? serverClientId}) async {
    if (_initialized) {
      return;
    }
    await GoogleSignIn.instance.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );
    _initialized = true;
  }

  @override
  Future<GoogleSignInResult> authenticate() async {
    final account = await GoogleSignIn.instance.authenticate();
    return GoogleSignInResult(
      idToken: account.authentication.idToken ?? '',
      accessToken: null,
    );
  }
}
