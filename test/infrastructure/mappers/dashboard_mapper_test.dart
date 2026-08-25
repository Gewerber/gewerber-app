import 'package:flutter_test/flutter_test.dart';
import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;

import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/infrastructure/mappers/dashboard_mapper.dart';
import 'package:gewerber_app/infrastructure/mappers/invoice_mapper.dart';
import 'package:gewerber_app/infrastructure/mappers/transaction_mapper.dart';

void main() {
  const mapper = DashboardMapper(InvoiceMapper(), TransactionMapper());

  final asOf = DateTime.utc(2026, 8, 24, 9);

  sdk.Invoice invoice({
    int id = 1,
    String number = 'RE-2026-001',
    DateTime? issueDate,
    int totalCents = 10000,
  }) => sdk.Invoice(
    id: id,
    businessId: 1,
    number: number,
    status: sdk.InvoiceStatus.sent,
    issueDate: issueDate ?? DateTime.utc(2026, 8, 20),
    totalCents: totalCents,
  );

  sdk.RecentTimeEntry entry({
    int id = 1,
    required DateTime startedAt,
    DateTime? stoppedAt,
    int? durationMinutes,
    String? projectName,
  }) => sdk.RecentTimeEntry(
    id: id,
    startedAt: startedAt,
    stoppedAt: stoppedAt,
    durationMinutes: durationMinutes,
    billable: true,
    projectId: projectName == null ? null : 7,
    projectName: projectName,
  );

  sdk.DashboardSummary summary({
    List<sdk.MonthlyTrendPoint> trend = const [],
    List<sdk.Invoice> invoices = const [],
    List<sdk.AccountingTransaction> transactions = const [],
    List<sdk.RecentTimeEntry> timeEntries = const [],
    sdk.ReceivablesSummary? receivables,
  }) => sdk.DashboardSummary(
    generatedAt: asOf,
    asOf: asOf,
    trendFrom: DateTime.utc(2026, 3, 1),
    trendTo: DateTime.utc(2026, 8, 31),
    kpis: sdk.DashboardKpis(
      periodFrom: DateTime.utc(2026, 8, 1),
      periodTo: DateTime.utc(2026, 8, 31),
      incomeCents: 0,
      expenseCents: 0,
      profitCents: 0,
      totalMinutes: 0,
      billableMinutes: 0,
      roundedMinutes: 0,
    ),
    monthlyTrend: trend,
    recentInvoices: invoices,
    recentTransactions: transactions,
    recentTimeEntries: timeEntries,
    receivables:
        receivables ??
        sdk.ReceivablesSummary(
          openInvoicesCount: 0,
          openTotalCents: 0,
          overdueCount: 0,
          overdueTotalCents: 0,
          debtors: [],
          overdueInvoices: [],
        ),
  );

  group('monthsFromModel', () {
    test('passes month starts and cent amounts through unchanged', () {
      final model = summary(
        trend: [
          sdk.MonthlyTrendPoint(
            monthStart: DateTime.utc(2026, 7, 1),
            incomeCents: 123456,
            expenseCents: 2345,
            profitCents: 121111,
          ),
          sdk.MonthlyTrendPoint(
            monthStart: DateTime.utc(2026, 8, 1),
            incomeCents: 100000,
            expenseCents: 99999,
            profitCents: 1,
          ),
        ],
      );

      final months = mapper.monthsFromModel(model);

      expect(months, hasLength(2));
      expect(months[0].monthStart, DateTime.utc(2026, 7, 1));
      expect(months[0].incomeCents, 123456);
      expect(months[0].expenseCents, 2345);
      expect(months[0].profitCents, 121111);
      expect(months[1].monthStart, DateTime.utc(2026, 8, 1));
      expect(months[1].profitCents, 1);
    });
  });

  group('activityFromModel', () {
    test('maps all three sealed activity variants', () {
      final model = summary(
        invoices: [invoice(number: 'RE-2026-041')],
        transactions: [
          sdk.AccountingTransaction(
            id: 3,
            businessId: 1,
            type: sdk.TransactionType.income,
            category: sdk.TransactionCategory.salesRevenue,
            occurredAt: DateTime.utc(2026, 8, 18),
            amountCents: 15000,
          ),
        ],
        timeEntries: [
          entry(
            startedAt: DateTime.utc(2026, 8, 19, 10),
            stoppedAt: DateTime.utc(2026, 8, 19, 12, 5),
            durationMinutes: 125,
            projectName: 'Website',
          ),
        ],
      );

      final activity = mapper.activityFromModel(model);

      expect(activity, hasLength(3));
      expect(
        activity.whereType<InvoiceActivity>().single.invoice.number,
        'RE-2026-041',
      );
      final time = activity.whereType<TimeActivity>().single;
      // Minutes come straight from the server's durationMinutes.
      expect(time.minutes, 125);
      expect(time.project, 'Website');
      expect(activity.whereType<TransactionActivity>().isNotEmpty, isTrue);
    });

    test('skips still-running entries without a duration', () {
      final model = summary(
        timeEntries: [
          entry(startedAt: DateTime.utc(2026, 8, 19, 10)),
          entry(
            id: 2,
            startedAt: DateTime.utc(2026, 8, 18, 8),
            stoppedAt: DateTime.utc(2026, 8, 18, 9),
            durationMinutes: 60,
          ),
        ],
      );

      final activity = mapper.activityFromModel(model);

      final running = activity.whereType<TimeActivity>().toList();
      expect(running, hasLength(1));
      expect(running.single.minutes, 60);
    });

    test('sorts the merged feed newest first', () {
      final model = summary(
        invoices: [invoice(issueDate: DateTime.utc(2026, 8, 20))],
        timeEntries: [
          entry(
            startedAt: DateTime.utc(2026, 8, 21, 8),
            stoppedAt: DateTime.utc(2026, 8, 21, 9),
            durationMinutes: 60,
          ),
        ],
      );

      final activity = mapper.activityFromModel(model);

      expect(activity.first, isA<TimeActivity>());
      expect(activity.last, isA<InvoiceActivity>());
    });
  });

  group('receivablesFromModel', () {
    test('passes cents and counts and keeps null customer names nullable', () {
      final overdue = invoice(
        number: 'RE-2026-041',
        issueDate: DateTime.utc(2026, 7, 2),
        totalCents: 250000,
      );
      final dto = sdk.ReceivablesSummary(
        openInvoicesCount: 3,
        openTotalCents: 320000,
        overdueCount: 1,
        overdueTotalCents: 80000,
        debtors: [
          sdk.DebtorSummary(
            customerId: 1,
            customerName: 'Alpha GmbH',
            openCount: 2,
            openTotalCents: 200000,
            overdueTotalCents: 0,
          ),
          // "No customer" bucket: both ids stay null.
          sdk.DebtorSummary(
            customerId: null,
            customerName: null,
            openCount: 1,
            openTotalCents: 80000,
            overdueTotalCents: 80000,
          ),
        ],
        overdueInvoices: [overdue],
      );

      final receivables = mapper.receivablesFromModel(dto);

      expect(receivables.outstandingTotalCents, 320000);
      expect(receivables.debtors, hasLength(2));

      final named = receivables.debtors[0];
      expect(named.customerId, 1);
      expect(named.displayName, 'Alpha GmbH');
      expect(named.outstandingCents, 200000);
      expect(named.invoiceCount, 2);

      final anonymous = receivables.debtors[1];
      expect(anonymous.customerId, isNull);
      expect(anonymous.displayName, isNull);
      expect(anonymous.invoiceCount, 1);

      expect(receivables.overdueInvoices.single.number, 'RE-2026-041');
    });
  });

  group('summaryFromModel', () {
    test('assembles every section from one response', () {
      final model = summary(
        trend: [
          sdk.MonthlyTrendPoint(
            monthStart: DateTime.utc(2026, 8, 1),
            incomeCents: 500000,
            expenseCents: 200000,
            profitCents: 300000,
          ),
        ],
        invoices: [invoice()],
        receivables: sdk.ReceivablesSummary(
          openInvoicesCount: 1,
          openTotalCents: 10000,
          overdueCount: 0,
          overdueTotalCents: 0,
          debtors: [
            sdk.DebtorSummary(
              customerId: 1,
              customerName: 'Alpha GmbH',
              openCount: 1,
              openTotalCents: 10000,
              overdueTotalCents: 0,
            ),
          ],
          overdueInvoices: [],
        ),
      );

      final result = mapper.summaryFromModel(model);

      expect(result.months.single.incomeCents, 500000);
      expect(result.activity, hasLength(1));
      expect(result.receivables.debtors.single.displayName, 'Alpha GmbH');
      expect(result.generatedAt, asOf);
    });
  });
}
