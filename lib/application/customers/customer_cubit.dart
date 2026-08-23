import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/customers/customer_state.dart';
import 'package:gewerber_app/core/errors/error_handler.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/business.dart';
import 'package:gewerber_app/domain/entities/customer.dart';
import 'package:gewerber_app/domain/repositories/customer_repository.dart';

/// Owns the customers of the active business.
@LazySingleton()
class CustomerCubit extends Cubit<CustomerState> {
  CustomerCubit(this._repository) : super(const CustomerState());

  final CustomerRepository _repository;

  /// Loads the customers, optionally filtered by [status].
  ///
  /// [limit] and [offset] page through the server-side list; `null` lets the
  /// backend apply its defaults.
  Future<void> load({CustomerStatus? status, int? limit, int? offset}) async {
    if (state.isLoading) return;
    emit(
      state.copyWith(status: CustomerViewStatus.loading, clearFailure: true),
    );
    try {
      final customers = await _repository.list(
        status: status,
        limit: limit,
        offset: offset,
      );
      if (isClosed) return;
      emit(
        CustomerState(status: CustomerViewStatus.loaded, customers: customers),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CustomerViewStatus.failure,
          failure: mapAppException(e),
        ),
      );
    } on Exception {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: CustomerViewStatus.failure,
          failure: const NetworkFailure(),
        ),
      );
    }
  }

  /// Creates a customer for the active business.
  ///
  /// Returns `true` on success.
  Future<bool> create({
    required String name,
    String? companyName,
    String? vatId,
    String? email,
    String? phone,
    Address? address,
    String? notes,
  }) async {
    try {
      final customer = await _repository.create(
        name: name,
        companyName: companyName,
        vatId: vatId,
        email: email,
        phone: phone,
        address: address,
        notes: notes,
      );
      if (!isClosed) {
        emit(
          CustomerState(
            status: CustomerViewStatus.loaded,
            customers: [...state.customers, customer],
          ),
        );
      }
      return true;
    } on Exception {
      return false;
    }
  }

  /// Updates an existing customer.
  ///
  /// Returns `true` on success.
  Future<bool> update(Customer customer) async {
    try {
      final updated = await _repository.update(customer);
      if (!isClosed) {
        emit(
          CustomerState(
            status: CustomerViewStatus.loaded,
            customers: [
              for (final current in state.customers)
                if (current.id == updated.id) updated else current,
            ],
          ),
        );
      }
      return true;
    } on Exception {
      return false;
    }
  }

  /// Archives the given customer.
  Future<void> archive(int customerId) async {
    try {
      await _repository.archive(customerId);
      if (!isClosed) {
        emit(
          CustomerState(
            status: CustomerViewStatus.loaded,
            customers: [
              for (final current in state.customers)
                if (current.id == customerId)
                  current.copyWithStatus(CustomerStatus.archived)
                else
                  current,
            ],
          ),
        );
      }
    } on Exception {
      // Non-fatal: keep the list as-is.
    }
  }
}
