import 'package:gewerber_app/domain/entities/business_settings.dart';

/// Contract for reading and updating the active business's settings.
abstract interface class BusinessSettingsRepository {
  /// Loads the settings of the business with [businessId].
  Future<BusinessSettings> get({required int businessId});

  /// Persists [settings] for the business with [businessId].
  Future<BusinessSettings> update(
    BusinessSettings settings, {
    required int businessId,
  });
}
