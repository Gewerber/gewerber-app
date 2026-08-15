import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_config.dart';
import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';

/// Performs platform sign-in through social identity providers.
///
/// The provider SDKs need OAuth credentials (Google client id, Apple service
/// id, Facebook app id). Those are passed with `--dart-define` at build time;
/// until a provider is configured this datasource refuses the sign-in with a
/// [SocialAuthNotConfiguredException]. The platform-specific flows are added
/// here once the credentials exist.
@LazySingleton(env: [AppEnvironment.authLive])
class SocialAuthRemoteDataSource {
  const SocialAuthRemoteDataSource();

  /// Ensures the provider is configured, then signs the user in.
  ///
  /// Returns the provider's credential (id token / access token) which is
  /// exchanged server-side via the corresponding identity provider endpoint.
  Future<String> signIn(SocialAuthProvider provider) async {
    _assertConfigured(provider);
    // TODO(gewerber): perform the provider flow (google_sign_in / sign_in_with_apple
    // / facebook_auth_desktop) and return the credential. The token exchange
    // goes through client.modules.serverpod_auth_idp.<provider>.login(...).
    throw const SocialAuthNotConfiguredException();
  }

  void _assertConfigured(SocialAuthProvider provider) {
    final isConfigured = switch (provider) {
      SocialAuthProvider.google => AppConfig.googleClientId.isNotEmpty,
      SocialAuthProvider.apple => AppConfig.appleClientId.isNotEmpty,
      SocialAuthProvider.facebook => AppConfig.facebookAppId.isNotEmpty,
    };
    if (!isConfigured) {
      throw const SocialAuthNotConfiguredException();
    }
  }
}
