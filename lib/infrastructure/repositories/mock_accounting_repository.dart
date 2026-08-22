import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/domain/repositories/accounting_repository.dart';

/// In-memory [AccountingRepository] backing the demo experience and the widget
/// tests. Data lives for the app session only.
@LazySingleton(as: AccountingRepository, env: [AppEnvironment.authMock])
class MockAccountingRepository implements AccountingRepository {
  final List<AccountingTransaction> _transactions = [];
  int _nextId = 1;

  @override
  Future<List<AccountingTransaction>> list({
    TransactionType? type,
    TransactionCategory? category,
    DateTime? from,
    DateTime? to,
    int? limit,
    int? offset,
  }) async {
    final result =
        _transactions
            .where(
              (transaction) =>
                  (type == null || transaction.type == type) &&
                  (category == null || transaction.category == category) &&
                  (from == null || !transaction.occurredAt.isBefore(from)) &&
                  (to == null || !transaction.occurredAt.isAfter(to)),
            )
            .toList()
          ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    final start = offset ?? 0;
    final limited = limit == null
        ? result.skip(start).toList()
        : result.skip(start).take(limit).toList();
    return limited;
  }

  @override
  Future<AccountingTransaction> create({
    required TransactionType type,
    required TransactionCategory category,
    required DateTime occurredAt,
    required int amountCents,
    String? description,
  }) async {
    final transaction = AccountingTransaction(
      id: _nextId++,
      type: type,
      category: category,
      occurredAt: occurredAt,
      amountCents: amountCents,
      description: description,
    );
    _transactions.add(transaction);
    return transaction;
  }

  @override
  Future<AccountingTransaction> update(
    AccountingTransaction transaction,
  ) async {
    final index = _transactions.indexWhere(
      (value) => value.id == transaction.id,
    );
    if (index < 0) {
      throw StateError('Unknown transaction id ${transaction.id}');
    }
    _transactions[index] = transaction;
    return transaction;
  }

  @override
  Future<void> delete(int transactionId) async {
    _transactions.removeWhere((value) => value.id == transactionId);
  }

  @override
  Future<ProfitLossReport> profitLoss(DateTime from, DateTime to) async {
    final inPeriod = _transactions.where(
      (transaction) =>
          !transaction.occurredAt.isBefore(from) &&
          !transaction.occurredAt.isAfter(to),
    );

    ProfitLossLine lineFor(TransactionCategory category) {
      final matching = inPeriod
          .where((transaction) => transaction.category == category)
          .toList();
      return ProfitLossLine(
        category: category,
        amountCents: matching.fold<int>(
          0,
          (sum, transaction) => sum + transaction.amountCents,
        ),
        count: matching.length,
      );
    }

    final incomeLines = TransactionCategory.incomeCategories
        .map(lineFor)
        .where((line) => line.count > 0)
        .toList();
    final expenseLines = TransactionCategory.expenseCategories
        .map(lineFor)
        .where((line) => line.count > 0)
        .toList();
    final income = incomeLines.fold<int>(
      0,
      (sum, line) => sum + line.amountCents,
    );
    final expense = expenseLines.fold<int>(
      0,
      (sum, line) => sum + line.amountCents,
    );

    return ProfitLossReport(
      from: from,
      to: to,
      incomeCents: income,
      expenseCents: expense,
      profitCents: income - expense,
      incomeLines: incomeLines,
      expenseLines: expenseLines,
    );
  }

  @override
  Future<String> exportCsv({
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  }) async {
    final lines = StringBuffer('type;category;description;amount');
    for (final transaction in _transactions) {
      if (type != null && transaction.type != type) continue;
      if (from != null && transaction.occurredAt.isBefore(from)) continue;
      if (to != null && transaction.occurredAt.isAfter(to)) continue;
      lines.write(
        '\n${transaction.type.name};${transaction.category.name};'
        '${transaction.description ?? ''};${transaction.amountCents}',
      );
    }
    return lines.toString();
  }
}
