import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gewerber_app/application/settings/app_settings_cubit.dart';
import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/domain/repositories/appearance_preferences_repository.dart';
import 'package:gewerber_app/domain/repositories/user_preferences_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/local/appearance_preferences_store.dart';

import 'injection.config.dart';

/// Service locator instance.
final GetIt getIt = GetIt.instance;

/// Generates and registers all dependencies (see `di/injection.config.dart`).
///
/// [environment] selects the authentication backend: `auth-live` (Serverpod)
/// or `auth-mock` (in-memory demo). When omitted, [AppEnvironment.authEnvironment]
/// decides based on the build mode and any `--dart-define=AUTH_MODE=...`.
///
/// [sharedPreferences] wires the device-local appearance persistence (theme
/// and language survive restarts and are available on the pre-auth screens).
/// Pass an instance warmed via `SharedPreferences.getInstance()` before
/// calling this (see `bootstrap`) so [AppSettingsCubit] can read it
/// synchronously at construction. When omitted (widget tests), no local
/// store is registered and the cubit behaves as before.
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies({
  String? environment,
  SharedPreferences? sharedPreferences,
}) {
  getIt.init(environment: environment ?? AppEnvironment.authEnvironment);
  if (sharedPreferences != null) {
    getIt.registerLazySingleton<AppearancePreferencesRepository>(
      () => SharedPreferencesAppearanceRepository(sharedPreferences),
    );
  }
  getIt.registerLazySingleton<AppSettingsCubit>(() {
    final repository = getIt.isRegistered<UserPreferencesRepository>()
        ? getIt<UserPreferencesRepository>()
        : null;
    return AppSettingsCubit(
      repository: repository,
      localStore: getIt.isRegistered<AppearancePreferencesRepository>()
          ? getIt<AppearancePreferencesRepository>()
          : null,
    );
  });
}
