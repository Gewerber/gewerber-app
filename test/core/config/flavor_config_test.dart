import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/core/config/app_config.dart';
import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/config/flavor_values.dart';

void main() {
  group('FlavorValues', () {
    // FlavorConfig is a global singleton; reset it between tests so the
    // assertions below see a clean state.
    tearDown(() {
      FlavorConfig(name: null, variables: const {});
    });

    test('reads variables from the active flavor', () {
      FlavorConfig(
        name: 'DEV',
        variables: const {
          'serverHost': 'http://localhost:8080',
          'authMode': 'mock',
          'connectTimeoutMs': 5000,
        },
      );

      expect(FlavorValues.serverHost, 'http://localhost:8080');
      expect(FlavorValues.authMode, 'mock');
      expect(FlavorValues.connectTimeoutMs, 5000);
    });

    test('falls back when a variable is absent', () {
      FlavorConfig(name: null);

      expect(FlavorValues.serverHost, '');
      expect(FlavorValues.authMode, '');
      expect(FlavorValues.connectTimeoutMs, 10 * 1000);
      expect(FlavorValues.string('missing', 'fallback'), 'fallback');
    });

    test('ignores variables with an unexpected type', () {
      FlavorConfig(
        variables: const {'serverHost': 42, 'connectTimeoutMs': 'nope'},
      );

      expect(FlavorValues.serverHost, '');
      expect(FlavorValues.connectTimeoutMs, 10 * 1000);
    });
  });

  group('AppEnvironment', () {
    tearDown(() {
      FlavorConfig(name: null, variables: const {});
    });

    test('falls back to the build mode when no flavor auth mode is set', () {
      // Widget tests run in debug mode -> mock authentication.
      expect(AppEnvironment.authEnvironment, AppEnvironment.authMock);
    });

    test('prefers the flavor auth mode', () {
      FlavorConfig(variables: const {'authMode': 'live'});
      expect(AppEnvironment.authEnvironment, AppEnvironment.authLive);

      FlavorConfig(variables: const {'authMode': 'mock'});
      expect(AppEnvironment.authEnvironment, AppEnvironment.authMock);
    });
  });

  group('AppConfig.fromFlavor', () {
    tearDown(() {
      FlavorConfig(name: null, variables: const {});
    });

    test('takes the server host from the flavor', () {
      FlavorConfig(variables: const {'serverHost': 'https://api.test.example'});

      final config = AppConfig.fromFlavor();
      expect(config.serverHost, 'https://api.test.example');
    });

    test('falls back to the --dart-define default when unset', () {
      final config = AppConfig.fromFlavor();
      expect(config.serverHost, AppConfig.defaultServerHost);
    });

    test('resolves OAuth ids from the flavor with dart-define fallback', () {
      FlavorConfig(
        variables: const {
          'googleClientId': 'flavor-google',
          'appleClientId': '',
        },
      );

      expect(AppConfig.googleClientId, 'flavor-google');
      expect(AppConfig.appleClientId, AppConfig.defaultAppleClientId);
    });
  });
}
