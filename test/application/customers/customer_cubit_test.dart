import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/customers/customer_state.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/business.dart';
import 'package:gewerber_app/domain/entities/customer.dart';
import 'package:gewerber_app/domain/entities/customer_list_page.dart';
import 'package:gewerber_app/domain/repositories/customer_repository.dart';

class _FakeCustomerRepository implements CustomerRepository {
  _FakeCustomerRepository({List<Customer>? customers, this.failLoad = false})
    : _customers = List.of(customers ?? const []);

  final List<Customer> _customers;
  bool failLoad;

  @override
  Future<List<Customer>> list({
    CustomerStatus? status,
    int? limit,
    int? offset,
  }) async {
    if (failLoad) throw const NetworkException();
    return List.unmodifiable(_customers);
  }

  @override
  Future<CustomerListPage> listPage({
    CustomerStatus? status,
    int? limit,
    int? offset,
  }) async {
    if (failLoad) throw const NetworkException();
    return CustomerListPage(
      items: List.unmodifiable(_customers),
      totalCount: _customers.length,
      limit: limit ?? 20,
      offset: offset ?? 0,
    );
  }

  @override
  Future<CustomerCursorPage> listCursorPage({
    CustomerStatus? status,
    int? limit,
    String? cursor,
  }) async {
    if (failLoad) throw const NetworkException();
    return CustomerCursorPage(
      items: List.unmodifiable(_customers),
      limit: limit ?? 20,
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
  }) async {
    final customer = Customer(id: _customers.length + 1, name: name);
    _customers.add(customer);
    return customer;
  }

  @override
  Future<Customer> update(Customer customer) async {
    final index = _customers.indexWhere((value) => value.id == customer.id);
    if (index < 0) throw StateError('Unknown customer ${customer.id}');
    _customers[index] = customer;
    return customer;
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

void main() {
  const customer = Customer(id: 1, name: 'Anna Muster');

  test('starts in the initial state', () {
    final cubit = CustomerCubit(_FakeCustomerRepository());

    expect(cubit.state.status, CustomerViewStatus.initial);
    expect(cubit.state.customers, isEmpty);
  });

  test('load emits loading then loaded with the customers', () async {
    final cubit = CustomerCubit(_FakeCustomerRepository(customers: [customer]));
    final states = <CustomerViewStatus>[];
    cubit.stream.listen((state) => states.add(state.status));

    await cubit.load();
    await Future<void>.delayed(Duration.zero);

    expect(states, [CustomerViewStatus.loading, CustomerViewStatus.loaded]);
    expect(cubit.state.customers, [customer]);
  });

  test('load failure maps to a failure state', () async {
    final cubit = CustomerCubit(_FakeCustomerRepository(failLoad: true));

    await cubit.load();

    expect(cubit.state.status, CustomerViewStatus.failure);
    expect(cubit.state.failure, isA<NetworkFailure>());
  });

  test('create appends the customer and returns true', () async {
    final cubit = CustomerCubit(_FakeCustomerRepository());

    final created = await cubit.create(name: 'Max Mustermann');

    expect(created, isTrue);
    expect(cubit.state.customers.single.name, 'Max Mustermann');
  });

  test('update replaces the matching customer', () async {
    final cubit = CustomerCubit(_FakeCustomerRepository(customers: [customer]));
    await cubit.load();

    final updated = await cubit.update(const Customer(id: 1, name: 'Anna Neu'));

    expect(updated, isTrue);
    expect(cubit.state.customers.single.name, 'Anna Neu');
  });

  test('archive marks the customer as archived', () async {
    final cubit = CustomerCubit(_FakeCustomerRepository(customers: [customer]));
    await cubit.load();

    await cubit.archive(1);

    expect(cubit.state.customers.single.status, CustomerStatus.archived);
  });
}
