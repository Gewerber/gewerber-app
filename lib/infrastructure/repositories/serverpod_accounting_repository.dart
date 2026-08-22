import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/domain/repositories/accounting_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/accounting_remote_data_source.dart';

/// Serverpod-backed [AccountingRepository].
@LazySingleton(as: AccountingRepository, env: [AppEnvironment.authLive])
class ServerpodAccountingRepository implements AccountingRepository {
  ServerpodAccountingRepository(this._dataSource);

  final AccountingRemoteDataSource _dataSource;

  @override
  Future<List<AccountingTransaction>> list({
    TransactionType? type,
    TransactionCategory? category,
    DateTime? from,
    DateTime? to,
    int? limit,
    int? offset,
  }) {
    return _guard(
      () => _dataSource.list(
        type: type,
        category: category,
        from: from,
        to: to,
        limit: limit,
        offset: offset,
      ),
    );
  }

  @override
  Future<AccountingTransaction> create({
    required TransactionType type,
    required TransactionCategory category,
    required DateTime occurredAt,
    required int amountCents,
    String? description,
  }) {
    return _guard(
      () => _dataSource.create(
        type: type,
        category: category,
        occurredAt: occurredAt,
        amountCents: amountCents,
        description: description,
      ),
    );
  }

  @override
  Future<AccountingTransaction> update(AccountingTransaction transaction) {
    return _guard(() => _dataSource.update(transaction));
  }

  @override
  Future<void> delete(int transactionId) {
    return _guard(() => _dataSource.delete(transactionId));
  }

  @override
  Future<ProfitLossReport> profitLoss(DateTime from, DateTime to) {
    return _guard(() => _dataSource.profitLoss(from, to));
  }

  @override
  Future<String> exportCsv({
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  }) {
    return _guard(() => _dataSource.exportCsv(type: type, from: from, to: to));
  }

  /// Runs [action] and rethrows [AppException]s, wrapping any other error as
  /// a [NetworkException].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }
}
