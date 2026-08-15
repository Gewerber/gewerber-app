import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/domain/entities/business.dart';
import 'package:gewerber_app/domain/entities/customer.dart';
import 'package:gewerber_app/domain/repositories/customer_repository.dart';

/// In-memory [CustomerRepository] backing the demo experience and the widget
/// tests. Data lives for the app session only.
@LazySingleton(as: CustomerRepository, env: [AppEnvironment.authMock])
class MockCustomerRepository implements CustomerRepository {
  final List<Customer> _customers = [];

  @override
  Future<List<Customer>> list({
    CustomerStatus? status,
    int? limit,
    int? offset,
  }) async {
    var result = _customers.where(
      (customer) => status == null || customer.status == status,
    );
    final start = offset ?? 0;
    final end = limit == null ? null : start + limit;
    return result
        .skip(start)
        .take(end == null ? 1 << 31 : end - start)
        .toList();
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
  }) async {
    final customer = Customer(
      id: _customers.length + 1,
      name: name,
      companyName: companyName,
      vatId: vatId,
      email: email,
      phone: phone,
      address: address,
      notes: notes,
    );
    _customers.add(customer);
    return customer;
  }

  @override
  Future<Customer> update(Customer customer) async {
    final index = _customers.indexWhere((value) => value.id == customer.id);
    if (index >= 0) {
      _customers[index] = customer;
      return customer;
    }
    throw StateError('Unknown customer id ${customer.id}');
  }

  @override
  Future<void> archive(int customerId) async {
    final index = _customers.indexWhere((value) => value.id == customerId);
    if (index >= 0) {
      _customers[index] = _customers[index].copyWithStatus(
        CustomerStatus.archived,
      );
    }
  }
}
