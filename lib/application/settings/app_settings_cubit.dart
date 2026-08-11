import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_settings_state.dart';

/// Owns the global UI preferences (theme mode and language).
///
/// Emits a new [AppSettingsState] so the root `MaterialApp` rebuilds with the
/// selected theme and locale. Changes are not persisted yet.
class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit() : super(const AppSettingsState());

  /// Sets the theme mode (light, dark or system).
  void setThemeMode(ThemeMode mode) {
    if (state.themeMode == mode) return;
    emit(state.copyWith(themeMode: mode));
  }

  /// Forces the given app locale.
  void setLocale(Locale locale) {
    if (state.locale == locale) return;
    emit(state.copyWith(locale: locale));
  }

  /// Returns to following the system language.
  void useSystemLocale() {
    if (state.locale == null) return;
    emit(state.copyWith(clearLocale: true));
  }
}
