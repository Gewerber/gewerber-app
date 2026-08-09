import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

/// Service locator instance.
final GetIt getIt = GetIt.instance;

/// Generates and registers all dependencies (see `di/injection.config.dart`).
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() {
  getIt.init();
}
