import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:gewerber_app/core/config/social_provider_availability.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/social_auth_flow.dart';

/// The subset of `flutter_facebook_auth` used by [FacebookSocialAuthFlow].
///
/// Injected so tests can drive the flow without the Facebook SDK. [login]
/// returns the SDK's [LoginResult] so the flow owns the status → credential /
/// cancellation mapping.
abstract interface class FacebookAuthOperations {
  /// Initialises the Facebook JavaScript SDK (web only).
  Future<void> webAndDesktopInitialize({
    required String appId,
    required bool cookie,
    required bool xfbml,
    required String version,
  });

  Future<LoginResult> login({
    required bool isWeb,
    required LoginTracking tracking,
  });
}

/// Facebook login through `flutter_facebook_auth`.
///
/// The web build initialises the JavaScript SDK first and then opens the login
/// dialog; mobile uses the native SDK. Only the access token is forwarded — the
/// backend exchanges it for the user's profile and email via the Graph API.
class FacebookSocialAuthFlow implements SocialAuthFlow {
  FacebookSocialAuthFlow({
    required this.appId,
    FacebookAuthOperations? operations,
    bool? isWeb,
    TargetPlatform? platform,
  }) : _operations = operations ?? const _FacebookAuthOperationsImpl(),
       _isWeb = isWeb ?? kIsWeb,
       _platform = platform ?? defaultTargetPlatform;

  /// Facebook app id (`--dart-define=FACEBOOK_APP_ID`).
  final String appId;

  final FacebookAuthOperations _operations;
  final bool _isWeb;
  final TargetPlatform _platform;

  @override
  bool get isConfigured {
    if (appId.isEmpty) {
      return false;
    }
    return SocialProviderAvailability.isAvailable(
      SocialAuthProvider.facebook,
      isWeb: _isWeb,
      platform: _platform,
    );
  }

  @override
  Future<SocialCredential> authenticate() async {
    if (!isConfigured) {
      throw const SocialAuthNotConfiguredException();
    }

    try {
      if (_isWeb) {
        await _operations.webAndDesktopInitialize(
          appId: appId,
          cookie: true,
          xfbml: true,
          version: _webSdkVersion,
        );
      }
      final result = await _operations.login(
        isWeb: _isWeb,
        tracking: LoginTracking.enabled,
      );
      return _map(result);
    } on AppException {
      rethrow;
    }
  }

  /// Facebook Graph API version used by the web SDK.
  ///
  /// Pinned to a currently served version: Graph API v21.0 is scheduled for
  /// removal on 2027-01-21.
  static const String _webSdkVersion = 'v27.0';

  FacebookCredential _map(LoginResult result) {
    if (result.status == LoginStatus.cancelled) {
      throw const SocialAuthCancelledException();
    }
    final token = result.accessToken?.tokenString;
    if (result.status != LoginStatus.success ||
        token == null ||
        token.isEmpty) {
      throw SocialAuthFailureException(
        result.message ?? 'Facebook login failed',
      );
    }
    return FacebookCredential(accessToken: token);
  }
}

class _FacebookAuthOperationsImpl implements FacebookAuthOperations {
  const _FacebookAuthOperationsImpl();

  @override
  Future<void> webAndDesktopInitialize({
    required String appId,
    required bool cookie,
    required bool xfbml,
    required String version,
  }) {
    return FacebookAuth.instance.webAndDesktopInitialize(
      appId: appId,
      cookie: cookie,
      xfbml: xfbml,
      version: version,
    );
  }

  @override
  Future<LoginResult> login({
    required bool isWeb,
    required LoginTracking tracking,
  }) async {
    try {
      return await FacebookAuth.instance.login(
        permissions: const ['email', 'public_profile'],
        // `limited` (the SDK default) issues a token the backend cannot verify:
        // it validates with `/debug_token` using `app_id|app_secret`, which
        // only succeeds for `enabled` (classic) logins.
        loginTracking: tracking,
      );
    } on PlatformException catch (error) {
      // The platform channel reports a user cancellation as CANCELLED
      // (`OperationCancelled` on the native SDKs).
      if (error.code == 'CANCELLED') {
        throw const SocialAuthCancelledException();
      }
      throw SocialAuthFailureException(
        error.message ?? 'Facebook login failed',
      );
    }
  }
}
