import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/domain/entities/business_settings.dart';
import 'package:gewerber_app/domain/repositories/business_settings_repository.dart';

/// In-memory [BusinessSettingsRepository] backing the demo experience and the
/// widget tests. Settings live for the app session only.
@LazySingleton(as: BusinessSettingsRepository, env: [AppEnvironment.authMock])
class MockBusinessSettingsRepository implements BusinessSettingsRepository {
  BusinessSettings _settings = const BusinessSettings();

  @override
  Future<BusinessSettings> get({required int businessId}) async => _settings;

  @override
  Future<BusinessSettings> update(
    BusinessSettings settings, {
    required int businessId,
  }) async {
    _settings = settings;
    return _settings;
  }
}
