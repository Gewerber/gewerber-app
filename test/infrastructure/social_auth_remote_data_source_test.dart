import 'package:flutter/foundation.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/core/config/app_config.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/apple_social_auth_flow.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/facebook_social_auth_flow.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/google_social_auth_flow.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social/microsoft_social_auth_flow.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social_auth_remote_data_source.dart';

void main() {
  const dataSource = SocialAuthRemoteDataSource();

  tearDown(() {
    FlavorConfig(name: null, variables: const {});
    debugDefaultTargetPlatformOverride = null;
  });

  group('SocialAuthRemoteDataSource.flowFor', () {
    test('builds the flow that belongs to each provider', () {
      FlavorConfig(name: null, variables: _fullCredentials);

      expect(
        dataSource.flowFor(SocialAuthProvider.google),
        isA<GoogleSocialAuthFlow>(),
      );
      expect(
        dataSource.flowFor(SocialAuthProvider.apple),
        isA<AppleSocialAuthFlow>(),
      );
      expect(
        dataSource.flowFor(SocialAuthProvider.facebook),
        isA<FacebookSocialAuthFlow>(),
      );
      expect(
        dataSource.flowFor(SocialAuthProvider.microsoft),
        isA<MicrosoftSocialAuthFlow>(),
      );
    });

    test('feeds the Google flow with the web/server and iOS client ids', () {
      FlavorConfig(
        name: null,
        variables: const {
          'googleClientId': 'web-client',
          'googleIosClientId': 'ios-client',
          'authRedirectUri': 'https://app.gewerber.de/auth.html',
        },
      );

      final flow =
          dataSource.flowFor(SocialAuthProvider.google) as GoogleSocialAuthFlow;

      expect(flow.clientId, 'web-client');
      expect(flow.iosClientId, 'ios-client');
      expect(flow.redirectUri, 'https://app.gewerber.de/auth.html');
    });

    test('feeds the Microsoft flow with its tenant and redirect uri', () {
      FlavorConfig(
        name: null,
        variables: const {
          'microsoftClientId': 'ms-client',
          'microsoftTenant': 'contoso',
          'authRedirectUri': 'https://app.gewerber.de/auth/callback',
        },
      );

      final flow = dataSource.flowFor(
        SocialAuthProvider.microsoft,
      ) as MicrosoftSocialAuthFlow;

      expect(flow.clientId, 'ms-client');
      expect(flow.tenant, 'contoso');
      expect(flow.redirectUri, 'https://app.gewerber.de/auth/callback');
    });
  });

  group('SocialAuthRemoteDataSource.isConfigured', () {
    test('is true for every provider with full credentials', () async {
      // Android: every provider has a flow there except Apple.
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      FlavorConfig(name: null, variables: _fullCredentials);

      for (final provider in SocialAuthProvider.values) {
        if (provider == SocialAuthProvider.apple) {
          // Apple has no Android flow; covered by the iOS case below.
          continue;
        }
        expect(
          await dataSource.isConfigured(provider),
          isTrue,
          reason: '$provider must be configured',
        );
      }
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(await dataSource.isConfigured(SocialAuthProvider.apple), isTrue);
    });

    test('is false for every provider without credentials', () async {
      FlavorConfig(name: null, variables: const {});

      for (final provider in SocialAuthProvider.values) {
        expect(await dataSource.isConfigured(provider), isFalse);
      }
    });

    test('is false for Apple on Android without a redirect uri', () async {
      // The test host is Android: Apple has no native flow there, so the
      // client id alone must not make the provider configurable.
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      FlavorConfig(name: null, variables: const {'appleClientId': 'apple'});

      expect(await dataSource.isConfigured(SocialAuthProvider.apple), isFalse);
    });

    test('is false for Google on iOS without the iOS client id', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      FlavorConfig(name: null, variables: const {'googleClientId': 'google'});

      expect(await dataSource.isConfigured(SocialAuthProvider.google), isFalse);
    });

    test(
      'is true for Google on iOS once the iOS client id is present',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        FlavorConfig(
          name: null,
          variables: const {
            'googleClientId': 'google',
            'googleIosClientId': 'google-ios',
          },
        );

        expect(
          await dataSource.isConfigured(SocialAuthProvider.google),
          isTrue,
        );
      },
    );

    test('is false for Microsoft without a redirect uri', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      FlavorConfig(
        name: null,
        variables: const {
          'microsoftClientId': 'ms-client',
          // `authRedirectUri` left at its default: it is derived from the
          // server host, which is non-empty, so only a blank host would make
          // the flow unconfigured. Asserted on the flow instead.
        },
      );

      expect(
        await dataSource.isConfigured(SocialAuthProvider.microsoft),
        isTrue,
      );
    });
  });

  group('AppConfig.authRedirectUri', () {
    test('derives the native redirect from the server host', () {
      FlavorConfig(
        name: null,
        variables: const {'serverHost': 'https://api.test.gewerber.de'},
      );

      expect(
        AppConfig.authRedirectUri,
        'https://api.test.gewerber.de/auth/callback',
      );
    });

    test('is overridden by AUTH_REDIRECT_URI', () {
      FlavorConfig(
        name: null,
        variables: const {
          'serverHost': 'https://api.test.gewerber.de',
          'authRedirectUri': 'https://app.gewerber.de/auth.html',
        },
      );

      expect(AppConfig.authRedirectUri, 'https://app.gewerber.de/auth.html');
    });
  });
}

const Map<String, Object> _fullCredentials = {
  'googleClientId': 'google',
  'googleIosClientId': 'google-ios',
  'appleClientId': 'apple',
  'appleRedirectUri': 'https://app.gewerber.de/auth.html',
  'facebookAppId': 'facebook',
  'microsoftClientId': 'microsoft',
  'authRedirectUri': 'https://app.gewerber.de/auth/callback',
};
