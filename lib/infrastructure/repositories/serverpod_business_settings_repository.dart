import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/business_settings.dart';
import 'package:gewerber_app/domain/repositories/business_settings_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/business_settings_remote_data_source.dart';

/// Serverpod-backed [BusinessSettingsRepository].
@LazySingleton(as: BusinessSettingsRepository, env: [AppEnvironment.authLive])
class ServerpodBusinessSettingsRepository
    implements BusinessSettingsRepository {
  ServerpodBusinessSettingsRepository(this._dataSource);

  final BusinessSettingsRemoteDataSource _dataSource;

  @override
  Future<BusinessSettings> get({required int businessId}) {
    return _guard(() => _dataSource.get(businessId: businessId));
  }

  @override
  Future<BusinessSettings> update(
    BusinessSettings settings, {
    required int businessId,
  }) {
    return _guard(() => _dataSource.update(settings, businessId: businessId));
  }

  /// Runs [action] and rethrows [AppException]s, wrapping any other error as
  /// a [NetworkException].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }
}
