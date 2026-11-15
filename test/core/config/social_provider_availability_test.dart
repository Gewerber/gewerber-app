import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/core/config/social_provider_availability.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';

void main() {
  group('SocialProviderAvailability.isAvailable', () {
    test('google is available on web, Android, iOS and macOS', () {
      expect(_available(SocialAuthProvider.google, isWeb: true), isTrue);
      expect(
        _available(SocialAuthProvider.google, platform: TargetPlatform.android),
        isTrue,
      );
      expect(
        _available(SocialAuthProvider.google, platform: TargetPlatform.iOS),
        isTrue,
      );
      expect(
        _available(SocialAuthProvider.google, platform: TargetPlatform.macOS),
        isTrue,
      );
    });

    test('google is unavailable on Windows, Linux and Fuchsia', () {
      expect(
        _available(SocialAuthProvider.google, platform: TargetPlatform.windows),
        isFalse,
      );
      expect(
        _available(SocialAuthProvider.google, platform: TargetPlatform.linux),
        isFalse,
      );
      expect(
        _available(SocialAuthProvider.google, platform: TargetPlatform.fuchsia),
        isFalse,
      );
    });

    test('apple is available on web, iOS and macOS', () {
      expect(_available(SocialAuthProvider.apple, isWeb: true), isTrue);
      expect(
        _available(SocialAuthProvider.apple, platform: TargetPlatform.iOS),
        isTrue,
      );
      expect(
        _available(SocialAuthProvider.apple, platform: TargetPlatform.macOS),
        isTrue,
      );
    });

    test('apple is unavailable on Android, Windows and Linux', () {
      expect(
        _available(SocialAuthProvider.apple, platform: TargetPlatform.android),
        isFalse,
      );
      expect(
        _available(SocialAuthProvider.apple, platform: TargetPlatform.windows),
        isFalse,
      );
      expect(
        _available(SocialAuthProvider.apple, platform: TargetPlatform.linux),
        isFalse,
      );
    });

    test('facebook is available on web, Android and iOS', () {
      expect(_available(SocialAuthProvider.facebook, isWeb: true), isTrue);
      expect(
        _available(
          SocialAuthProvider.facebook,
          platform: TargetPlatform.android,
        ),
        isTrue,
      );
      expect(
        _available(SocialAuthProvider.facebook, platform: TargetPlatform.iOS),
        isTrue,
      );
    });

    test('facebook is unavailable on macOS, Windows and Linux', () {
      expect(
        _available(SocialAuthProvider.facebook, platform: TargetPlatform.macOS),
        isFalse,
      );
      expect(
        _available(
          SocialAuthProvider.facebook,
          platform: TargetPlatform.windows,
        ),
        isFalse,
      );
      expect(
        _available(SocialAuthProvider.facebook, platform: TargetPlatform.linux),
        isFalse,
      );
    });

    test('microsoft is available everywhere', () {
      for (final providerPlatform in TargetPlatform.values) {
        expect(
          _available(SocialAuthProvider.microsoft, platform: providerPlatform),
          isTrue,
          reason: 'microsoft must be available on $providerPlatform',
        );
      }
      expect(_available(SocialAuthProvider.microsoft, isWeb: true), isTrue);
    });
  });

  group('SocialProviderAvailability.isAvailableNow', () {
    test('matches the static matrix for the current platform', () {
      for (final provider in SocialAuthProvider.values) {
        expect(
          SocialProviderAvailability.isAvailableNow(provider),
          SocialProviderAvailability.isAvailable(
            provider,
            isWeb: kIsWeb,
            platform: defaultTargetPlatform,
          ),
          reason: 'mismatch for $provider',
        );
      }
    });
  });
}

bool _available(
  SocialAuthProvider provider, {
  bool isWeb = false,
  TargetPlatform platform = TargetPlatform.android,
}) {
  return SocialProviderAvailability.isAvailable(
    provider,
    isWeb: isWeb,
    platform: platform,
  );
}
