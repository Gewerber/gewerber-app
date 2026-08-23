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

import '../application/accounting/accounting_cubit.dart' as _i946;
import '../application/auth/auth_cubit.dart' as _i487;
import '../application/business/business_cubit.dart' as _i139;
import '../application/business_settings/business_settings_cubit.dart' as _i419;
import '../application/customers/customer_cubit.dart' as _i598;
import '../application/forgot_password/forgot_password_cubit.dart' as _i318;
import '../application/guidance/checklist_cubit.dart' as _i873;
import '../application/guidance/guidance_cubit.dart' as _i140;
import '../application/invoice_templates/invoice_template_cubit.dart' as _i563;
import '../application/invoices/invoice_cubit.dart' as _i1027;
import '../application/recurring_schedules/recurring_schedule_cubit.dart'
    as _i184;
import '../application/register/register_cubit.dart' as _i66;
import '../application/time_tracking/projects_cubit.dart' as _i593;
import '../application/time_tracking/time_entries_cubit.dart' as _i266;
import '../application/user_profile/user_profile_cubit.dart' as _i268;
import '../core/config/app_config.dart' as _i221;
import '../domain/repositories/accounting_repository.dart' as _i188;
import '../domain/repositories/auth_repository.dart' as _i800;
import '../domain/repositories/business_repository.dart' as _i93;
import '../domain/repositories/business_settings_repository.dart' as _i743;
import '../domain/repositories/customer_repository.dart' as _i907;
import '../domain/repositories/guidance_repository.dart' as _i78;
import '../domain/repositories/invoice_repository.dart' as _i778;
import '../domain/repositories/invoice_template_repository.dart' as _i309;
import '../domain/repositories/recurring_schedule_repository.dart' as _i721;
import '../domain/repositories/time_tracking_repository.dart' as _i323;
import '../domain/repositories/user_preferences_repository.dart' as _i101;
import '../domain/repositories/user_profile_repository.dart' as _i439;
import '../infrastructure/core/serverpod_client_factory.dart' as _i661;
import '../infrastructure/datasources/local/session_store.dart' as _i900;
import '../infrastructure/datasources/remote/accounting_remote_data_source.dart'
    as _i253;
import '../infrastructure/datasources/remote/auth_remote_data_source.dart'
    as _i322;
import '../infrastructure/datasources/remote/business_remote_data_source.dart'
    as _i1061;
import '../infrastructure/datasources/remote/business_settings_remote_data_source.dart'
    as _i334;
import '../infrastructure/datasources/remote/customer_remote_data_source.dart'
    as _i1067;
import '../infrastructure/datasources/remote/guidance_remote_data_source.dart'
    as _i126;
import '../infrastructure/datasources/remote/invoice_remote_data_source.dart'
    as _i206;
import '../infrastructure/datasources/remote/invoice_template_remote_data_source.dart'
    as _i490;
import '../infrastructure/datasources/remote/recurring_schedule_remote_data_source.dart'
    as _i317;
import '../infrastructure/datasources/remote/social_auth_remote_data_source.dart'
    as _i691;
import '../infrastructure/datasources/remote/time_tracking_remote_data_source.dart'
    as _i876;
import '../infrastructure/datasources/remote/user_preferences_remote_data_source.dart'
    as _i984;
import '../infrastructure/datasources/remote/user_profile_remote_data_source.dart'
    as _i212;
import '../infrastructure/mappers/business_mapper.dart' as _i457;
import '../infrastructure/mappers/customer_mapper.dart' as _i234;
import '../infrastructure/mappers/guidance_mapper.dart' as _i367;
import '../infrastructure/mappers/invoice_mapper.dart' as _i295;
import '../infrastructure/mappers/time_tracking_mapper.dart' as _i42;
import '../infrastructure/mappers/transaction_mapper.dart' as _i756;
import '../infrastructure/mappers/user_mapper.dart' as _i980;
import '../infrastructure/mappers/user_preferences_mapper.dart' as _i53;
import '../infrastructure/repositories/mock_accounting_repository.dart'
    as _i254;
