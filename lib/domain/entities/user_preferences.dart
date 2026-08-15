import 'package:equatable/equatable.dart';

/// Theme appearance preference, mirroring the server's `AppTheme` enum.
enum ThemePreference {
  system,
  light,
  dark;

  /// Builds the preference from its server-side (lowercase) name.
  static ThemePreference fromName(String name) {
    return switch (name) {
      'light' => ThemePreference.light,
      'dark' => ThemePreference.dark,
      _ => ThemePreference.system,
    };
  }
}

/// Supported app languages, mirroring the server's `Locale` enum.
enum AppLocale {
  de,
  en,
  ru,
  tr;

  static AppLocale fromName(String name) {
    return switch (name) {
      'en' => AppLocale.en,
      'ru' => AppLocale.ru,
      'tr' => AppLocale.tr,
      _ => AppLocale.de,
    };
  }
}

/// Server-synced user preferences (theme and language).
///
/// These live on the user's profile in the backend so the same settings are
/// restored on every device.
class UserPreferences extends Equatable {
  const UserPreferences({required this.locale, required this.theme});

  /// Preferred app language.
  final AppLocale locale;

  /// Preferred appearance.
  final ThemePreference theme;

  @override
  List<Object?> get props => [locale, theme];
}
