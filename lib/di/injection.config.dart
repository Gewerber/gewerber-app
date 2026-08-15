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

import '../application/auth/auth_cubit.dart' as _i487;
import '../application/forgot_password/forgot_password_cubit.dart' as _i318;
import '../application/register/register_cubit.dart' as _i66;
import '../core/config/app_config.dart' as _i221;
import '../domain/repositories/auth_repository.dart' as _i800;
import '../infrastructure/core/serverpod_client_factory.dart' as _i661;
import '../infrastructure/datasources/local/session_store.dart' as _i900;
import '../infrastructure/datasources/remote/auth_remote_data_source.dart'
    as _i322;
import '../infrastructure/datasources/remote/social_auth_remote_data_source.dart'
    as _i691;
import '../infrastructure/mappers/user_mapper.dart' as _i980;
import '../infrastructure/repositories/mock_auth_repository.dart' as _i338;
import '../infrastructure/repositories/serverpod_auth_repository.dart' as _i194;
import '../presentation/router/auth_redirect_controller.dart' as _i1070;

const String _auth_live = 'auth_live';
const String _auth_mock = 'auth_mock';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appConfigModule = _$AppConfigModule();
    gh.factory<_i980.UserMapper>(() => const _i980.UserMapper());
    gh.singleton<_i221.AppConfig>(() => appConfigModule.provideAppConfig());
    gh.lazySingleton<_i661.ServerpodClientFactory>(
      () => _i661.ServerpodClientFactory(gh<_i221.AppConfig>()),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i322.AuthRemoteDataSource>(
      () => _i322.AuthRemoteDataSource(gh<_i661.ServerpodClientFactory>()),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i800.AuthRepository>(
      () => _i338.MockAuthRepository(),
      registerFor: {_auth_mock},
    );
    gh.lazySingleton<_i900.SessionStore>(
      () => _i900.SessionStore(),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i691.SocialAuthRemoteDataSource>(
      () => const _i691.SocialAuthRemoteDataSource(),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i800.AuthRepository>(
      () => _i194.ServerpodAuthRepository(
        gh<_i322.AuthRemoteDataSource>(),
        gh<_i691.SocialAuthRemoteDataSource>(),
        gh<_i900.SessionStore>(),
        gh<_i980.UserMapper>(),
      ),
      registerFor: {_auth_live},
    );
    gh.factory<_i318.ForgotPasswordCubit>(
      () => _i318.ForgotPasswordCubit(gh<_i800.AuthRepository>()),
    );
    gh.lazySingleton<_i487.AuthCubit>(
      () => _i487.AuthCubit(gh<_i800.AuthRepository>()),
    );
    gh.lazySingleton<_i1070.AuthRedirectController>(
      () => _i1070.AuthRedirectController(gh<_i487.AuthCubit>()),
    );
    gh.factory<_i66.RegisterCubit>(
      () =>
          _i66.RegisterCubit(gh<_i800.AuthRepository>(), gh<_i487.AuthCubit>()),
    );
    return this;
  }
}

class _$AppConfigModule extends _i221.AppConfigModule {}
