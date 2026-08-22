import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/repositories/invoice_repository.dart';

/// In-memory [InvoiceRepository] backing the demo experience and the widget
/// tests. Data lives for the app session only.
@LazySingleton(as: InvoiceRepository, env: [AppEnvironment.authMock])
class MockInvoiceRepository implements InvoiceRepository {
  final List<Invoice> _invoices = [];
  final Map<int, List<InvoiceItem>> _items = {};
  final Map<int, List<PaymentRecord>> _payments = {};
  final Map<int, List<InvoiceReminder>> _reminders = {};
  int _nextNumber = 1;
  int _nextPaymentId = 1;
  int _nextReminderId = 1;

  @override
  Future<List<Invoice>> list({
    InvoiceStatus? status,
    int? limit,
    int? offset,
  }) async {
    var result = _invoices.where(
      (invoice) => status == null || invoice.status == status,
    );
    final start = offset ?? 0;
    final end = limit == null ? null : start + limit;
    return result
        .skip(start)
        .take(end == null ? 1 << 31 : end - start)
        .toList();
  }

  @override
  Future<({Invoice invoice, List<InvoiceItem> items})> get(
    int invoiceId,
  ) async {
    final invoice = _invoices.firstWhere((value) => value.id == invoiceId);
    return (invoice: invoice, items: _items[invoiceId] ?? const []);
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
  }) async {
    final invoice = Invoice(
      id: _invoices.length + 1,
      number: 'RE-${_nextNumber++}',
      customerId: customerId,
      issueDate: issueDate ?? DateTime.now(),
      dueDate: dueDate,
      serviceDateFrom: serviceDateFrom,
      serviceDateTo: serviceDateTo,
      notes: notes,
    );
    _invoices.add(invoice);
    _items[invoice.id] = items;
    return invoice;
  }

  @override
  Future<Invoice> update(
    Invoice invoice, {
    required List<InvoiceItem> items,
  }) async {
    final index = _invoices.indexWhere((value) => value.id == invoice.id);
    if (index < 0) throw StateError('Unknown invoice id ${invoice.id}');
    _invoices[index] = invoice;
    _items[invoice.id] = items;
    return invoice;
  }

  @override
  Future<void> delete(int invoiceId) async {
    _invoices.removeWhere((value) => value.id == invoiceId);
    _items.remove(invoiceId);
    _payments.remove(invoiceId);
    _reminders.remove(invoiceId);
  }

  Invoice _transition(int invoiceId, InvoiceStatus status) {
    final index = _invoices.indexWhere((value) => value.id == invoiceId);
    if (index < 0) throw StateError('Unknown invoice id $invoiceId');
    final updated = Invoice(
      id: invoiceId,
      number: _invoices[index].number,
      status: status,
      customerId: _invoices[index].customerId,
      issueDate: _invoices[index].issueDate,
      dueDate: _invoices[index].dueDate,
      serviceDateFrom: _invoices[index].serviceDateFrom,
      serviceDateTo: _invoices[index].serviceDateTo,
      subtotalCents: _invoices[index].subtotalCents,
      vatTotalCents: _invoices[index].vatTotalCents,
      totalCents: _invoices[index].totalCents,
      notes: _invoices[index].notes,
    );
    _invoices[index] = updated;
    return updated;
  }

  @override
  Future<Invoice> markSent(int invoiceId) async =>
      _transition(invoiceId, InvoiceStatus.sent);

  @override
  Future<Invoice> cancel(int invoiceId) async =>
      _transition(invoiceId, InvoiceStatus.cancelled);

  @override
  Future<InvoicePdf> generatePdf(int invoiceId) async {
    final invoice = _invoices.firstWhere((value) => value.id == invoiceId);
    const header = '%PDF-1.4 (mock invoice document)';
    return InvoicePdf(
      documentId: invoiceId,
      fileName: '${invoice.number}.pdf',
      bytes: header.codeUnits,
    );
  }

  @override
  Future<String> exportCsv({InvoiceStatus? status}) async {
    final lines = StringBuffer('number;status;total');
    for (final invoice in _invoices) {
      if (status != null && invoice.status != status) continue;
      lines.write(
        '\n${invoice.number};${invoice.status.name};${invoice.totalCents}',
      );
    }
    return lines.toString();
  }

  @override
  Future<String> exportJson({InvoiceStatus? status}) async {
    final selected = _invoices
        .where((invoice) => status == null || invoice.status == status)
        .map((invoice) => invoice.number)
        .toList();
    return '{"invoices": $selected}';
  }

  @override
  Future<PaymentRecord> recordPayment({
    required int invoiceId,
    required int amountCents,
    DateTime? paidAt,
    String? reference,
  }) async {
    final payment = PaymentRecord(
      id: _nextPaymentId++,
      invoiceId: invoiceId,
      amountCents: amountCents,
      paidAt: paidAt ?? DateTime.now(),
      reference: reference,
    );
    _payments.putIfAbsent(invoiceId, () => []).add(payment);

    // Mirror the server: fully paid invoices transition to `paid`.
    final invoice = _invoices.firstWhere((value) => value.id == invoiceId);
    final paidTotal = _payments[invoiceId]!.fold<int>(
      0,
      (sum, record) => sum + record.amountCents,
    );
    if (paidTotal >= invoice.totalCents && invoice.totalCents > 0) {
      _transition(invoiceId, InvoiceStatus.paid);
    }
    return payment;
  }

  @override
  Future<InvoicePaymentStatus> paymentStatus(int invoiceId) async {
    final invoice = _invoices.firstWhere((value) => value.id == invoiceId);
    final payments = _payments[invoiceId] ?? const [];
    final paidTotal = payments.fold<int>(
      0,
      (sum, record) => sum + record.amountCents,
    );
    final remaining = invoice.totalCents - paidTotal;
    return InvoicePaymentStatus(
      invoiceId: invoiceId,
      paidTotalCents: paidTotal,
      remainingCents: remaining.clamp(0, invoice.totalCents),
      isPaid: remaining <= 0,
      payments: payments,
    );
  }

  @override
  Future<List<InvoiceReminder>> listReminders(int invoiceId) async {
    return List.unmodifiable(_reminders[invoiceId] ?? const []);
  }

  @override
  Future<InvoiceReminder> sendReminder(int invoiceId) async {
    final reminders = _reminders.putIfAbsent(invoiceId, () => []);
    final reminder = InvoiceReminder(
      id: _nextReminderId++,
      invoiceId: invoiceId,
      level: reminders.length + 1,
      sentAt: DateTime.now(),
    );
    reminders.add(reminder);
    return reminder;
  }
}
