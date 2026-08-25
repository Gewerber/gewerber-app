import 'package:shared_preferences/shared_preferences.dart';

import 'package:gewerber_app/domain/entities/user_preferences.dart';
import 'package:gewerber_app/domain/repositories/appearance_preferences_repository.dart';

/// [AppearancePreferencesRepository] backed by `shared_preferences`.
///
/// Stores plain lowercase names (`light`/`dark`/`system`, `de`/`en`/`ru`/`tr`)
/// so the values stay human-readable in the preferences file. Unknown stored
/// values are treated as "not set".
class SharedPreferencesAppearanceRepository
    implements AppearancePreferencesRepository {
  /// Creates a repository over an already-loaded [SharedPreferences]
  /// instance. `bootstrap` warms the plugin cache before DI setup so the
  /// cubit can read the persisted appearance synchronously.
  const SharedPreferencesAppearanceRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _themeKey = 'appearance.theme';
  static const _localeKey = 'appearance.locale';

  @override
  ThemePreference? loadTheme() => switch (_prefs.getString(_themeKey)) {
    'light' => ThemePreference.light,
    'dark' => ThemePreference.dark,
    'system' => ThemePreference.system,
    _ => null,
  };

  @override
  AppLocale? loadLocale() => switch (_prefs.getString(_localeKey)) {
    'de' => AppLocale.de,
    'en' => AppLocale.en,
    'ru' => AppLocale.ru,
    'tr' => AppLocale.tr,
    _ => null,
  };

  @override
  Future<void> saveTheme(ThemePreference? theme) => theme == null
      ? _prefs.remove(_themeKey)
      : _prefs.setString(_themeKey, theme.name);

  @override
  Future<void> saveLocale(AppLocale? locale) => locale == null
      ? _prefs.remove(_localeKey)
      : _prefs.setString(_localeKey, locale.name);
}
