import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/settings/app_settings_cubit.dart';

void main() {
  test('starts with system theme and no forced locale', () {
    final cubit = AppSettingsCubit();

    expect(cubit.state.themeMode, ThemeMode.system);
    expect(cubit.state.locale, isNull);
  });

  test('setThemeMode switches the theme mode', () {
    final cubit = AppSettingsCubit();

    cubit.setThemeMode(ThemeMode.dark);
    expect(cubit.state.themeMode, ThemeMode.dark);
    expect(cubit.state.isDarkTheme, isTrue);

    cubit.setThemeMode(ThemeMode.light);
    expect(cubit.state.themeMode, ThemeMode.light);
    expect(cubit.state.isLightTheme, isTrue);

    cubit.setThemeMode(ThemeMode.system);
    expect(cubit.state.isSystemTheme, isTrue);
  });

  test('setThemeMode with the same mode does not emit', () {
    final cubit = AppSettingsCubit();
    var emissions = 0;
    cubit.stream.listen((_) => emissions++);

    cubit.setThemeMode(ThemeMode.system);

    expect(emissions, 0);
  });

  test('setLocale forces a locale and useSystemLocale resets it', () {
    final cubit = AppSettingsCubit();

    cubit.setLocale(const Locale('de'));
    expect(cubit.state.locale, const Locale('de'));
    expect(cubit.state.isActiveLocale(const Locale('de')), isTrue);

    cubit.useSystemLocale();
    expect(cubit.state.locale, isNull);
    expect(cubit.state.isActiveLocale(null), isTrue);
  });

  test('useSystemLocale when already system does not emit', () {
    final cubit = AppSettingsCubit();
    var emissions = 0;
    cubit.stream.listen((_) => emissions++);

    cubit.useSystemLocale();

    expect(emissions, 0);
  });
}
