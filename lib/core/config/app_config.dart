import 'package:flutter/foundation.dart';
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
    defaultValue: 'https://api.gewerber.de',
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

  /// Google OAuth client id for iOS/macOS, overridable with
  /// `--dart-define=GOOGLE_IOS_CLIENT_ID=...`.
  static const String defaultGoogleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '',
  );

  /// Apple redirect URI used by the web-based Apple flow, overridable with
  /// `--dart-define=APPLE_REDIRECT_URI=...`.
  static const String defaultAppleRedirectUri = String.fromEnvironment(
    'APPLE_REDIRECT_URI',
    defaultValue: '',
  );

  /// Microsoft (Entra ID) application (client) id, overridable with
  /// `--dart-define=MICROSOFT_CLIENT_ID=...`.
  static const String defaultMicrosoftClientId = String.fromEnvironment(
    'MICROSOFT_CLIENT_ID',
    defaultValue: '',
  );

  /// Microsoft (Entra ID) tenant, overridable with
  /// `--dart-define=MICROSOFT_TENANT=...`.
  static const String defaultMicrosoftTenant = String.fromEnvironment(
    'MICROSOFT_TENANT',
    defaultValue: 'common',
  );

  /// Explicit OAuth redirect URI for the browser-based flows, overridable
  /// with `--dart-define=AUTH_REDIRECT_URI=...`. When empty, the redirect is
  /// derived from the active server host.
  static const String defaultAuthRedirectUri = String.fromEnvironment(
    'AUTH_REDIRECT_URI',
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

  /// Google OAuth client id for iOS/macOS of the active flavor.
  static String get googleIosClientId =>
      _fromFlavor('googleIosClientId', defaultGoogleIosClientId);

  /// Apple redirect URI of the active flavor.
  static String get appleRedirectUri =>
      _fromFlavor('appleRedirectUri', defaultAppleRedirectUri);

  /// Microsoft (Entra ID) application (client) id of the active flavor.
  static String get microsoftClientId =>
      _fromFlavor('microsoftClientId', defaultMicrosoftClientId);

  /// Microsoft (Entra ID) tenant of the active flavor.
  static String get microsoftTenant =>
      _fromFlavor('microsoftTenant', defaultMicrosoftTenant);

  /// Base URL of the active flavor (see [fromFlavor]).
  static String get resolvedServerHost =>
      _fromFlavor('serverHost', defaultServerHost);

  /// OAuth redirect URI for the browser-based flows (Google web, Apple web,
  /// Microsoft).
  ///
  /// Defaults per platform and can be overridden explicitly through
  /// [defaultAuthRedirectUri]:
  ///
  /// * **web** — the app's own origin plus the `flutter_web_auth_2` callback
  ///   page (`$origin/auth.html`, shipped as `web/auth.html`). The callback
  ///   page hands the OAuth result to the app window with
  ///   `window.postMessage(..., origin)`, which browsers only deliver between
  ///   matching scheme + host + port, so the redirect *must* be same-origin.
  ///   The backend's `/auth/callback` route on `api.gewerber.de` cannot serve
  ///   that purpose for a web build served from `app.gewerber.de`.
  /// * **native** — `'$resolvedServerHost/auth/callback'`, served by the
  ///   backend (`FlutterWebAuth2CallbackRoute`). An `https` redirect on iOS /
  ///   macOS additionally needs the API host to publish
  ///   `apple-app-site-association` (Universal Links); on Android 12+ it needs
  ///   `assetlinks.json` (App Links).
  static String get authRedirectUri {
    final explicit = _fromFlavor('authRedirectUri', defaultAuthRedirectUri);
    if (explicit.isNotEmpty) {
      return explicit;
    }
    if (kIsWeb) {
      final origin = Uri.base.origin;
      return origin.isEmpty ? '/auth.html' : '$origin/auth.html';
    }
    return '$resolvedServerHost/auth/callback';
  }

  /// Builds the configuration from the active flavor, keeping the
  /// `--dart-define` defaults as fallbacks.
  factory AppConfig.fromFlavor() {
    return AppConfig(
      serverHost: resolvedServerHost,
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
