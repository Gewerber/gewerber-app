// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../core/config/app_config.dart' as _i221;
import '../domain/repositories/auth_repository.dart' as _i800;
import '../infrastructure/repositories/mock_auth_repository.dart' as _i338;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appConfigModule = _$AppConfigModule();
    gh.singleton<_i221.AppConfig>(() => appConfigModule.provideAppConfig());
    gh.lazySingleton<_i800.AuthRepository>(() => _i338.MockAuthRepository());
    return this;
  }
}

class _$AppConfigModule extends _i221.AppConfigModule {}
