import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gewerber_app/application/settings/app_settings_cubit.dart';
import 'package:gewerber_app/application/settings/app_settings_state.dart';
import 'package:gewerber_app/domain/entities/user_preferences.dart';
import 'package:gewerber_app/domain/repositories/user_preferences_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/local/appearance_preferences_store.dart';

/// Sentinel matrix for the device-local appearance store.
///
/// The cubit's `AppSettingsState.locale == null` is the "follow the system
/// language" SENTINEL; in the device store the sentinel is represented by an
/// ABSENT `appearance.locale` key (see `SharedPreferencesAppearanceRepository`).
///
/// These tests pin that the sentinel survives every path introduced with the
/// second (device) store, mapped to review-matrix cases by name:
///
/// * **matrix 1** — theme-only change must persist the sentinel, never a
///   resolved concrete language;
/// * **matrix 2** — post-login server→device mirror policy (server wins while
///   signed in, see the dartdoc on `AppSettingsCubit.syncFromServer`);
/// * **matrix 3** — sign-out `reset()` re-applies stored values and never
///   deletes store keys; without a store it falls back to const defaults;
/// * **matrix 4** — every mutating method is safe when no
///   `AppearancePreferencesRepository` was ever registered.
void main() {
  test('sentinel matrix 1/4: theme-only change persists the system-language '
      'sentinel', () async {
    // Device follows the system language — locale key absent on purpose.
    SharedPreferences.setMockInitialValues({'appearance.theme': 'light'});
    final prefs = await SharedPreferences.getInstance();
    final cubit = AppSettingsCubit(
      localStore: SharedPreferencesAppearanceRepository(prefs),
    );
    expect(cubit.state.themeMode, ThemeMode.light);
    expect(cubit.state.locale, isNull);

    cubit.setThemeMode(ThemeMode.dark);
    await Future<void>.delayed(Duration.zero);

    // The new theme lands TOGETHER WITH THE SENTINEL (absent key) — not a
    // resolved concrete language silently pinning the system locale.
    expect(prefs.getString('appearance.theme'), 'dark');
    expect(prefs.getString('appearance.locale'), isNull);

    // Next launch restores exactly that: dark theme, still following the
    // system language.
    final relaunched = AppSettingsCubit(
      localStore: SharedPreferencesAppearanceRepository(prefs),
    );
    expect(relaunched.state.themeMode, ThemeMode.dark);
    expect(relaunched.state.locale, isNull);
  });

  test('sentinel matrix 2/4: post-login mirror applies server-wins-while-'
      'signed-in over the device sentinel', () async {
    SharedPreferences.setMockInitialValues({'appearance.theme': 'dark'});
    final prefs = await SharedPreferences.getInstance();
    final server = FakeServerPreferences(
      const UserPreferences(locale: AppLocale.de, theme: ThemePreference.light),
    );
    final cubit = AppSettingsCubit(
      localStore: SharedPreferencesAppearanceRepository(prefs),
      repository: server,
    );
    expect(cubit.state.locale, isNull); // device holds the sentinel

    await cubit.syncFromServer();

    // Deliberate policy (documented on syncFromServer): the concrete
    // profile language replaces the in-memory sentinel…
    expect(cubit.state.themeMode, ThemeMode.light);
    expect(cubit.state.locale, const Locale('de'));
    // …and mirrors into the device store, deliberately overwriting the
    // sentinel there too.
    await Future<void>.delayed(Duration.zero);
    expect(prefs.getString('appearance.theme'), 'light');
    expect(prefs.getString('appearance.locale'), 'de');

    // Documented consequence: after sign-out, reset() re-applies the device
    // store — which now carries the mirrored concrete value. The sentinel
    // stays one useSystemLocale() away.
    cubit.reset();
    expect(cubit.state.themeMode, ThemeMode.light);
    expect(cubit.state.locale, const Locale('de'));
  });

  test('sentinel matrix 2/4: syncFromServer without a stored profile changes '
      'nothing', () async {
    SharedPreferences.setMockInitialValues({'appearance.locale': 'ru'});
    final prefs = await SharedPreferences.getInstance();
    final cubit = AppSettingsCubit(
      localStore: SharedPreferencesAppearanceRepository(prefs),
      repository:
          FakeServerPreferences(), // no profile yet → getMyPreferences null
    );
    var emissions = 0;
    cubit.stream.listen((_) => emissions++);

    await cubit.syncFromServer();

    expect(cubit.state.themeMode, ThemeMode.system);
    expect(cubit.state.locale, const Locale('ru'));
    expect(emissions, 0);
    expect(prefs.getString('appearance.locale'), 'ru');
  });

  test(
    'sentinel matrix 3/4: reset re-applies the device store without deleting '
    'keys',
    () async {
      SharedPreferences.setMockInitialValues({
        'appearance.theme': 'dark',
        'appearance.locale': 'de',
      });
      final prefs = await SharedPreferences.getInstance();
      final cubit = AppSettingsCubit(
        localStore: SharedPreferencesAppearanceRepository(prefs),
      );

      // A signed-in session mutates the theme; both dimensions persist.
      cubit.setThemeMode(ThemeMode.light);
      await Future<void>.delayed(Duration.zero);

      cubit.reset();

      // Stored values re-applied (NOT the const defaults)…
      expect(cubit.state.themeMode, ThemeMode.light);
      expect(cubit.state.locale, const Locale('de'));
      // …and reset() performed no store writes or deletions of its own.
      expect(prefs.getString('appearance.theme'), 'light');
      expect(prefs.getString('appearance.locale'), 'de');

      // Equivalence proof: a fresh cubit over the same keys matches exactly.
      final relaunched = AppSettingsCubit(
        localStore: SharedPreferencesAppearanceRepository(prefs),
      );
      expect(cubit.state, relaunched.state);
    },
  );

  test('sentinel matrix 3/4: reset restores the system-language sentinel held '
      'by the store', () async {
    SharedPreferences.setMockInitialValues({'appearance.theme': 'dark'});
    final prefs = await SharedPreferences.getInstance();
    final cubit = AppSettingsCubit(
      localStore: SharedPreferencesAppearanceRepository(prefs),
    );

    // Detour during a session: pick a language, then hand control back to
    // the system — which writes the sentinel back into the store.
    cubit.setLocale(const Locale('en'));
    await Future<void>.delayed(Duration.zero);
    expect(prefs.getString('appearance.locale'), 'en');
    cubit.useSystemLocale();
    await Future<void>.delayed(Duration.zero);
    expect(prefs.getString('appearance.locale'), isNull);

    cubit.reset();

    expect(cubit.state.themeMode, ThemeMode.dark);
    expect(cubit.state.locale, isNull, reason: 'sentinel restored from store');
  });

  test('sentinel matrix 3/4: reset without a store falls back to the const '
      'defaults', () {
    final cubit = AppSettingsCubit(); // OSS/test DI path: no stores at all

    cubit.setThemeMode(ThemeMode.dark);
    cubit.setLocale(const Locale('de'));
    cubit.reset();

    expect(cubit.state, const AppSettingsState());
    expect(cubit.state.themeMode, ThemeMode.system);
    expect(cubit.state.locale, isNull);
  });

  test(
    'sentinel matrix 4/4: all mutating methods are safe without a registered '
    'device store',
    () async {
      final cubit = AppSettingsCubit();

      // Every mutator must pass its persistence guards without crashing
      // when neither store was ever registered.
      cubit.setThemeMode(ThemeMode.dark);
      expect(cubit.state.themeMode, ThemeMode.dark);

      cubit.setLocale(const Locale('tr'));
      expect(cubit.state.locale, const Locale('tr'));

      cubit.useSystemLocale();
      expect(cubit.state.locale, isNull);

      await cubit.syncFromServer(); // no-op without a repository

      cubit.reset();
      expect(cubit.state, const AppSettingsState());
    },
  );

  test('sentinel matrix 4/4: server-backed cubit without a device store stays '
      'safe', () async {
    final server = FakeServerPreferences(
      const UserPreferences(locale: AppLocale.en, theme: ThemePreference.dark),
    );
    final cubit = AppSettingsCubit(repository: server);

    await cubit.syncFromServer();
    expect(cubit.state.themeMode, ThemeMode.dark);
    expect(cubit.state.locale, const Locale('en'));

    // Mutations still push BOTH dimensions to the server (no wipe of the
    // sibling dimension) and simply skip the missing local store.
    cubit.setThemeMode(ThemeMode.light);
    await Future<void>.delayed(Duration.zero);

    expect(server.updates, hasLength(1));
    expect(server.updates.single.theme, ThemePreference.light);
    expect(server.updates.single.locale, AppLocale.en);
  });
}

/// Trivial in-memory [UserPreferencesRepository] fake for tests above.
class FakeServerPreferences implements UserPreferencesRepository {
  FakeServerPreferences([UserPreferences? initial]) : _preferences = initial;

  UserPreferences? _preferences;

  /// Every payload passed to [update], in call order.
  final List<UserPreferences> updates = [];

  @override
  Future<UserPreferences?> getMyPreferences() async => _preferences;

  @override
  Future<void> update(UserPreferences preferences) async {
    updates.add(preferences);
    _preferences = preferences;
  }
}
