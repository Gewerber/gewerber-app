import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/business.dart';
import 'package:gewerber_app/domain/entities/customer.dart';
import 'package:gewerber_app/domain/entities/customer_list_page.dart';
import 'package:gewerber_app/domain/repositories/customer_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/customer_remote_data_source.dart';

/// Serverpod-backed [CustomerRepository].
@LazySingleton(as: CustomerRepository, env: [AppEnvironment.authLive])
class ServerpodCustomerRepository implements CustomerRepository {
  ServerpodCustomerRepository(this._dataSource);

  final CustomerRemoteDataSource _dataSource;

  @override
  Future<List<Customer>> list({
    CustomerStatus? status,
    int? limit,
    int? offset,
  }) {
    return _guard(
      () => _dataSource.list(status: status, limit: limit, offset: offset),
    );
  }

  @override
  Future<CustomerListPage> listPage({
    CustomerStatus? status,
    int? limit,
    int? offset,
  }) {
    return _guard(
      () => _dataSource.listPage(status: status, limit: limit, offset: offset),
    );
  }

  @override
  Future<CustomerCursorPage> listCursorPage({
    CustomerStatus? status,
    int? limit,
    String? cursor,
  }) {
    return _guard(
      () => _dataSource.listCursorPage(
        status: status,
        limit: limit,
        cursor: cursor,
      ),
    );
  }

  @override
  Future<Customer> create({
    required String name,
    String? companyName,
    String? vatId,
    String? email,
    String? phone,
    Address? address,
    String? notes,
  }) {
    return _guard(
      () => _dataSource.create(
        name: name,
        companyName: companyName,
        vatId: vatId,
        email: email,
        phone: phone,
        address: address,
        notes: notes,
      ),
    );
  }

  @override
  Future<Customer> update(Customer customer) {
    return _guard(() => _dataSource.update(customer));
  }

  @override
  Future<void> archive(int customerId) {
    return _guard(() async {
      final customer = await _dataSource.get(customerId);
      final updated = customer.copyWithStatus(CustomerStatus.archived);
      await _dataSource.update(updated);
    });
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
