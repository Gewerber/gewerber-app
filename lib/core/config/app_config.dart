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
