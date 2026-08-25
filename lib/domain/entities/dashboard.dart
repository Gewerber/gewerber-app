import 'package:equatable/equatable.dart';

import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';

/// Income and expense totals of a single calendar month.
///
/// [monthStart] is the first day of the month (local wall clock, midnight).
class MonthlyFinancials extends Equatable {
  const MonthlyFinancials({
    required this.monthStart,
    required this.incomeCents,
    required this.expenseCents,
  });

  /// First day of the represented month.
  final DateTime monthStart;

  final int incomeCents;

  final int expenseCents;

  /// Profit of the month (income minus expenses).
  int get profitCents => incomeCents - expenseCents;

  @override
  List<Object?> get props => [monthStart, incomeCents, expenseCents];
}

/// One event of the dashboard's recent activity feed.
///
/// Subclasses are ordered by [at] (newest first) by the repository.
sealed class RecentActivityItem extends Equatable {
  const RecentActivityItem({required this.at});

  /// When the event happened; used for ordering the feed.
  final DateTime at;

  @override
  List<Object?> get props => [at];
}

/// An invoice was created or changed.
class InvoiceActivity extends RecentActivityItem {
  const InvoiceActivity({required this.invoice, required super.at});

  final Invoice invoice;

  @override
  List<Object?> get props => [...super.props, invoice];
}

/// Time was tracked (a manual entry was created or a timer stopped).
class TimeActivity extends RecentActivityItem {
  const TimeActivity({required this.minutes, required super.at, this.project});

  /// Tracked duration in minutes.
  final int minutes;

  /// Name of the project the time was tracked on, when known.
  final String? project;

  @override
  List<Object?> get props => [...super.props, minutes, project];
}

/// An income or expense transaction was recorded.
class TransactionActivity extends RecentActivityItem {
  /// Not `const`: [at] is derived from the transaction's occurrence date.
  TransactionActivity({required this.transaction})
    : super(at: transaction.occurredAt);

  final AccountingTransaction transaction;

  @override
  List<Object?> get props => [...super.props, transaction];
}

/// One aggregation line of outstanding receivables per customer.
///
/// Lines without a displayable customer ([displayName] is `null`) — no
/// customer assigned, a detached customer row or a nameless one — render a
/// localized "no customer" label in the UI.
class DebtorLine extends Equatable {
  const DebtorLine({
    required this.customerId,
    required this.displayName,
    required this.outstandingCents,
    required this.invoiceCount,
  });

  /// Customer these open invoices belong to, `null` when the invoices have no
  /// customer assigned.
  final int? customerId;

  /// Display name of the customer (company name if present, otherwise the
  /// contact name); `null` when there is no displayable name.
  final String? displayName;

  /// Sum of open invoice totals.
  final int outstandingCents;

  /// Number of open invoices of this customer.
  final int invoiceCount;

  @override
  List<Object?> get props => [
    customerId,
    displayName,
    outstandingCents,
    invoiceCount,
  ];
}

/// Open (sent + overdue) receivables of the business.
class ReceivablesSummary extends Equatable {
  const ReceivablesSummary({
    required this.outstandingTotalCents,
    required this.debtors,
    required this.overdueInvoices,
  });

  /// Total amount of all sent and overdue invoices.
  final int outstandingTotalCents;

  /// Outstanding amounts grouped per customer, sorted by amount descending.
  final List<DebtorLine> debtors;

  /// Overdue invoices sorted by due date ascending (most urgent first).
  final List<Invoice> overdueInvoices;

  @override
  List<Object?> get props => [outstandingTotalCents, debtors, overdueInvoices];
}

/// Aggregated dashboard data assembled from several modules.
class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.months,
    required this.activity,
    required this.receivables,
    required this.generatedAt,
  });

  /// Monthly income/expense totals, oldest month first.
  ///
  /// Empty when the summary carries no trend data.
  final List<MonthlyFinancials> months;

  /// Most recent events across invoicing, accounting and time tracking,
  /// newest first.
  final List<RecentActivityItem> activity;

  final ReceivablesSummary receivables;

  /// When the summary was assembled.
  final DateTime generatedAt;

  @override
  List<Object?> get props => [months, activity, receivables, generatedAt];
}
