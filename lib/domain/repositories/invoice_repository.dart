import 'package:gewerber_app/domain/entities/invoice.dart';

/// Contract for invoice operations used by the application layer.
abstract interface class InvoiceRepository {
  /// Lists the business's invoices, optionally filtered by [status].
  Future<List<Invoice>> list({InvoiceStatus? status, int? limit, int? offset});

  /// Loads a single invoice together with its line items.
  Future<({Invoice invoice, List<InvoiceItem> items})> get(int invoiceId);

  /// Creates a new invoice.
  ///
  /// [templateId] associates a layout template whose header/footer are
  /// applied to the generated PDF.
  Future<Invoice> create({
    required List<InvoiceItem> items,
    int? customerId,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? serviceDateFrom,
    DateTime? serviceDateTo,
    String? notes,
    int? templateId,
  });

  /// Updates an existing invoice.
  Future<Invoice> update(Invoice invoice, {required List<InvoiceItem> items});

  /// Deletes the given invoice (only draft invoices can be deleted).
  Future<void> delete(int invoiceId);

  /// Transitions a draft invoice to `sent`.
  Future<Invoice> markSent(int invoiceId);

  /// Cancels an invoice that is not paid or already cancelled.
  Future<Invoice> cancel(int invoiceId);

  /// Generates the invoice PDF on the server and returns it for download.
  Future<InvoicePdf> generatePdf(int invoiceId);

  /// Exports invoices as CSV (semicolon-separated, comma decimals).
  Future<String> exportCsv({InvoiceStatus? status});

  /// Exports invoices (with items) as a JSON string.
  Future<String> exportJson({InvoiceStatus? status});

  /// Records a payment for the invoice.
  Future<PaymentRecord> recordPayment({
    required int invoiceId,
    required int amountCents,
    DateTime? paidAt,
    String? reference,
  });

  /// Loads the payment state of the invoice.
  Future<InvoicePaymentStatus> paymentStatus(int invoiceId);

  /// Lists all reminders sent for the invoice, ordered by send date.
  Future<List<InvoiceReminder>> listReminders(int invoiceId);

  /// Sends a payment reminder to the customer and records it.
  Future<InvoiceReminder> sendReminder(int invoiceId);
}
