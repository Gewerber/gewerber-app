import 'package:gewerber_app/domain/entities/business.dart';
import 'package:gewerber_app/domain/entities/customer.dart';

/// Contract for customer operations used by the application layer.
abstract interface class CustomerRepository {
  /// Lists the business's customers, optionally filtered by [status].
  Future<List<Customer>> list({
    CustomerStatus? status,
    int? limit,
    int? offset,
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
