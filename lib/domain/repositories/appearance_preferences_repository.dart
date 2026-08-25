import 'package:gewerber_app/domain/entities/user_preferences.dart';

/// Contract for device-local persistence of UI appearance preferences.
///
/// Unlike [UserPreferencesRepository] (server profile, per account), this
/// store keeps the last chosen appearance on the device so it applies from
/// the very first frame — including on the pre-auth screens before anyone
/// signs in.
abstract interface class AppearancePreferencesRepository {
  /// Loads the persisted theme, or `null` when none was stored.
  ThemePreference? loadTheme();

  /// Loads the persisted language, or `null` to follow the system language.
  AppLocale? loadLocale();

  /// Persists [theme]. Pass `null` to remove the stored value.
  Future<void> saveTheme(ThemePreference? theme);

  /// Persists [locale]. Pass `null` to remove the stored value
  /// (follow the system language again).
  Future<void> saveLocale(AppLocale? locale);
}
