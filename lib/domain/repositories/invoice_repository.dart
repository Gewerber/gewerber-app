import 'package:gewerber_app/domain/entities/invoice.dart';

/// Contract for invoice operations used by the application layer.
abstract interface class InvoiceRepository {
  /// Lists the business's invoices, optionally filtered by [status].
  Future<List<Invoice>> list({InvoiceStatus? status, int? limit, int? offset});

  /// Loads a single invoice together with its line items.
  Future<({Invoice invoice, List<InvoiceItem> items})> get(int invoiceId);

  /// Creates a new invoice.
  Future<Invoice> create({
    required List<InvoiceItem> items,
    int? customerId,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? serviceDateFrom,
    DateTime? serviceDateTo,
    String? notes,
  });

  /// Updates an existing invoice.
  Future<Invoice> update(Invoice invoice, {required List<InvoiceItem> items});

  /// Deletes the given invoice (only draft invoices can be deleted).
  Future<void> delete(int invoiceId);
}
