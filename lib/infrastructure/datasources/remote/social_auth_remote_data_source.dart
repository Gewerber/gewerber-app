import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_config.dart';
import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/apple_social_auth_flow.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/facebook_social_auth_flow.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/google_social_auth_flow.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/microsoft_social_auth_flow.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/social_auth_flow.dart';

/// Performs platform sign-in through social identity providers.
///
/// Each provider is resolved to a [SocialAuthFlow] built from the
/// `--dart-define` OAuth credentials; a provider whose credentials are missing
/// (or that is unsupported on the current platform) refuses the sign-in with a
/// [SocialAuthNotConfiguredException].
///
/// The provider SDK operations are injected through the flows' seams, so this
/// datasource stays a thin dispatch layer. The server-side token exchange lives
/// in the repository (`client.<provider>Idp.login(...)`).
@LazySingleton(env: [AppEnvironment.authLive])
class SocialAuthRemoteDataSource {
  const SocialAuthRemoteDataSource();

  /// Runs the flow of [provider] and returns its credential.
  Future<SocialCredential> signIn(SocialAuthProvider provider) {
    return _flowFor(provider).authenticate();
  }

  /// Builds the flow for [provider].
  ///
  /// Visible for testing so a fake flow can be substituted.
  @visibleForTesting
  SocialAuthFlow flowFor(SocialAuthProvider provider) => _flowFor(provider);

  SocialAuthFlow _flowFor(SocialAuthProvider provider) {
    return switch (provider) {
      SocialAuthProvider.google => GoogleSocialAuthFlow(
        clientId: AppConfig.googleClientId,
        iosClientId: AppConfig.googleIosClientId,
      ),
      SocialAuthProvider.apple => AppleSocialAuthFlow(
        clientId: AppConfig.appleClientId,
        redirectUri: AppConfig.appleRedirectUri,
      ),
      SocialAuthProvider.facebook => FacebookSocialAuthFlow(
        appId: AppConfig.facebookAppId,
      ),
      SocialAuthProvider.microsoft => MicrosoftSocialAuthFlow(
        clientId: AppConfig.microsoftClientId,
        redirectUri: AppConfig.authRedirectUri,
        tenant: AppConfig.microsoftTenant,
      ),
    };
  }
}
