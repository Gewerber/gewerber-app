import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/infrastructure/core/serverpod_client_factory.dart';

/// Transport-level dashboard calls against the Serverpod backend.
///
/// Every serverpod exception is translated into an [AppException] so higher
/// layers stay free of transport details.
@LazySingleton(env: [AppEnvironment.authLive])
class DashboardRemoteDataSource {
  DashboardRemoteDataSource(this._clientFactory);

  final ServerpodClientFactory _clientFactory;

  sdk.Client get _client => _clientFactory.client;

  /// Fetches the aggregated server-side summary.
  ///
  /// All list sizes are clamped server-side; `asOf` is deliberately not
  /// passed through — it anchors every window for backend tests only.
  Future<sdk.DashboardSummary> getSummary({
    int? trendMonths,
    int? recentLimit,
    int? overdueLimit,
    int? debtorLimit,
  }) async {
    try {
      return await _client.dashboard.getSummary(
        trendMonths: trendMonths,
        recentLimit: recentLimit,
        overdueLimit: overdueLimit,
        debtorLimit: debtorLimit,
      );
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }
}
