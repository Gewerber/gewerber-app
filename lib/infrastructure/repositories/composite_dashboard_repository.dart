import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/utils/month_math.dart';
import 'package:gewerber_app/domain/entities/customer.dart';
import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/domain/repositories/accounting_repository.dart';
import 'package:gewerber_app/domain/repositories/customer_repository.dart';
import 'package:gewerber_app/domain/repositories/dashboard_repository.dart';
import 'package:gewerber_app/domain/repositories/invoice_repository.dart';
import 'package:gewerber_app/domain/repositories/time_tracking_repository.dart';

/// Per-source fetch window for the activity feed before merging.
const int _activityFetchLimit = 20;

/// [DashboardRepository] that composes the existing module repositories.
///
/// No new server endpoints are required: trends come from monthly P&L
/// reports, activity from the recent invoices/transactions/time entries and
/// receivables from the open invoice lists plus one customer list.
@Deprecated('Replaced by server-side dashboard.getSummary; remove next release')
@LazySingleton(env: [AppEnvironment.authLive])
class CompositeDashboardRepository implements DashboardRepository {
  CompositeDashboardRepository(
    this._accounting,
    this._invoices,
    this._timeTracking,
    this._customers,
  );

  final AccountingRepository _accounting;
  final InvoiceRepository _invoices;
  final TimeTrackingRepository _timeTracking;
  final CustomerRepository _customers;

  @override
  Future<List<MonthlyFinancials>> monthlyFinancials({
    required int months,
    DateTime? anchor,
  }) async {
    final effectiveAnchor = anchor ?? DateTime.now();
    final count = months.clamp(1, DashboardRepository.maxTrendMonths);
    final starts = lastNMonthStarts(effectiveAnchor, count);

    // One P&L call per month; independent, so run them concurrently.
    final reports = await Future.wait([
      for (final start in starts)
        _accounting.profitLoss(start, monthEnd(start)),
    ]);

    return [
      for (final (index, report) in reports.indexed)
        MonthlyFinancials(
          monthStart: starts[index],
          incomeCents: report.incomeCents,
          expenseCents: report.expenseCents,
        ),
    ];
  }

  @override
  Future<List<RecentActivityItem>> recentActivity({
    int limit = DashboardRepository.defaultActivityLimit,
    DateTime? anchor,
  }) async {
    // Fetch each source with a small window; the merged feed is sorted
    // client-side because list orderings differ per module.
    final results = await Future.wait([
      _invoices.list(limit: _activityFetchLimit),
      _accounting.list(limit: _activityFetchLimit),
      _timeTracking.listEntries(limit: _activityFetchLimit),
      _timeTracking.listProjects(),
    ]);
    final invoices = results[0] as List<Invoice>;
    final transactions = results[1] as List<AccountingTransaction>;
    final entries = results[2] as List<TimeEntry>;
    final projects = results[3] as List<Project>;
    final projectNames = {
      for (final project in projects) project.id: project.name,
    };

    final items = <RecentActivityItem>[
      for (final invoice in invoices)
        InvoiceActivity(invoice: invoice, at: invoice.issueDate),
      for (final transaction in transactions)
        TransactionActivity(transaction: transaction),
      for (final entry in entries)
        if (!entry.isRunning && entry.durationMinutes != null)
          TimeActivity(
            minutes: entry.durationMinutes!,
            at: entry.startedAt,
            project: entry.projectId == null
                ? null
                : projectNames[entry.projectId],
          ),
    ]..sort((a, b) => b.at.compareTo(a.at));

    return items.take(limit).toList();
  }

  @override
  Future<ReceivablesSummary> receivables() async {
    final openInvoices = await Future.wait([
      _invoices.list(status: InvoiceStatus.sent),
      _invoices.list(status: InvoiceStatus.overdue),
      _customers.list(),
    ]);
    final sent = openInvoices[0] as List<Invoice>;
    final overdue = openInvoices[1] as List<Invoice>;
    final customers = openInvoices[2] as List<Customer>;

    final names = {for (final customer in customers) customer.id: customer};

    // Group the open invoices per customer; `null` groups invoices without
    // an assigned customer.
    final totals = <int?, ({int cents, int count})>{};
    for (final invoice in [...sent, ...overdue]) {
      final current = totals[invoice.customerId];
      totals[invoice.customerId] = (
        cents: (current?.cents ?? 0) + invoice.totalCents,
        count: (current?.count ?? 0) + 1,
      );
    }

    final debtors = [
      for (final entry in totals.entries)
        DebtorLine(
          customerId: entry.key,
          displayName: entry.key == null ? null : names[entry.key]?.displayName,
          outstandingCents: entry.value.cents,
          invoiceCount: entry.value.count,
        ),
    ]..sort((a, b) => b.outstandingCents.compareTo(a.outstandingCents));

    // Most urgent first; invoices without a due date fall back to the issue
    // date so they never drop out of the ordering.
    final overdueSorted = [...overdue]
      ..sort(
        (a, b) =>
            (a.dueDate ?? a.issueDate).compareTo(b.dueDate ?? b.issueDate),
      );

    return ReceivablesSummary(
      outstandingTotalCents: debtors.fold<int>(
        0,
        (sum, debtor) => sum + debtor.outstandingCents,
      ),
      debtors: debtors,
      overdueInvoices: overdueSorted,
    );
  }

  @override
  Future<DashboardSummary> summary({
    required int months,
    DateTime? anchor,
  }) async {
    final results = await Future.wait([
      monthlyFinancials(months: months, anchor: anchor),
      recentActivity(anchor: anchor),
      receivables(),
    ]);
    return DashboardSummary(
      months: results[0] as List<MonthlyFinancials>,
      activity: results[1] as List<RecentActivityItem>,
      receivables: results[2] as ReceivablesSummary,
      generatedAt: DateTime.now(),
    );
  }
}
