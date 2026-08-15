import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/business_settings.dart';
import 'package:gewerber_app/infrastructure/core/serverpod_client_factory.dart';

/// Transport-level business settings calls against the Serverpod backend.
@LazySingleton(env: [AppEnvironment.authLive])
class BusinessSettingsRemoteDataSource {
  BusinessSettingsRemoteDataSource(this._clientFactory);

  final ServerpodClientFactory _clientFactory;

  sdk.Client get _client => _clientFactory.client;

  Future<BusinessSettings> get({required int businessId}) async {
    try {
      return _fromModel(
        await _client.businessSettings.get(businessId: businessId),
      );
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<BusinessSettings> update(
    BusinessSettings settings, {
    required int businessId,
  }) async {
    try {
      final model = await _client.businessSettings.update(
        sdk.UpdateBusinessSettingsRequest(
          businessId: businessId,
          paymentTermsDays: settings.paymentTermsDays,
          invoiceNumberPrefix: settings.invoiceNumberPrefix,
          invoiceNumberIncludeYear: settings.invoiceNumberIncludeYear,
          invoiceNumberMinDigits: settings.invoiceNumberMinDigits,
          roundingMode: sdk.RoundingMode.values.byName(
            settings.roundingMode.name,
          ),
          roundingGranularityMinutes: settings.roundingGranularityMinutes,
        ),
      );
      return _fromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  BusinessSettings _fromModel(sdk.BusinessSettings model) {
    return BusinessSettings(
      paymentTermsDays: model.paymentTermsDays,
      invoiceNumberPrefix: model.invoiceNumberPrefix,
      invoiceNumberIncludeYear: model.invoiceNumberIncludeYear,
      invoiceNumberMinDigits: model.invoiceNumberMinDigits,
      roundingMode: RoundingMode.fromName(model.roundingMode.name),
      roundingGranularityMinutes: model.roundingGranularityMinutes,
    );
  }
}
