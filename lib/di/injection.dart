import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';

import 'injection.config.dart';

/// Service locator instance.
final GetIt getIt = GetIt.instance;

/// Generates and registers all dependencies (see `di/injection.config.dart`).
///
/// [environment] selects the authentication backend: `auth-live` (Serverpod)
/// or `auth-mock` (in-memory demo). When omitted, [AppEnvironment.authEnvironment]
/// decides based on the build mode and any `--dart-define=AUTH_MODE=...`.
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies({String? environment}) {
  getIt.init(environment: environment ?? AppEnvironment.authEnvironment);
}
