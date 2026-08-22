import 'package:equatable/equatable.dart';

/// Whether a transaction is money in or money out, mirroring the server's
/// `TransactionType` enum.
enum TransactionType {
  income,
  expense;

  static TransactionType fromName(String name) {
    return TransactionType.values.firstWhere(
      (value) => value.name == name,
      orElse: () => TransactionType.expense,
    );
  }
}

/// Bookkeeping category of a transaction, mirroring the server's
/// `TransactionCategory` enum.
enum TransactionCategory {
  salesRevenue,
  serviceRevenue,
  otherIncome,
  goodsPurchase,
  rent,
  office,
  travel,
  vehicle,
  advertising,
  insurance,
  telecommunication,
  training,
  consulting,
  feesAndDuties,
  tools,
  otherExpense;

  static TransactionCategory fromName(String name) {
    return TransactionCategory.values.firstWhere(
      (value) => value.name == name,
      orElse: () => TransactionCategory.otherExpense,
    );
  }

  /// Categories that apply to income transactions.
  static const List<TransactionCategory> incomeCategories = [
    salesRevenue,
    serviceRevenue,
    otherIncome,
  ];

  /// Categories that apply to expense transactions.
  static const List<TransactionCategory> expenseCategories = [
    goodsPurchase,
    rent,
    office,
    travel,
    vehicle,
    advertising,
    insurance,
    telecommunication,
    training,
    consulting,
    feesAndDuties,
    tools,
    otherExpense,
  ];

  bool get isIncomeCategory => incomeCategories.contains(this);
}

/// An income or expense transaction (EÜR bookkeeping).
class AccountingTransaction extends Equatable {
  const AccountingTransaction({
    required this.id,
    required this.type,
    required this.category,
    required this.occurredAt,
    required this.amountCents,
    this.description,
    this.receiptDocumentId,
    this.relatedInvoiceId,
  });

  final int id;
  final TransactionType type;
  final TransactionCategory category;
  final String? description;
  final DateTime occurredAt;
  final int amountCents;
  final int? receiptDocumentId;
  final int? relatedInvoiceId;

  AccountingTransaction copyWith({
    TransactionType? type,
    TransactionCategory? category,
    Object? description = _sentinel,
    DateTime? occurredAt,
    int? amountCents,
  }) {
    return AccountingTransaction(
      id: id,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description is String? ? description : this.description,
      occurredAt: occurredAt ?? this.occurredAt,
      amountCents: amountCents ?? this.amountCents,
      receiptDocumentId: receiptDocumentId,
      relatedInvoiceId: relatedInvoiceId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    category,
    description,
    occurredAt,
    amountCents,
    receiptDocumentId,
    relatedInvoiceId,
  ];
}

/// One category line of a profit & loss report.
class ProfitLossLine extends Equatable {
  const ProfitLossLine({
    required this.category,
    required this.amountCents,
    required this.count,
  });

  final TransactionCategory category;
  final int amountCents;
  final int count;

  @override
  List<Object?> get props => [category, amountCents, count];
}

/// Basic profit & loss (EÜR style) for a period.
class ProfitLossReport extends Equatable {
  const ProfitLossReport({
    required this.from,
    required this.to,
    required this.incomeCents,
    required this.expenseCents,
    required this.profitCents,
    this.incomeLines = const [],
    this.expenseLines = const [],
  });

  final DateTime from;
  final DateTime to;
  final int incomeCents;
  final int expenseCents;
  final int profitCents;
  final List<ProfitLossLine> incomeLines;
  final List<ProfitLossLine> expenseLines;

  @override
  List<Object?> get props => [
    from,
    to,
    incomeCents,
    expenseCents,
    profitCents,
    incomeLines,
    expenseLines,
  ];
}

const Object _sentinel = Object();
