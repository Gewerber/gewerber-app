import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/pkce.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/social_auth_flow.dart';

/// The subset of `flutter_web_auth_2` used by [MicrosoftSocialAuthFlow].
///
/// Injected so tests can drive the flow without opening a browser.
abstract interface class WebAuthenticationOperations {
  /// Opens [url] and resolves with the callback URL the provider redirected to.
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    String? httpsHost,
    String? httpsPath,
  });
}

/// Microsoft (Entra ID) sign-in through the OAuth 2.0 authorization-code flow
/// with PKCE.
///
/// The app opens the Microsoft authorize endpoint in a browser (custom tab /
/// system browser / popup), Microsoft redirects back to [redirectUri] with an
/// authorization code, and the backend exchanges that code — together with the
/// [MicrosoftCredential.codeVerifier] produced here — for tokens.
///
/// Works on every Flutter platform: [MicrosoftCredential.isWebPlatform] records
/// whether the browser was the web popup or a native browser view.
class MicrosoftSocialAuthFlow implements SocialAuthFlow {
  MicrosoftSocialAuthFlow({
    required this.clientId,
    required this.redirectUri,
    this.tenant = 'common',
    WebAuthenticationOperations? operations,
    bool? isWeb,
  }) : _operations = operations ?? const _FlutterWebAuth2OperationsImpl(),
       _isWeb = isWeb ?? kIsWeb;

  /// Entra ID application (client) id (`--dart-define=MICROSOFT_CLIENT_ID`).
  final String clientId;

  /// OAuth redirect URI (`--dart-define=AUTH_REDIRECT_URI`).
  final String redirectUri;

  /// Entra ID tenant (`--dart-define=MICROSOFT_TENANT`, default `common`).
  final String tenant;

  final WebAuthenticationOperations _operations;
  final bool _isWeb;

  static const String _authorizePath = '/oauth2/v2.0/authorize';
  static const String _scope = 'openid profile email offline_access';

  @override
  bool get isConfigured => clientId.isNotEmpty && redirectUri.isNotEmpty;

  @override
  Future<SocialCredential> authenticate() async {
    if (!isConfigured) {
      throw const SocialAuthNotConfiguredException();
    }

    final codeVerifier = Pkce.generateCodeVerifier();
    final state = Pkce.generateState();
    final redirect = Uri.parse(redirectUri);
    final isHttps = redirect.scheme == 'https';

    final authorizeUrl = Uri.https(
      'login.microsoftonline.com',
      '$tenant$_authorizePath',
      {
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': redirectUri,
        'response_mode': 'query',
        'scope': _scope,
        'code_challenge': Pkce.codeChallengeS256(codeVerifier),
        'code_challenge_method': 'S256',
        'state': state,
      },
    ).toString();

    final String callbackUrl;
    try {
      callbackUrl = await _operations.authenticate(
        url: authorizeUrl,
        // A custom-scheme redirect uses the scheme as callback scheme; an https
        // redirect relies on the host/path pair below (iOS >= 17.4 / macOS
        // >= 14.4 universal links).
        callbackUrlScheme: isHttps ? 'https' : redirect.scheme,
        httpsHost: isHttps ? redirect.host : null,
        httpsPath: isHttps ? redirect.path : null,
      );
    } on PlatformException catch (error) {
      if (error.code == 'CANCELED') {
        throw const SocialAuthCancelledException();
      }
      throw SocialAuthFailureException(
        error.message ?? 'Microsoft sign-in failed',
      );
    } on AppException {
      rethrow;
    }

    final callback = Uri.parse(callbackUrl);
    final error = callback.queryParameters['error'];
    if (error != null) {
      // Microsoft returns `access_denied` when the user declines consent.
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
        'Microsoft sign-in returned an unexpected state',
      );
    }

    final code = callback.queryParameters['code'];
    if (code == null || code.isEmpty) {
      throw const SocialAuthFailureException(
        'Microsoft sign-in did not return an authorization code',
      );
    }

    return MicrosoftCredential(
      code: code,
      codeVerifier: codeVerifier,
      redirectUri: redirectUri,
      isWebPlatform: _isWeb,
    );
  }
}

class _FlutterWebAuth2OperationsImpl implements WebAuthenticationOperations {
  const _FlutterWebAuth2OperationsImpl();

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    String? httpsHost,
    String? httpsPath,
  }) {
    return FlutterWebAuth2.authenticate(
      url: url,
      callbackUrlScheme: callbackUrlScheme,
      options: FlutterWebAuth2Options(
        httpsHost: httpsHost,
        httpsPath: httpsPath,
      ),
    );
  }
}
