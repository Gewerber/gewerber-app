import 'package:flutter_flavor/flutter_flavor.dart';

/// Typed, safe access to the variables of the active flavor.
///
/// The entry points (`lib/main.dart`, `lib/main_dev.dart`,
/// `lib/main_staging.dart`) set these through [FlavorConfig]. Values that are
/// absent from the flavor fall back to [fallback] (typically a `--dart-define`
/// compile-time constant).
abstract final class FlavorValues {
  /// Backend base URL of the active flavor.
  static String get serverHost => string('serverHost', '');

  /// Authentication mode of the active flavor: `live` or `mock`.
  static String get authMode => string('authMode', '');

  /// Google OAuth client id of the active flavor (web).
  static String get googleClientId => string('googleClientId', '');

  /// Apple OAuth client id / service id of the active flavor.
  static String get appleClientId => string('appleClientId', '');

  /// Facebook OAuth app id of the active flavor.
  static String get facebookAppId => string('facebookAppId', '');

  /// Connection timeout for backend calls, in milliseconds.
  static int get connectTimeoutMs => integer('connectTimeoutMs', 10 * 1000);

  /// Reads [key] from the active flavor, falling back to [fallback] when the
  /// flavor does not define it or it is not a non-empty string.
  static String string(String key, String fallback) {
    final value = FlavorConfig.instance.variables[key];
    return value is String && value.isNotEmpty ? value : fallback;
  }

  /// Reads [key] from the active flavor, falling back to [fallback] when the
  /// flavor does not define it or it is not an integer.
  static int integer(String key, int fallback) {
    final value = FlavorConfig.instance.variables[key];
    return value is int ? value : fallback;
  }
}
