import 'package:equatable/equatable.dart';

import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/customer.dart';

/// Loading state of the customer list.
enum CustomerViewStatus { initial, loading, loaded, failure }

/// Immutable customer state.
class CustomerState extends Equatable {
  const CustomerState({
    this.status = CustomerViewStatus.initial,
    this.customers = const [],
    this.failure,
  });

  final CustomerViewStatus status;
  final List<Customer> customers;
  final Failure? failure;

  bool get isLoading => status == CustomerViewStatus.loading;

  CustomerState copyWith({
    CustomerViewStatus? status,
    List<Customer>? customers,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return CustomerState(
      status: status ?? this.status,
      customers: customers ?? this.customers,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, customers, failure];
}
