import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/entitlement.dart';
import 'package:gewerber_app/domain/repositories/entitlement_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/entitlement_remote_data_source.dart';

/// Serverpod-backed [EntitlementRepository].
@LazySingleton(as: EntitlementRepository, env: [AppEnvironment.authLive])
class ServerpodEntitlementRepository implements EntitlementRepository {
  ServerpodEntitlementRepository(this._dataSource);

  final EntitlementRemoteDataSource _dataSource;

  @override
  Future<Entitlements> list() => _guard(() => _dataSource.list());

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