import '../infrastructure/repositories/mock_auth_repository.dart' as _i338;
import '../infrastructure/repositories/mock_business_repository.dart' as _i869;
import '../infrastructure/repositories/mock_business_settings_repository.dart'
    as _i587;
import '../infrastructure/repositories/mock_customer_repository.dart' as _i569;
import '../infrastructure/repositories/mock_guidance_repository.dart' as _i420;
import '../infrastructure/repositories/mock_invoice_repository.dart' as _i555;
import '../infrastructure/repositories/mock_invoice_template_repository.dart'
    as _i677;
import '../infrastructure/repositories/mock_recurring_schedule_repository.dart'
    as _i612;
import '../infrastructure/repositories/mock_time_tracking_repository.dart'
    as _i368;
import '../infrastructure/repositories/mock_user_preferences_repository.dart'
    as _i732;
import '../infrastructure/repositories/mock_user_profile_repository.dart'
    as _i553;
import '../infrastructure/repositories/serverpod_accounting_repository.dart'
    as _i224;
import '../infrastructure/repositories/serverpod_auth_repository.dart' as _i194;
import '../infrastructure/repositories/serverpod_business_repository.dart'
    as _i1028;
import '../infrastructure/repositories/serverpod_business_settings_repository.dart'
    as _i63;
import '../infrastructure/repositories/serverpod_customer_repository.dart'
    as _i720;
import '../infrastructure/repositories/serverpod_guidance_repository.dart'
    as _i34;
import '../infrastructure/repositories/serverpod_invoice_repository.dart'
    as _i1035;
import '../infrastructure/repositories/serverpod_invoice_template_repository.dart'
    as _i708;
import '../infrastructure/repositories/serverpod_recurring_schedule_repository.dart'
    as _i463;
import '../infrastructure/repositories/serverpod_time_tracking_repository.dart'
    as _i640;
import '../infrastructure/repositories/serverpod_user_preferences_repository.dart'
    as _i763;
import '../infrastructure/repositories/serverpod_user_profile_repository.dart'
    as _i141;
