import 'package:equatable/equatable.dart';

/// Invoice status, mirroring the server's `InvoiceStatus` enum.
enum InvoiceStatus {
  draft,
  sent,
  paid,
  overdue,
  cancelled;

  static InvoiceStatus fromName(String name) {
    return InvoiceStatus.values.firstWhere(
      (value) => value.name == name,
      orElse: () => InvoiceStatus.draft,
    );
  }
}

/// Value-added tax rate applied to an invoice line, mirroring the server's
/// `VatRate` enum.
enum InvoiceVatRate {
  none,
  reduced,
  standard;

  static InvoiceVatRate fromName(String name) {
    return InvoiceVatRate.values.firstWhere(
      (value) => value.name == name,
      orElse: () => InvoiceVatRate.standard,
    );
  }
}

/// A single line item of an invoice.
class InvoiceItem extends Equatable {
  const InvoiceItem({
    required this.description,
    this.quantity = 1,
    this.unitPriceCents = 0,
    this.vatRate = InvoiceVatRate.standard,
    this.lineTotalCents = 0,
  });

  final String description;
  final double quantity;
  final int unitPriceCents;
  final InvoiceVatRate vatRate;
  final int lineTotalCents;

  InvoiceItem copyWith({
    String? description,
    double? quantity,
    int? unitPriceCents,
    InvoiceVatRate? vatRate,
    int? lineTotalCents,
  }) {
    return InvoiceItem(
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      vatRate: vatRate ?? this.vatRate,
      lineTotalCents: lineTotalCents ?? this.lineTotalCents,
    );
  }

  @override
  List<Object?> get props => [
    description,
    quantity,
    unitPriceCents,
    vatRate,
    lineTotalCents,
  ];
}

/// A recorded payment for an invoice.
class PaymentRecord extends Equatable {
  const PaymentRecord({
    required this.id,
    required this.invoiceId,
    required this.amountCents,
    this.paidAt,
    this.reference,
  });

  final int id;
  final int invoiceId;
  final DateTime? paidAt;
  final int amountCents;
  final String? reference;

  @override
  List<Object?> get props => [id, invoiceId, paidAt, amountCents, reference];
}

/// Payment state of a single invoice.
class InvoicePaymentStatus extends Equatable {
  const InvoicePaymentStatus({
    required this.invoiceId,
    required this.paidTotalCents,
    required this.remainingCents,
    required this.isPaid,
    this.payments = const [],
  });

  final int invoiceId;
  final int paidTotalCents;
  final int remainingCents;
  final bool isPaid;
  final List<PaymentRecord> payments;

  @override
  List<Object?> get props => [
    invoiceId,
    paidTotalCents,
    remainingCents,
    isPaid,
    payments,
  ];
}

/// A payment reminder (dunning level) sent for an invoice.
class InvoiceReminder extends Equatable {
  const InvoiceReminder({
    required this.id,
    required this.invoiceId,
    required this.level,
    this.sentAt,
  });

  final int id;
  final int invoiceId;
  final int level;
  final DateTime? sentAt;

  @override
  List<Object?> get props => [id, invoiceId, level, sentAt];
}

/// Metadata of a generated invoice PDF stored as a document on the server.
class InvoicePdf extends Equatable {
  const InvoicePdf({
    required this.documentId,
    required this.fileName,
    required this.bytes,
  });

  final int documentId;
  final String fileName;
  final List<int> bytes;

  @override
  List<Object?> get props => [documentId, fileName, bytes.length];
}

/// An invoice issued by the business.
class Invoice extends Equatable {
  const Invoice({
    required this.id,
    required this.number,
    required this.issueDate,
    this.status = InvoiceStatus.draft,
    this.customerId,
    this.dueDate,
    this.serviceDateFrom,
    this.serviceDateTo,
    this.subtotalCents = 0,
    this.vatTotalCents = 0,
    this.totalCents = 0,
    this.notes,
    this.templateId,
  });

  final int id;
  final String number;
  final InvoiceStatus status;
  final int? customerId;
  final DateTime issueDate;
  final DateTime? dueDate;
  final DateTime? serviceDateFrom;
  final DateTime? serviceDateTo;
  final int subtotalCents;
  final int vatTotalCents;
  final int totalCents;
  final String? notes;

  /// Layout template applied to the invoice (header/footer/logo on the
  /// generated PDF), if any.
  final int? templateId;

  bool get isDraft => status == InvoiceStatus.draft;

  @override
  List<Object?> get props => [
    id,
    number,
    status,
    customerId,
    issueDate,
    dueDate,
    serviceDateFrom,
    serviceDateTo,
    subtotalCents,
    vatTotalCents,
    totalCents,
    notes,
    templateId,
  ];
}
