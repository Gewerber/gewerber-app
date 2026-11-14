import 'package:gewerber_app/core/config/app_config.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';

/// Whether a social provider has the client-side credentials this build needs.
///
/// Mirrors the "is this provider usable at all" half of the flows' own
/// `isConfigured` checks (the flows additionally require the platform-specific
/// ids, e.g. the Google iOS client id). Used by the UI to decide which buttons
/// to render; a provider without credentials would only ever fail with
/// `SocialAuthNotConfiguredException`, so it is not offered at all.
abstract final class SocialProviderConfig {
  /// Whether [provider] has its OAuth client id/app id configured.
  static bool isConfigured(SocialAuthProvider provider) {
    return switch (provider) {
      SocialAuthProvider.google => AppConfig.googleClientId.isNotEmpty,
      SocialAuthProvider.apple => AppConfig.appleClientId.isNotEmpty,
      SocialAuthProvider.facebook => AppConfig.facebookAppId.isNotEmpty,
      SocialAuthProvider.microsoft => AppConfig.microsoftClientId.isNotEmpty,
    };
  }
}
