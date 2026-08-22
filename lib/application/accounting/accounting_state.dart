import 'package:equatable/equatable.dart';

import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';

/// Loading state of the transactions view.
enum AccountingViewStatus { initial, loading, loaded, failure }

/// Immutable accounting state (transactions + P&L report).
class AccountingState extends Equatable {
  const AccountingState({
    this.status = AccountingViewStatus.initial,
    this.transactions = const [],
    this.report,
    this.failure,
  });

  final AccountingViewStatus status;
  final List<AccountingTransaction> transactions;

  /// The last loaded profit & loss report, if any.
  final ProfitLossReport? report;

  final Failure? failure;

  bool get isLoading => status == AccountingViewStatus.loading;

  AccountingState copyWith({
    AccountingViewStatus? status,
    List<AccountingTransaction>? transactions,
    Object? report = _sentinel,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return AccountingState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      report: report is ProfitLossReport? ? report : this.report,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, transactions, report, failure];
}

const Object _sentinel = Object();
