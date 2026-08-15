import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/settings/app_settings_state.dart';
import 'package:gewerber_app/domain/entities/user_preferences.dart';
import 'package:gewerber_app/domain/repositories/user_preferences_repository.dart';

/// Owns the global UI preferences (theme mode and language).
///
/// Emits a new [AppSettingsState] so the root `MaterialApp` rebuilds with the
/// selected theme and locale. When a [UserPreferencesRepository] is provided,
/// changes are persisted on the user's server profile and restored across
/// devices via [syncFromServer].
class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit({UserPreferencesRepository? repository})
    : _repository = repository,
      super(const AppSettingsState());

  final UserPreferencesRepository? _repository;

  /// Loads the server-side preferences and applies them to the app.
  ///
  /// Best-effort: when the profile cannot be reached, the current local
  /// settings stay in place.
  Future<void> syncFromServer() async {
    final repository = _repository;
    if (repository == null) return;
    try {
      final preferences = await repository.getMyPreferences();
      if (preferences == null || isClosed) return;
      final theme = _toThemeMode(preferences.theme);
      final locale = _toLocale(preferences.locale);
      if (theme == state.themeMode && locale == state.locale) return;
      emit(state.copyWith(themeMode: theme, locale: locale));
    } catch (_) {
      // Non-fatal: keep the current local settings.
    }
  }

  /// Sets the theme mode (light, dark or system).
  void setThemeMode(ThemeMode mode) {
    if (state.themeMode == mode) return;
    emit(state.copyWith(themeMode: mode));
    _persist();
  }

  /// Forces the given app locale.
  void setLocale(Locale locale) {
    if (state.locale == locale) return;
    emit(state.copyWith(locale: locale));
    _persist();
  }

  /// Returns to following the system language.
  void useSystemLocale() {
    if (state.locale == null) return;
    emit(state.copyWith(clearLocale: true));
    _persist();
  }

  /// Resets to the initial state (system theme, system locale).
  ///
  /// Used by tests to isolate scenarios from the shared singleton.
  void reset() {
    emit(const AppSettingsState());
  }

  /// Persists the current preferences on the server profile.
  ///
  /// The server always stores a concrete language, so following the system
  /// language resolves to the best-matching supported locale.
  void _persist() {
    final repository = _repository;
    if (repository == null) return;
    final preferences = UserPreferences(
      locale: _resolveAppLocale(state.locale),
      theme: _toAppTheme(state.themeMode),
    );
    unawaited(_persistSafely(repository, preferences));
  }

  Future<void> _persistSafely(
    UserPreferencesRepository repository,
    UserPreferences preferences,
  ) async {
    try {
      await repository.update(preferences);
    } catch (_) {
      // Best-effort: keep the local selection.
    }
  }

  Locale? _toLocale(AppLocale locale) => Locale(locale.name);

  ThemeMode _toThemeMode(ThemePreference theme) {
    return switch (theme) {
      ThemePreference.light => ThemeMode.light,
      ThemePreference.dark => ThemeMode.dark,
      ThemePreference.system => ThemeMode.system,
    };
  }

  ThemePreference _toAppTheme(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => ThemePreference.light,
      ThemeMode.dark => ThemePreference.dark,
      ThemeMode.system => ThemePreference.system,
    };
  }

  AppLocale _resolveAppLocale(Locale? locale) {
    final code =
        locale?.languageCode ?? PlatformDispatcher.instance.locale.languageCode;
    return AppLocale.values.firstWhere(
      (value) => value.name == code,
      orElse: () => AppLocale.de,
    );
  }
}
