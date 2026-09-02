import 'package:gewerber_app/domain/entities/transaction.dart';

/// Contract for bookkeeping operations (income/expense transactions, P&L).
abstract interface class AccountingRepository {
  /// Lists transactions with optional filters.
  Future<List<AccountingTransaction>> list({
    TransactionType? type,
    TransactionCategory? category,
    DateTime? from,
    DateTime? to,
    int? limit,
    int? offset,
  });

  /// Retrieves a single transaction by its ID.
  Future<AccountingTransaction> getAccountingTransaction(int transactionId);

  /// Records an income or expense transaction.
  ///
  /// [receiptDocumentId] links a previously uploaded receipt document
  /// (via `document.upload`) to the transaction.
  Future<AccountingTransaction> create({
    required TransactionType type,
    required TransactionCategory category,
    required DateTime occurredAt,
    required int amountCents,
    String? description,
    int? receiptDocumentId,
  });

  /// Updates an existing transaction.
  Future<AccountingTransaction> update(AccountingTransaction transaction);

  /// Deletes a transaction.
  Future<void> delete(int transactionId);

  /// Basic profit & loss (EÜR style) for the period.
  Future<ProfitLossReport> profitLoss(DateTime from, DateTime to);

  /// Exports transactions as CSV.
  Future<String> exportCsv({
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  });
}