import '../presentation/router/auth_redirect_controller.dart' as _i1070;
import '../presentation/router/business_redirect_controller.dart' as _i981;

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
    gh.factory<_i457.BusinessMapper>(() => const _i457.BusinessMapper());
    gh.factory<_i234.CustomerMapper>(() => const _i234.CustomerMapper());
    gh.factory<_i367.GuidanceMapper>(() => const _i367.GuidanceMapper());
    gh.factory<_i295.InvoiceMapper>(() => const _i295.InvoiceMapper());
    gh.factory<_i42.TimeTrackingMapper>(() => const _i42.TimeTrackingMapper());
    gh.factory<_i756.TransactionMapper>(() => const _i756.TransactionMapper());
    gh.factory<_i980.UserMapper>(() => const _i980.UserMapper());
    gh.factory<_i53.UserPreferencesMapper>(
      () => const _i53.UserPreferencesMapper(),
    );
    gh.singleton<_i221.AppConfig>(() => appConfigModule.provideAppConfig());
    gh.lazySingleton<_i661.ServerpodClientFactory>(
      () => _i661.ServerpodClientFactory(gh<_i221.AppConfig>()),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i322.AuthRemoteDataSource>(
      () => _i322.AuthRemoteDataSource(gh<_i661.ServerpodClientFactory>()),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i334.BusinessSettingsRemoteDataSource>(
      () => _i334.BusinessSettingsRemoteDataSource(
        gh<_i661.ServerpodClientFactory>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i490.InvoiceTemplateRemoteDataSource>(
      () => _i490.InvoiceTemplateRemoteDataSource(
        gh<_i661.ServerpodClientFactory>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i317.RecurringScheduleRemoteDataSource>(
      () => _i317.RecurringScheduleRemoteDataSource(
        gh<_i661.ServerpodClientFactory>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i212.UserProfileRemoteDataSource>(
      () =>
          _i212.UserProfileRemoteDataSource(gh<_i661.ServerpodClientFactory>()),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i778.InvoiceRepository>(
      () => _i555.MockInvoiceRepository(),
      registerFor: {_auth_mock},
    );
    gh.lazySingleton<_i309.InvoiceTemplateRepository>(
      () => _i677.MockInvoiceTemplateRepository(),
      registerFor: {_auth_mock},
    );
    gh.lazySingleton<_i253.AccountingRemoteDataSource>(
      () => _i253.AccountingRemoteDataSource(
        gh<_i661.ServerpodClientFactory>(),
        gh<_i756.TransactionMapper>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i101.UserPreferencesRepository>(
      () => _i732.MockUserPreferencesRepository(),
      registerFor: {_auth_mock},
    );
    gh.lazySingleton<_i323.TimeTrackingRepository>(
      () => _i368.MockTimeTrackingRepository(),
      registerFor: {_auth_mock},
    );
    gh.lazySingleton<_i126.GuidanceRemoteDataSource>(
      () => _i126.GuidanceRemoteDataSource(
        gh<_i661.ServerpodClientFactory>(),
        gh<_i367.GuidanceMapper>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i439.UserProfileRepository>(
      () => _i553.MockUserProfileRepository(),
      registerFor: {_auth_mock},
    );
    gh.lazySingleton<_i721.RecurringScheduleRepository>(
      () => _i612.MockRecurringScheduleRepository(),
      registerFor: {_auth_mock},
    );
    gh.lazySingleton<_i188.AccountingRepository>(
      () => _i254.MockAccountingRepository(),
      registerFor: {_auth_mock},
    );
    gh.lazySingleton<_i800.AuthRepository>(
      () => _i338.MockAuthRepository(),
      registerFor: {_auth_mock},
    );
    gh.lazySingleton<_i1061.BusinessRemoteDataSource>(
      () => _i1061.BusinessRemoteDataSource(
        gh<_i661.ServerpodClientFactory>(),
        gh<_i457.BusinessMapper>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i78.GuidanceRepository>(
      () => _i420.MockGuidanceRepository(),
      registerFor: {_auth_mock},
    );
    gh.lazySingleton<_i743.BusinessSettingsRepository>(
      () => _i587.MockBusinessSettingsRepository(),
      registerFor: {_auth_mock},
    );
    gh.lazySingleton<_i907.CustomerRepository>(
      () => _i569.MockCustomerRepository(),
      registerFor: {_auth_mock},
    );
    gh.lazySingleton<_i93.BusinessRepository>(
      () => _i869.MockBusinessRepository(),
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
    gh.lazySingleton<_i93.BusinessRepository>(
      () => _i1028.ServerpodBusinessRepository(
        gh<_i1061.BusinessRemoteDataSource>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i139.BusinessCubit>(
      () => _i139.BusinessCubit(gh<_i93.BusinessRepository>()),
    );
    gh.lazySingleton<_i439.UserProfileRepository>(
      () => _i141.ServerpodUserProfileRepository(
        gh<_i212.UserProfileRemoteDataSource>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i743.BusinessSettingsRepository>(
      () => _i63.ServerpodBusinessSettingsRepository(
        gh<_i334.BusinessSettingsRemoteDataSource>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i206.InvoiceRemoteDataSource>(
      () => _i206.InvoiceRemoteDataSource(
        gh<_i661.ServerpodClientFactory>(),
        gh<_i295.InvoiceMapper>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i876.TimeTrackingRemoteDataSource>(
      () => _i876.TimeTrackingRemoteDataSource(
        gh<_i661.ServerpodClientFactory>(),
        gh<_i42.TimeTrackingMapper>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i188.AccountingRepository>(
      () => _i224.ServerpodAccountingRepository(
        gh<_i253.AccountingRemoteDataSource>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i981.BusinessRedirectController>(
      () => _i981.BusinessRedirectController(gh<_i139.BusinessCubit>()),
    );
    gh.lazySingleton<_i946.AccountingCubit>(
      () => _i946.AccountingCubit(gh<_i188.AccountingRepository>()),
    );
    gh.lazySingleton<_i309.InvoiceTemplateRepository>(
      () => _i708.ServerpodInvoiceTemplateRepository(
        gh<_i490.InvoiceTemplateRemoteDataSource>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i1067.CustomerRemoteDataSource>(
      () => _i1067.CustomerRemoteDataSource(
        gh<_i661.ServerpodClientFactory>(),
        gh<_i234.CustomerMapper>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i78.GuidanceRepository>(
      () => _i34.ServerpodGuidanceRepository(
        gh<_i126.GuidanceRemoteDataSource>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i778.InvoiceRepository>(
      () => _i1035.ServerpodInvoiceRepository(
        gh<_i206.InvoiceRemoteDataSource>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i984.UserPreferencesRemoteDataSource>(
      () => _i984.UserPreferencesRemoteDataSource(
        gh<_i661.ServerpodClientFactory>(),
        gh<_i53.UserPreferencesMapper>(),
      ),
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
    gh.lazySingleton<_i419.BusinessSettingsCubit>(
      () => _i419.BusinessSettingsCubit(gh<_i743.BusinessSettingsRepository>()),
    );
    gh.lazySingleton<_i721.RecurringScheduleRepository>(
      () => _i463.ServerpodRecurringScheduleRepository(
        gh<_i317.RecurringScheduleRemoteDataSource>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i184.RecurringScheduleCubit>(
      () =>
          _i184.RecurringScheduleCubit(gh<_i721.RecurringScheduleRepository>()),
    );
    gh.lazySingleton<_i907.CustomerRepository>(
      () => _i720.ServerpodCustomerRepository(
        gh<_i1067.CustomerRemoteDataSource>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i323.TimeTrackingRepository>(
      () => _i640.ServerpodTimeTrackingRepository(
        gh<_i876.TimeTrackingRemoteDataSource>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i563.InvoiceTemplateCubit>(
      () => _i563.InvoiceTemplateCubit(gh<_i309.InvoiceTemplateRepository>()),
    );
    gh.lazySingleton<_i268.UserProfileCubit>(
      () => _i268.UserProfileCubit(gh<_i439.UserProfileRepository>()),
    );
    gh.lazySingleton<_i598.CustomerCubit>(
      () => _i598.CustomerCubit(gh<_i907.CustomerRepository>()),
    );
    gh.lazySingleton<_i873.ChecklistCubit>(
      () => _i873.ChecklistCubit(gh<_i78.GuidanceRepository>()),
    );
    gh.lazySingleton<_i140.GuidanceCubit>(
      () => _i140.GuidanceCubit(gh<_i78.GuidanceRepository>()),
    );
    gh.lazySingleton<_i101.UserPreferencesRepository>(
      () => _i763.ServerpodUserPreferencesRepository(
        gh<_i984.UserPreferencesRemoteDataSource>(),
      ),
      registerFor: {_auth_live},
    );
    gh.lazySingleton<_i1027.InvoiceCubit>(
      () => _i1027.InvoiceCubit(gh<_i778.InvoiceRepository>()),
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
    gh.lazySingleton<_i593.ProjectsCubit>(
      () => _i593.ProjectsCubit(gh<_i323.TimeTrackingRepository>()),
    );
    gh.lazySingleton<_i266.TimeEntriesCubit>(
      () => _i266.TimeEntriesCubit(gh<_i323.TimeTrackingRepository>()),
    );
    gh.factory<_i66.RegisterCubit>(
      () =>
          _i66.RegisterCubit(gh<_i800.AuthRepository>(), gh<_i487.AuthCubit>()),
    );
    return this;
  }
}

class _$AppConfigModule extends _i221.AppConfigModule {}
