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
  ///
  /// [limit] and [offset] page through the server-side list; `null` lets the
  /// backend apply its defaults.
  Future<void> load({InvoiceStatus? status, int? limit, int? offset}) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: InvoiceViewStatus.loading, clearFailure: true));
    try {
      final invoices = await _repository.list(
        status: status,
        limit: limit,
        offset: offset,
      );
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
  /// [templateId] associates a layout template with the invoice (default
  /// template prefill). Returns `true` on success.
  Future<bool> create({
    required List<InvoiceItem> items,
    int? customerId,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? serviceDateFrom,
    DateTime? serviceDateTo,
    String? notes,
    int? templateId,
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
        templateId: templateId,
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

  /// Transitions a draft invoice to `sent`.
  ///
  /// Returns `true` on success.
  Future<bool> markSent(int invoiceId) {
    return _transition(invoiceId, () => _repository.markSent(invoiceId));
  }

  /// Cancels an invoice that is not paid or already cancelled.
  ///
  /// Returns `true` on success.
  Future<bool> cancelInvoice(int invoiceId) {
    return _transition(invoiceId, () => _repository.cancel(invoiceId));
  }

  Future<bool> _transition(
    int invoiceId,
    Future<Invoice> Function() action,
  ) async {
    try {
      final updated = await action();
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

  /// Generates the invoice PDF on the server and returns it for download.
  Future<InvoicePdf?> downloadPdf(int invoiceId) async {
    try {
      return await _repository.generatePdf(invoiceId);
    } on Exception {
      return null;
    }
  }

  /// Exports invoices as CSV. Returns `null` on failure.
  Future<String?> exportCsv({InvoiceStatus? status}) async {
    try {
      return await _repository.exportCsv(status: status);
    } on Exception {
      return null;
    }
  }

  /// Exports invoices as JSON. Returns `null` on failure.
  Future<String?> exportJson({InvoiceStatus? status}) async {
    try {
      return await _repository.exportJson(status: status);
    } on Exception {
      return null;
    }
  }

  /// Records a payment for the invoice.
  ///
  /// Returns `true` on success.
  Future<bool> recordPayment({
    required int invoiceId,
    required int amountCents,
    DateTime? paidAt,
    String? reference,
  }) async {
    try {
      await _repository.recordPayment(
        invoiceId: invoiceId,
        amountCents: amountCents,
        paidAt: paidAt,
        reference: reference,
      );
      // A fully paid invoice transitions to `paid` server-side; refresh the
      // cached list entry so the status chip updates.
      await refresh(invoiceId);
      return true;
    } on Exception {
      return false;
    }
  }

  /// Loads the payment state of the invoice. Returns `null` on failure.
  Future<InvoicePaymentStatus?> paymentStatus(int invoiceId) async {
    try {
      return await _repository.paymentStatus(invoiceId);
    } on Exception {
      return null;
    }
  }

  /// Lists all reminders sent for the invoice. Returns `null` on failure.
  Future<List<InvoiceReminder>?> listReminders(int invoiceId) async {
    try {
      return await _repository.listReminders(invoiceId);
    } on Exception {
      return null;
    }
  }

  /// Sends a payment reminder for the invoice.
  ///
  /// Returns `true` on success.
  Future<bool> sendReminder(int invoiceId) async {
    try {
      await _repository.sendReminder(invoiceId);
      return true;
    } on Exception {
      return false;
    }
  }

  /// Re-fetches a single invoice and updates the cached list entry.
  Future<void> refresh(int invoiceId) async {
    try {
      final result = await _repository.get(invoiceId);
      if (isClosed) return;
      emit(
        InvoiceState(
          status: InvoiceViewStatus.loaded,
          invoices: [
            for (final current in state.invoices)
              if (current.id == invoiceId) result.invoice else current,
          ],
        ),
      );
    } on Exception {
      // Non-fatal: the stale entry stays in the list.
    }
  }
}
