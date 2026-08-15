import 'package:injectable/injectable.dart';

/// Application-wide configuration resolved at startup.
///
/// Values may be overridden at build/run time through `--dart-define` flags,
/// e.g. `--dart-define=SERVER_HOST=https://api.gewerber.de`.
class AppConfig {
  /// Runtime default, overridable with `--dart-define=SERVER_HOST=...`.
  static const String defaultServerHost = String.fromEnvironment(
    'SERVER_HOST',
    defaultValue: 'http://localhost:8080',
  );

  /// Google OAuth client id, overridable with
  /// `--dart-define=GOOGLE_CLIENT_ID=...` (web).
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );

  /// Apple OAuth client id / service id, overridable with
  /// `--dart-define=APPLE_CLIENT_ID=...`.
  static const String appleClientId = String.fromEnvironment(
    'APPLE_CLIENT_ID',
    defaultValue: '',
  );

  /// Facebook OAuth app id, overridable with
  /// `--dart-define=FACEBOOK_APP_ID=...`.
  static const String facebookAppId = String.fromEnvironment(
    'FACEBOOK_APP_ID',
    defaultValue: '',
  );

  const AppConfig({
    this.serverHost = defaultServerHost,
    this.connectTimeoutMs = 10 * 1000,
  });

  /// Base URL of the Gewerber backend.
  final String serverHost;

  /// Connection timeout for backend calls, in milliseconds.
  final int connectTimeoutMs;
}

/// Registers the singleton [AppConfig] in DI.
@module
abstract class AppConfigModule {
  @singleton
  AppConfig provideAppConfig() => const AppConfig();
}
