import 'package:gewerber_app/domain/entities/business.dart';
import 'package:gewerber_app/domain/entities/customer.dart';
import 'package:gewerber_app/domain/entities/customer_list_page.dart';

/// Contract for customer operations used by the application layer.
abstract interface class CustomerRepository {
  /// Lists the business's customers, optionally filtered by [status].
  Future<List<Customer>> list({
    CustomerStatus? status,
    int? limit,
    int? offset,
  });

  /// Returns an offset-based paged list of customers.
  Future<CustomerListPage> listPage({
    CustomerStatus? status,
    int? limit,
    int? offset,
  });

  /// Returns a cursor-based paged list of customers.
  Future<CustomerCursorPage> listCursorPage({
    CustomerStatus? status,
    int? limit,
    String? cursor,
  });

  /// Creates a customer for the active business.
  Future<Customer> create({
    required String name,
    String? companyName,
    String? vatId,
    String? email,
    String? phone,
    Address? address,
    String? notes,
  });

  /// Updates an existing customer.
  Future<Customer> update(Customer customer);

  /// Archives the given customer.
  Future<void> archive(int customerId);
}
