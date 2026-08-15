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
  ];
}
