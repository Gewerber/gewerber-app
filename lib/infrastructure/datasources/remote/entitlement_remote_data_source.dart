import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/entitlement.dart';
import 'package:gewerber_app/infrastructure/core/serverpod_client_factory.dart';

/// Transport-level entitlement calls against the Serverpod backend.
///
/// Every serverpod exception is translated into an [AppException] so higher
/// layers stay free of transport details.
@LazySingleton(env: [AppEnvironment.authLive])
class EntitlementRemoteDataSource {
  EntitlementRemoteDataSource(this._clientFactory);

  final ServerpodClientFactory _clientFactory;

  sdk.Client get _client => _clientFactory.client;

  Future<Entitlements> list() async {
    try {
      final sdkFeatures = await _client.entitlement.list();
      final features = sdkFeatures.map(_mapFeature).toList();
      return Entitlements(features: features);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  static Feature _mapFeature(sdk.Feature sdkFeature) =>
      Feature.fromName(sdkFeature.name);
}
