import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/accounting/accounting_state.dart';
import 'package:gewerber_app/core/errors/error_handler.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/domain/repositories/accounting_repository.dart';

/// Owns the bookkeeping transactions and the P&L report of the active
/// business.
@LazySingleton()
class AccountingCubit extends Cubit<AccountingState> {
  AccountingCubit(this._repository) : super(const AccountingState());

  final AccountingRepository _repository;

  /// Loads the transactions, optionally filtered.
  Future<void> load({
    TransactionType? type,
    TransactionCategory? category,
    DateTime? from,
    DateTime? to,
  }) async {
    if (state.isLoading) return;
    emit(
      state.copyWith(status: AccountingViewStatus.loading, clearFailure: true),
    );
    try {
      final transactions = await _repository.list(
        type: type,
        category: category,
        from: from,
        to: to,
        limit: 100,
      );
      if (isClosed) return;
      emit(
        AccountingState(
          status: AccountingViewStatus.loaded,
          transactions: transactions,
          report: state.report,
        ),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AccountingViewStatus.failure,
          failure: mapAppException(e),
        ),
      );
    } on Exception {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AccountingViewStatus.failure,
          failure: const NetworkFailure(),
        ),
      );
    }
  }

  /// Records a transaction. Returns `true` on success.
  ///
  /// [receiptDocumentId] references an already uploaded receipt document.
  Future<bool> create({
    required TransactionType type,
    required TransactionCategory category,
    required DateTime occurredAt,
    required int amountCents,
    String? description,
    int? receiptDocumentId,
  }) async {
    try {
      final transaction = await _repository.create(
        type: type,
        category: category,
        occurredAt: occurredAt,
        amountCents: amountCents,
        description: description,
        receiptDocumentId: receiptDocumentId,
      );
      if (!isClosed) {
        emit(
          state.copyWith(transactions: [transaction, ...state.transactions]),
        );
      }
      return true;
    } on Exception {
      return false;
    }
  }

  /// Deletes a transaction. Returns `true` on success.
  Future<bool> delete(int transactionId) async {
    try {
      await _repository.delete(transactionId);
      if (!isClosed) {
        emit(
          state.copyWith(
            transactions: state.transactions
                .where((transaction) => transaction.id != transactionId)
                .toList(),
          ),
        );
      }
      return true;
    } on Exception {
      return false;
    }
  }

  /// Loads the P&L report for the period. Returns `true` on success.
  Future<bool> loadReport(DateTime from, DateTime to) async {
    try {
      final report = await _repository.profitLoss(from, to);
      if (!isClosed) {
        emit(state.copyWith(report: report));
      }
      return true;
    } on Exception {
      return false;
    }
  }

  /// Exports transactions as CSV. Returns `null` on failure.
  Future<String?> exportCsv({
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      return await _repository.exportCsv(type: type, from: from, to: to);
    } on Exception {
      return null;
    }
  }
}
