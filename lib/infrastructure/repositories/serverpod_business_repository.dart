import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/business.dart';
import 'package:gewerber_app/domain/repositories/business_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/business_remote_data_source.dart';

/// Serverpod-backed [BusinessRepository].
@LazySingleton(as: BusinessRepository, env: [AppEnvironment.authLive])
class ServerpodBusinessRepository implements BusinessRepository {
  ServerpodBusinessRepository(this._dataSource);

  final BusinessRemoteDataSource _dataSource;

  @override
  Future<Business> getBusiness(int businessId) {
    return _guard(() => _dataSource.getBusiness(businessId));
  }

  @override
  Future<List<Business>> listMine() {
    return _guard(() => _dataSource.listMine());
  }

  @override
  Future<Business> create({
    required String name,
    LegalForm legalForm = LegalForm.einzelunternehmen,
    bool isKleinunternehmer = false,
    String? vatId,
    String? email,
    String? phone,
    Address? address,
    BusinessLocale locale = BusinessLocale.de,
    BusinessCurrency currency = BusinessCurrency.eur,
  }) {
    return _guard(
      () => _dataSource.create(
        name: name,
        legalForm: legalForm,
        isKleinunternehmer: isKleinunternehmer,
        vatId: vatId,
        email: email,
        phone: phone,
        address: address,
        locale: locale,
        currency: currency,
      ),
    );
  }

  @override
  Future<Business> update(Business business) {
    return _guard(() => _dataSource.update(business));
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
