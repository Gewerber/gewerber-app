import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/utils/month_math.dart';
import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/domain/repositories/dashboard_repository.dart';

/// In-memory [DashboardRepository] backing the demo experience and the
/// widget tests.
///
/// All data is derived deterministically from [anchor] (default "now"), so
/// the same anchor always produces the same summary — golden tests and
/// screenshots stay stable.
@LazySingleton(as: DashboardRepository, env: [AppEnvironment.authMock])
class MockDashboardRepository implements DashboardRepository {
  @override
  Future<List<MonthlyFinancials>> monthlyFinancials({
    required int months,
    DateTime? anchor,
  }) async {
    final effectiveAnchor = anchor ?? DateTime.now();
    final starts = lastNMonthStarts(effectiveAnchor, months);
    return [
      // Deterministic pseudo-series: stable per index, independent of the
      // absolute calendar month.
      for (final (index, start) in starts.indexed)
        MonthlyFinancials(
          monthStart: start,
          incomeCents: 120000 + ((index * 37) % 8) * 15000,
          expenseCents: 60000 + ((index * 23) % 5) * 10000,
        ),
    ];
  }

  @override
  Future<List<RecentActivityItem>> recentActivity({
    int limit = DashboardRepository.defaultActivityLimit,
    DateTime? anchor,
  }) async {
    final now = anchor ?? DateTime.now();

    final items = <RecentActivityItem>[
      TimeActivity(
        minutes: 45,
        at: now.subtract(const Duration(hours: 3)),
        project: 'Website-Relaunch',
      ),
      InvoiceActivity(
        invoice: _invoice(
          id: 9014,
          number: 'RE-2026-14',
          status: InvoiceStatus.sent,
          customerId: 501,
          issueDate: now.subtract(const Duration(days: 1)),
          dueDate: now.add(const Duration(days: 13)),
          totalCents: 249800,
        ),
        at: now.subtract(const Duration(days: 1)),
      ),
      TransactionActivity(
        transaction: AccountingTransaction(
          id: 7021,
          type: TransactionType.income,
          category: TransactionCategory.salesRevenue,
          occurredAt: now.subtract(const Duration(days: 2)),
          amountCents: 85000,
          description: 'Anzahlung Müller GmbH',
        ),
      ),
      TransactionActivity(
        transaction: AccountingTransaction(
          id: 7020,
          type: TransactionType.expense,
          category: TransactionCategory.office,
          occurredAt: now.subtract(const Duration(days: 4)),
          amountCents: 4200,
          description: 'Büromaterial',
        ),
      ),
      InvoiceActivity(
        invoice: _invoice(
          id: 9013,
          number: 'RE-2026-13',
          status: InvoiceStatus.overdue,
          customerId: 502,
          issueDate: now.subtract(const Duration(days: 26)),
          dueDate: now.subtract(const Duration(days: 6)),
          totalCents: 149500,
        ),
        at: now.subtract(const Duration(days: 26)),
      ),
      TimeActivity(
        minutes: 210,
        at: now.subtract(const Duration(days: 27)),
        project: 'Steuererklärung',
      ),
    ]..sort((a, b) => b.at.compareTo(a.at));

    return items.take(limit).toList();
  }

  @override
  Future<ReceivablesSummary> receivables() async {
    // Truncate to midnight so repeated calls within one calendar day are
    // byte-identical (deterministic for golden tests).
    final today = DateTime.now();
    final now = DateTime(today.year, today.month, today.day);
    return ReceivablesSummary(
      outstandingTotalCents: 560800,
      debtors: const [
        DebtorLine(
          customerId: 501,
          displayName: 'Müller GmbH',
          outstandingCents: 337300,
          invoiceCount: 2,
        ),
        DebtorLine(
          customerId: 502,
          displayName: 'Schmidt & Co. KG',
          outstandingCents: 149500,
          invoiceCount: 1,
        ),
        DebtorLine(
          customerId: null,
          displayName: '',
          outstandingCents: 74000,
          invoiceCount: 1,
        ),
      ],
      overdueInvoices: [
        _invoice(
          id: 9013,
          number: 'RE-2026-13',
          status: InvoiceStatus.overdue,
          customerId: 502,
          issueDate: now.subtract(const Duration(days: 26)),
          dueDate: now.subtract(const Duration(days: 6)),
          totalCents: 149500,
        ),
        _invoice(
          id: 9011,
          number: 'RE-2026-11',
          status: InvoiceStatus.overdue,
          customerId: null,
          issueDate: now.subtract(const Duration(days: 42)),
          dueDate: now.subtract(const Duration(days: 12)),
          totalCents: 74000,
        ),
      ],
    );
  }

  @override
  Future<DashboardSummary> summary({
    required int months,
    DateTime? anchor,
  }) async {
    final effectiveAnchor = anchor ?? DateTime.now();
    final results = await Future.wait([
      monthlyFinancials(months: months, anchor: anchor),
      recentActivity(anchor: anchor),
      receivables(),
    ]);
    return DashboardSummary(
      months: results[0] as List<MonthlyFinancials>,
      activity: results[1] as List<RecentActivityItem>,
      receivables: results[2] as ReceivablesSummary,
      generatedAt: effectiveAnchor,
    );
  }
}

Invoice _invoice({
  required int id,
  required String number,
  required InvoiceStatus status,
  required int? customerId,
  required DateTime issueDate,
  DateTime? dueDate,
  required int totalCents,
}) {
  return Invoice(
    id: id,
    number: number,
    status: status,
    customerId: customerId,
    issueDate: issueDate,
    dueDate: dueDate,
    subtotalCents: totalCents,
    totalCents: totalCents,
  );
}
