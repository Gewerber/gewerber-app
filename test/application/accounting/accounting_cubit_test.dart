import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/accounting/accounting_cubit.dart';
import 'package:gewerber_app/application/accounting/accounting_state.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/domain/repositories/accounting_repository.dart';

class _FakeAccountingRepository implements AccountingRepository {
  _FakeAccountingRepository({this.transactions = const [], this.fail = false});

  final List<AccountingTransaction> transactions;
  final bool fail;

  AccountingTransaction? lastUpdate;

  @override
  Future<List<AccountingTransaction>> list({
    TransactionType? type,
    TransactionCategory? category,
    DateTime? from,
    DateTime? to,
    int? limit,
    int? offset,
  }) async => List.of(transactions);

  @override
  Future<AccountingTransaction> update(
    AccountingTransaction transaction,
  ) async {
    lastUpdate = transaction;
    if (fail) throw const NetworkException('boom');
    return transaction;
  }

  // ── Unused members ──────────────────────────────────────────────────────

  @override
  Future<AccountingTransaction> create({
    required TransactionType type,
    required TransactionCategory category,
    required DateTime occurredAt,
    required int amountCents,
    String? description,
    int? receiptDocumentId,
  }) => throw UnimplementedError();

  @override
  Future<void> delete(int transactionId) => throw UnimplementedError();

  @override
  Future<ProfitLossReport> profitLoss(DateTime from, DateTime to) =>
      throw UnimplementedError();

  @override
  Future<String> exportCsv({
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  }) => throw UnimplementedError();

  @override
  Future<AccountingTransaction> getAccountingTransaction(int transactionId) =>
      throw UnimplementedError();
}

AccountingTransaction transaction(int id, {int amountCents = 1000}) {
  return AccountingTransaction(
    id: id,
    type: TransactionType.expense,
    category: TransactionCategory.office,
    occurredAt: DateTime(2026, 8, 20),
    amountCents: amountCents,
    description: 'Original $id',
  );
}

void main() {
  test(
    'update stores the payload and replaces the entry in the list',
    () async {
      final original = transaction(1);
      final repository = _FakeAccountingRepository(
        transactions: [original, transaction(2)],
      );
      final cubit = AccountingCubit(repository);
      await cubit.load();

      final edited = AccountingTransaction(
        id: original.id,
        type: TransactionType.income,
        category: TransactionCategory.salesRevenue,
        occurredAt: DateTime(2026, 8, 21),
        amountCents: 9900,
        description: 'Edited',
      );

      final success = await cubit.update(edited);

      expect(success, isTrue);
      expect(repository.lastUpdate, same(edited));
      expect(cubit.state.status, AccountingViewStatus.loaded);
      expect(cubit.state.transactions.map((t) => t.description), [
        'Edited',
        'Original 2',
      ]);
    },
  );

  test('update failure keeps the list unchanged and reports false', () async {
    final original = transaction(1);
    final repository = _FakeAccountingRepository(
      transactions: [original],
      fail: true,
    );
    final cubit = AccountingCubit(repository);
    await cubit.load();

    final success = await cubit.update(
      original.copyWith(description: 'Edited'),
    );

    expect(success, isFalse);
    expect(cubit.state.transactions.single.description, 'Original 1');
  });
}
