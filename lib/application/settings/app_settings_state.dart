import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Global UI preferences: theme and language.
///
/// Not persisted yet; [locale] stays `null` to follow the system language
/// until the user explicitly picks one.
class AppSettingsState extends Equatable {
  const AppSettingsState({this.themeMode = ThemeMode.system, this.locale});

  /// Selected theme. Defaults to [ThemeMode.system].
  final ThemeMode themeMode;

  /// Forced app locale, or `null` to follow the system language.
  final Locale? locale;

  bool get isSystemTheme => themeMode == ThemeMode.system;
  bool get isLightTheme => themeMode == ThemeMode.light;
  bool get isDarkTheme => themeMode == ThemeMode.dark;

  /// Whether [locale] (or the system locale when null) is the active one.
  bool isActiveLocale(Locale? locale) => this.locale == locale;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool clearLocale = false,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: clearLocale ? null : (locale ?? this.locale),
    );
  }

  @override
  List<Object?> get props => [themeMode, locale];
}
