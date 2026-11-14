import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:gewerber_app/core/config/social_provider_availability.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/social_auth_flow.dart';

/// Result of a Google sign-in, reduced to the fields the app needs.
class GoogleSignInResult {
  const GoogleSignInResult({required this.idToken, this.accessToken});

  final String idToken;
  final String? accessToken;
}

/// The subset of `google_sign_in` used by [GoogleSocialAuthFlow].
///
/// Injected so tests can drive the flow without a platform channel.
abstract interface class GoogleSignInOperations {
  Future<void> initialize({String? clientId, String? serverClientId});

  Future<GoogleSignInResult> authenticate();
}

/// Google sign-in through `google_sign_in` 7.
///
/// The ID token is exchanged server-side by `client.googleIdp.login`, so the
/// backend needs the *server* client id (`googleClientId`) as the token
/// audience. On iOS/macOS the SDK additionally needs the platform client id
/// (`googleIosClientId`); on Android the server client id is enough; on web
/// the SDK only accepts the web client id.
///
/// Phase-1 limitation: `google_sign_in` 7 does not implement `authenticate()` on
/// the web (it requires the rendered GIS button), and no hand-rolled desktop
/// PKCE flow is provided for Windows/Linux. Those platforms therefore fail with
/// [SocialAuthFailureException] instead of silently pretending to work.
class GoogleSocialAuthFlow implements SocialAuthFlow {
  GoogleSocialAuthFlow({
    required this.clientId,
    required this.iosClientId,
    GoogleSignInOperations? operations,
    bool? isWeb,
    TargetPlatform? platform,
  }) : _operations = operations ?? _GoogleSignInOperationsImpl(),
       _isWeb = isWeb ?? kIsWeb,
       _platform = platform ?? defaultTargetPlatform;

  /// The web / server OAuth client id (`--dart-define=GOOGLE_CLIENT_ID`).
  final String clientId;

  /// The iOS/macOS OAuth client id (`--dart-define=GOOGLE_IOS_CLIENT_ID`).
  final String iosClientId;

  final GoogleSignInOperations _operations;
  final bool _isWeb;
  final TargetPlatform _platform;

  @override
  bool get isConfigured {
    if (!SocialProviderAvailability.isAvailable(
      SocialAuthProvider.google,
      isWeb: _isWeb,
      platform: _platform,
    )) {
      return false;
    }
    if (_isWeb || _isApplePlatform) {
      // Web needs the web client id; iOS/macOS additionally need the platform
      // client id because the SDK signs in with it.
      return clientId.isNotEmpty &&
          (!_isApplePlatform || iosClientId.isNotEmpty);
    }
    return clientId.isNotEmpty;
  }

  bool get _isApplePlatform =>
      _platform == TargetPlatform.iOS || _platform == TargetPlatform.macOS;

  @override
  Future<SocialCredential> authenticate() async {
    if (!isConfigured) {
      throw const SocialAuthNotConfiguredException();
    }
    try {
      if (_isWeb) {
        // google_sign_in_web rejects `serverClientId` and requires the web
        // client id as `clientId`.
        await _operations.initialize(clientId: clientId);
      } else if (_isApplePlatform) {
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
    } on UnimplementedError catch (error) {
      // `authenticate()` is not implemented on web (GIS button required).
      throw SocialAuthFailureException(
        'Google sign-in is not supported on this platform: '
        '${error.message ?? 'unimplemented'}',
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
