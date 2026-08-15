import 'package:flutter/foundation.dart';

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
  /// An explicit `--dart-define=AUTH_MODE=...` wins. Without it, release
  /// builds use the live backend while debug builds and widget tests keep
  /// the mock repository (no network, deterministic).
  static String get authEnvironment {
    return switch (_authModeOverride) {
      'live' => authLive,
      'mock' => authMock,
      _ => kReleaseMode ? authLive : authMock,
    };
  }
}
