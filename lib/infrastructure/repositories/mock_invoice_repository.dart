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
  int _nextNumber = 1;

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
  }
}
