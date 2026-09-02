import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/entities/invoice_list_page.dart';
import 'package:gewerber_app/domain/repositories/invoice_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/invoice_remote_data_source.dart';

/// Serverpod-backed [InvoiceRepository].
@LazySingleton(as: InvoiceRepository, env: [AppEnvironment.authLive])
class ServerpodInvoiceRepository implements InvoiceRepository {
  ServerpodInvoiceRepository(this._dataSource);

  final InvoiceRemoteDataSource _dataSource;

  @override
  Future<List<Invoice>> list({InvoiceStatus? status, int? limit, int? offset}) {
    return _guard(
      () => _dataSource.list(status: status, limit: limit, offset: offset),
    );
  }

  @override
  Future<InvoiceListPage> listPage({
    InvoiceStatus? status,
    int? limit,
    int? offset,
  }) {
    return _guard(
      () => _dataSource.listPage(status: status, limit: limit, offset: offset),
    );
  }

  @override
  Future<InvoiceCursorPage> listCursorPage({
    InvoiceStatus? status,
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
  Future<({Invoice invoice, List<InvoiceItem> items})> get(int invoiceId) {
    return _guard(() => _dataSource.get(invoiceId));
  }

  @override
  Future<Invoice> create({
    required List<InvoiceItem> items,
    int? customerId,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? serviceDateFrom,
    DateTime? serviceDateTo,
    String? notes,
    int? templateId,
  }) {
    return _guard(
      () => _dataSource.create(
        items: items,
        customerId: customerId,
        issueDate: issueDate,
        dueDate: dueDate,
        serviceDateFrom: serviceDateFrom,
        serviceDateTo: serviceDateTo,
        notes: notes,
        templateId: templateId,
      ),
    );
  }

  @override
  Future<Invoice> update(Invoice invoice, {required List<InvoiceItem> items}) {
    return _guard(() => _dataSource.update(invoice, items: items));
  }

  @override
  Future<void> delete(int invoiceId) {
    return _guard(() => _dataSource.delete(invoiceId));
  }

  @override
  Future<Invoice> markSent(int invoiceId) {
    return _guard(() => _dataSource.markSent(invoiceId));
  }

  @override
  Future<Invoice> cancel(int invoiceId) {
    return _guard(() => _dataSource.cancel(invoiceId));
  }

  @override
  Future<InvoicePdf> generatePdf(int invoiceId) {
    return _guard(() => _dataSource.generatePdf(invoiceId));
  }

  @override
  Future<String> exportCsv({InvoiceStatus? status}) {
    return _guard(() => _dataSource.exportCsv(status: status));
  }

  @override
  Future<String> exportJson({InvoiceStatus? status}) {
    return _guard(() => _dataSource.exportJson(status: status));
  }

  @override
  Future<PaymentRecord> recordPayment({
    required int invoiceId,
    required int amountCents,
    DateTime? paidAt,
    String? reference,
  }) {
    return _guard(
      () => _dataSource.recordPayment(
        invoiceId: invoiceId,
        amountCents: amountCents,
        paidAt: paidAt,
        reference: reference,
      ),
    );
  }

  @override
  Future<InvoicePaymentStatus> paymentStatus(int invoiceId) {
    return _guard(() => _dataSource.paymentStatus(invoiceId));
  }

  @override
  Future<List<InvoiceReminder>> listReminders(int invoiceId) {
    return _guard(() => _dataSource.listReminders(invoiceId));
  }

  @override
  Future<InvoiceReminder> sendReminder(int invoiceId) {
    return _guard(() => _dataSource.sendReminder(invoiceId));
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
