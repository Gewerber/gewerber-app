import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/flavor_values.dart';

/// Application-wide configuration resolved at startup.
///
/// Values may be overridden at build/run time through `--dart-define` flags,
/// e.g. `--dart-define=SERVER_HOST=https://api.gewerber.de`. The active
/// flavor (see the entry points `lib/main.dart`, `lib/main_dev.dart`,
/// `lib/main_staging.dart`) takes precedence over those defaults.
class AppConfig {
  /// Runtime default, overridable with `--dart-define=SERVER_HOST=...`.
  static const String defaultServerHost = String.fromEnvironment(
    'SERVER_HOST',
    defaultValue: 'http://localhost:8080',
  );

  /// Google OAuth client id default, overridable with
  /// `--dart-define=GOOGLE_CLIENT_ID=...` (web).
  static const String defaultGoogleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );

  /// Apple OAuth client id / service id default, overridable with
  /// `--dart-define=APPLE_CLIENT_ID=...`.
  static const String defaultAppleClientId = String.fromEnvironment(
    'APPLE_CLIENT_ID',
    defaultValue: '',
  );

  /// Facebook OAuth app id default, overridable with
  /// `--dart-define=FACEBOOK_APP_ID=...`.
  static const String defaultFacebookAppId = String.fromEnvironment(
    'FACEBOOK_APP_ID',
    defaultValue: '',
  );

  /// Resolves a flavor variable, falling back to the `--dart-define`
  /// compile-time constant when the flavor omits it.
  static String _fromFlavor(String key, String dartDefineDefault) {
    final flavorValue = FlavorValues.string(key, '');
    return flavorValue.isNotEmpty ? flavorValue : dartDefineDefault;
  }

  /// Google OAuth client id of the active flavor (web).
  static String get googleClientId =>
      _fromFlavor('googleClientId', defaultGoogleClientId);

  /// Apple OAuth client id / service id of the active flavor.
  static String get appleClientId =>
      _fromFlavor('appleClientId', defaultAppleClientId);

  /// Facebook OAuth app id of the active flavor.
  static String get facebookAppId =>
      _fromFlavor('facebookAppId', defaultFacebookAppId);

  /// Builds the configuration from the active flavor, keeping the
  /// `--dart-define` defaults as fallbacks.
  factory AppConfig.fromFlavor() {
    return AppConfig(
      serverHost: _fromFlavor('serverHost', defaultServerHost),
      connectTimeoutMs: FlavorValues.connectTimeoutMs,
    );
  }

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
  AppConfig provideAppConfig() => AppConfig.fromFlavor();
}
