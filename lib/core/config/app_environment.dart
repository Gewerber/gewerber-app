import 'package:flutter/foundation.dart';

import 'package:gewerber_app/core/config/flavor_values.dart';

/// Injectable environments used to select the authentication backend.
///
/// The live environment talks to the Serverpod backend; the mock environment
/// backs the demo experience and the widget test suite.
abstract final class AppEnvironment {
  /// Live Serverpod-backed authentication.
  static const String authLive = 'auth_live';

  /// In-memory mock authentication (demo mode, widget tests).
  static const String authMock = 'auth_mock';

  /// Optional compile-time override, `--dart-define=AUTH_MODE=live|mock`.
  static const String _authModeOverride = String.fromEnvironment(
    'AUTH_MODE',
    defaultValue: '',
  );

  /// Resolves the default authentication environment.
  ///
  /// Precedence: an explicit `--dart-define=AUTH_MODE=...` wins, then the
  /// active flavor's `authMode` variable (set by the entry point), then the
  /// build mode — release builds use the live backend while debug builds and
  /// widget tests keep the mock repository (no network, deterministic).
  static String get authEnvironment {
    if (_authModeOverride == 'live') return authLive;
    if (_authModeOverride == 'mock') return authMock;
    return switch (FlavorValues.authMode) {
      'live' => authLive,
      'mock' => authMock,
      _ => kReleaseMode ? authLive : authMock,
    };
  }
}
