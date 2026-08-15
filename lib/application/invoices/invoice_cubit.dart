import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/invoices/invoice_state.dart';
import 'package:gewerber_app/core/errors/error_handler.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/repositories/invoice_repository.dart';

/// Owns the invoices of the active business.
@LazySingleton()
class InvoiceCubit extends Cubit<InvoiceState> {
  InvoiceCubit(this._repository) : super(const InvoiceState());

  final InvoiceRepository _repository;

  /// Loads the invoices, optionally filtered by [status].
  Future<void> load({InvoiceStatus? status}) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: InvoiceViewStatus.loading, clearFailure: true));
    try {
      final invoices = await _repository.list(status: status);
      if (isClosed) return;
      emit(InvoiceState(status: InvoiceViewStatus.loaded, invoices: invoices));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: InvoiceViewStatus.failure,
          failure: mapAppException(e),
        ),
      );
    } on Exception {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: InvoiceViewStatus.failure,
          failure: const NetworkFailure(),
        ),
      );
    }
  }

  /// Loads a single invoice together with its line items.
  Future<({Invoice invoice, List<InvoiceItem> items})?> get(
    int invoiceId,
  ) async {
    try {
      return await _repository.get(invoiceId);
    } on Exception {
      return null;
    }
  }

  /// Creates a new invoice.
  ///
  /// Returns `true` on success.
  Future<bool> create({
    required List<InvoiceItem> items,
    int? customerId,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? serviceDateFrom,
    DateTime? serviceDateTo,
    String? notes,
  }) async {
    try {
      final invoice = await _repository.create(
        items: items,
        customerId: customerId,
        issueDate: issueDate,
        dueDate: dueDate,
        serviceDateFrom: serviceDateFrom,
        serviceDateTo: serviceDateTo,
        notes: notes,
      );
      if (!isClosed) {
        emit(
          InvoiceState(
            status: InvoiceViewStatus.loaded,
            invoices: [...state.invoices, invoice],
          ),
        );
      }
      return true;
    } on Exception {
      return false;
    }
  }

  /// Updates an existing invoice.
  ///
  /// Returns `true` on success.
  Future<bool> update(
    Invoice invoice, {
    required List<InvoiceItem> items,
  }) async {
    try {
      final updated = await _repository.update(invoice, items: items);
      if (!isClosed) {
        emit(
          InvoiceState(
            status: InvoiceViewStatus.loaded,
            invoices: [
              for (final current in state.invoices)
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

  /// Deletes the given invoice.
  ///
  /// Returns `true` on success.
  Future<bool> delete(int invoiceId) async {
    try {
      await _repository.delete(invoiceId);
      if (!isClosed) {
        emit(
          InvoiceState(
            status: InvoiceViewStatus.loaded,
            invoices: state.invoices
                .where((invoice) => invoice.id != invoiceId)
                .toList(),
          ),
        );
      }
      return true;
    } on Exception {
      return false;
    }
  }
}
