import 'package:flutter/foundation.dart';

import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';

/// Platform support matrix of the social sign-in providers.
///
/// Phase 1 deliberately does not ship a desktop PKCE flow for Google, so
/// Windows/Linux (and Fuchsia) are unsupported there. Apple is unavailable on
/// Android and on the non-Apple desktop platforms because the native
/// AuthenticationServices flow only exists on Apple platforms and the web
/// redirect flow is only wired up for the browser.
///
/// This is the *platform* half of the "can this provider run here" answer; the
/// flows add their credential requirements on top and are the single source of
/// truth (see `SocialAuthRemoteDataSource.isConfigured`, which the UI asks).
abstract final class SocialProviderAvailability {
  /// Whether [provider] can be used on [platform] (or on the web when
  /// [isWeb] is true).
  static bool isAvailable(
    SocialAuthProvider provider, {
    required bool isWeb,
    required TargetPlatform platform,
  }) {
    return switch (provider) {
      SocialAuthProvider.google => isWeb || _googlePlatforms.contains(platform),
      SocialAuthProvider.apple => isWeb || _applePlatforms.contains(platform),
      SocialAuthProvider.facebook =>
        isWeb || _facebookPlatforms.contains(platform),
      // Microsoft uses flutter_web_auth_2, which supports every Flutter
      // platform (browser, mobile and desktop).
      SocialAuthProvider.microsoft => true,
    };
  }

  /// Convenience wrapper around [isAvailable] using [kIsWeb] and
  /// [defaultTargetPlatform] of the current build.
  static bool isAvailableNow(SocialAuthProvider provider) {
    return isAvailable(
      provider,
      isWeb: kIsWeb,
      platform: defaultTargetPlatform,
    );
  }

  static const Set<TargetPlatform> _googlePlatforms = {
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  };

  static const Set<TargetPlatform> _applePlatforms = {
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  };

  static const Set<TargetPlatform> _facebookPlatforms = {
    TargetPlatform.android,
    TargetPlatform.iOS,
  };
}
