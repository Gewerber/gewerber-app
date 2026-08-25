import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gewerber_app/application/settings/app_settings_cubit.dart';
import 'package:gewerber_app/infrastructure/datasources/local/appearance_preferences_store.dart';

/// Persistence roundtrip for the appearance preferences.
///
/// Uses the mocked `shared_preferences` backing store: a seeded value must
/// restore the cubit state at construction, and changes made through the
/// cubit must land in the store so a freshly constructed cubit picks them up
/// (the next-launch scenario).
void main() {
  test('seeded preferences restore the state at construction', () async {
    SharedPreferences.setMockInitialValues({
      'appearance.theme': 'dark',
      'appearance.locale': 'de',
    });
    final prefs = await SharedPreferences.getInstance();
    final cubit = AppSettingsCubit(
      localStore: SharedPreferencesAppearanceRepository(prefs),
    );

    expect(cubit.state.themeMode, ThemeMode.dark);
    expect(cubit.state.locale, const Locale('de'));
    expect(cubit.state.isDarkTheme, isTrue);
    expect(cubit.state.isActiveLocale(const Locale('de')), isTrue);
  });

  test('changing appearance writes through to the store', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = SharedPreferencesAppearanceRepository(prefs);
    final cubit = AppSettingsCubit(localStore: store);

    cubit.setThemeMode(ThemeMode.light);
    cubit.setLocale(const Locale('tr'));
    // Writes are fire-and-forget; flush pending microtasks.
    await Future<void>.delayed(Duration.zero);

    expect(prefs.getString('appearance.theme'), 'light');
    expect(prefs.getString('appearance.locale'), 'tr');

    // A fresh cubit (next launch) restores the persisted values.
    final relaunched = AppSettingsCubit(
      localStore: SharedPreferencesAppearanceRepository(prefs),
    );
    expect(relaunched.state.themeMode, ThemeMode.light);
    expect(relaunched.state.locale, const Locale('tr'));
  });

  test('changing one dimension keeps the other stored value', () async {
    SharedPreferences.setMockInitialValues({'appearance.locale': 'de'});
    final prefs = await SharedPreferences.getInstance();
    final cubit = AppSettingsCubit(
      localStore: SharedPreferencesAppearanceRepository(prefs),
    );

    // Switching only the theme must not clear the stored language…
    cubit.setThemeMode(ThemeMode.dark);
    await Future<void>.delayed(Duration.zero);
    expect(prefs.getString('appearance.theme'), 'dark');
    expect(prefs.getString('appearance.locale'), 'de');

    // …and switching back to the system language must keep the theme.
    cubit.useSystemLocale();
    await Future<void>.delayed(Duration.zero);
    expect(prefs.getString('appearance.theme'), 'dark');
    expect(prefs.getString('appearance.locale'), isNull);

    final relaunched = AppSettingsCubit(
      localStore: SharedPreferencesAppearanceRepository(prefs),
    );
    expect(relaunched.state.themeMode, ThemeMode.dark);
    expect(relaunched.state.locale, isNull);
  });

  test('useSystemLocale removes the stored locale', () async {
    SharedPreferences.setMockInitialValues({'appearance.locale': 'ru'});
    final prefs = await SharedPreferences.getInstance();
    final cubit = AppSettingsCubit(
      localStore: SharedPreferencesAppearanceRepository(prefs),
    );

    cubit.useSystemLocale();
    await Future<void>.delayed(Duration.zero);

    expect(prefs.getString('appearance.locale'), isNull);
  });

  test('reset re-applies the device-local appearance', () async {
    SharedPreferences.setMockInitialValues({
      'appearance.theme': 'dark',
      'appearance.locale': 'de',
    });
    final prefs = await SharedPreferences.getInstance();
    final cubit = AppSettingsCubit(
      localStore: SharedPreferencesAppearanceRepository(prefs),
    );

    // A signed-in session may change the appearance through the settings
    // screens; every change persists on the device immediately.
    cubit.setThemeMode(ThemeMode.light);
    await Future<void>.delayed(Duration.zero);

    // Signing out resets the cubit — the stored device appearance is
    // re-applied (both dimensions intact), not plain defaults.
    cubit.reset();

    expect(cubit.state.themeMode, ThemeMode.light);
    expect(cubit.state.locale, const Locale('de'));
  });

  test('unknown stored values fall back to the defaults', () async {
    SharedPreferences.setMockInitialValues({
      'appearance.theme': 'blue',
      'appearance.locale': 'xx',
    });
    final prefs = await SharedPreferences.getInstance();
    final cubit = AppSettingsCubit(
      localStore: SharedPreferencesAppearanceRepository(prefs),
    );

    expect(cubit.state.themeMode, ThemeMode.system);
    expect(cubit.state.locale, isNull);
  });

  test('without a store the initial state stays the plain default', () async {
    final cubit = AppSettingsCubit();

    expect(cubit.state.themeMode, ThemeMode.system);
    expect(cubit.state.locale, isNull);
  });
}
