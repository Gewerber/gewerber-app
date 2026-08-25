import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:gewerber_app/application/settings/app_settings_state.dart';
import 'package:gewerber_app/domain/entities/user_preferences.dart';
import 'package:gewerber_app/domain/repositories/appearance_preferences_repository.dart';
import 'package:gewerber_app/domain/repositories/user_preferences_repository.dart';

/// Owns the global UI preferences (theme mode and language).
///
/// Emits a new [AppSettingsState] so the root `MaterialApp` rebuilds with the
/// selected theme and locale.
///
/// Persistence works on two levels:
/// * an optional device-local [AppearancePreferencesRepository] keeps the
///   last chosen appearance across restarts (seeded synchronously in the
///   constructor, so it applies from the first frame) and makes the choice
///   available on the pre-auth screens;
/// * when a [UserPreferencesRepository] is provided, changes are additionally
///   persisted on the user's server profile and restored across devices via
///   [syncFromServer].
class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit({this.repository, this.localStore})
    : super(localStore == null ? const AppSettingsState() : _from(localStore)) {
    if (localStore != null) _syncFormatLocale();
  }

  /// Server-side preferences store (per-account sync), when registered.
  final UserPreferencesRepository? repository;

  /// Device-local appearance store, when persistence is wired
  /// (see `bootstrap`). Seeded synchronously at construction.
  final AppearancePreferencesRepository? localStore;

  /// Builds the initial state from the device-local store.
  ///
  /// Values that fail to map (e.g. written by a newer app version) are
  /// ignored, falling back to the defaults.
  static AppSettingsState _from(AppearancePreferencesRepository store) {
    return AppSettingsState(
      themeMode: switch (store.loadTheme()) {
        null => ThemeMode.system,
        final theme => _toThemeMode(theme),
      },
      locale: store.loadLocale() == null
          ? null
          : _toLocale(store.loadLocale()!),
    );
  }

  /// Loads the server-side preferences and applies them to the app.
  ///
  /// Best-effort: when the profile cannot be reached, the current local
  /// settings stay in place. Applied values are also written through to the
  /// device-local store so the next cold start matches the profile.
  Future<void> syncFromServer() async {
    final serverRepository = repository;
    if (serverRepository == null) return;
    try {
      final preferences = await serverRepository.getMyPreferences();
      if (preferences == null || isClosed) return;
      final theme = _toThemeMode(preferences.theme);
      final locale = _toLocale(preferences.locale);
      if (theme == state.themeMode && locale == state.locale) return;
      emit(state.copyWith(themeMode: theme, locale: locale));
      _persistLocal(themeMode: theme, locale: locale);
      _syncFormatLocale();
    } catch (_) {
      // Non-fatal: keep the current local settings.
    }
  }

  /// Sets the theme mode (light, dark or system).
  void setThemeMode(ThemeMode mode) {
    if (state.themeMode == mode) return;
    emit(state.copyWith(themeMode: mode));
    _persist();
    _persistLocal(themeMode: mode);
  }

  /// Forces the given app locale.
  void setLocale(Locale locale) {
    if (state.locale == locale) return;
    emit(state.copyWith(locale: locale));
    _syncFormatLocale();
    _persist();
    _persistLocal(locale: locale);
  }

  /// Returns to following the system language.
  void useSystemLocale() {
    if (state.locale == null) return;
    emit(state.copyWith(clearLocale: true));
    _syncFormatLocale();
    _persist();
    _persistLocal(locale: null);
  }

  /// Resets to the initial state.
  ///
  /// When a device-local store is present, the persisted appearance is
  /// re-applied instead of the plain defaults — the appearance is a device
  /// preference that survives sign-out/sign-in. Without a store this falls
  /// back to system theme and system locale (also used by tests to isolate
  /// scenarios from the shared singleton).
  void reset() {
    emit(localStore == null ? const AppSettingsState() : _from(localStore!));
    _syncFormatLocale();
  }

  /// Persists the current preferences on the server profile.
  ///
  /// The server always stores a concrete language, so following the system
  /// language resolves to the best-matching supported locale.
  void _persist() {
    final serverRepository = repository;
    if (serverRepository == null) return;
    final preferences = UserPreferences(
      locale: _resolveAppLocale(state.locale),
      theme: _toAppTheme(state.themeMode),
    );
    unawaited(_persistSafely(serverRepository, preferences));
  }

  /// Writes [themeMode]/[locale] through to the device-local store.
  ///
  /// Only the given dimension is touched; `null` values mean "remove"
  /// (follow the system). Best-effort: failures keep the local selection.
  void _persistLocal({ThemeMode? themeMode, Locale? locale}) {
    final store = localStore;
    if (store == null) return;
    try {
      if (themeMode != null) {
        unawaited(store.saveTheme(_toAppTheme(themeMode)));
      }
      unawaited(
        store.saveLocale(locale == null ? null : _resolveAppLocale(locale)),
      );
    } catch (_) {
      // Best-effort: keep the local selection.
    }
  }

  /// Keeps `package:intl` formatters (currency, dates) aligned with the
  /// active app language.
  void _syncFormatLocale() {
    final locale = state.locale?.toLanguageTag();
    Intl.defaultLocale =
        locale ?? PlatformDispatcher.instance.locale.toString();
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

  static Locale _toLocale(AppLocale locale) => Locale(locale.name);

  static ThemeMode _toThemeMode(ThemePreference theme) {
    return switch (theme) {
      ThemePreference.light => ThemeMode.light,
      ThemePreference.dark => ThemeMode.dark,
      ThemePreference.system => ThemeMode.system,
    };
  }

  static ThemePreference _toAppTheme(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => ThemePreference.light,
      ThemeMode.dark => ThemePreference.dark,
      ThemeMode.system => ThemePreference.system,
    };
  }

  static AppLocale _resolveAppLocale(Locale? locale) {
    final code =
        locale?.languageCode ?? PlatformDispatcher.instance.locale.languageCode;
    return AppLocale.values.firstWhere(
      (value) => value.name == code,
      orElse: () => AppLocale.de,
    );
  }
}
