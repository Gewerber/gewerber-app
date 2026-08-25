import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/infrastructure/mappers/invoice_mapper.dart';
import 'package:gewerber_app/infrastructure/mappers/transaction_mapper.dart';

/// Maps the server-side dashboard summary onto the domain entities.
@injectable
class DashboardMapper {
  const DashboardMapper(this._invoices, this._transactions);

  final InvoiceMapper _invoices;
  final TransactionMapper _transactions;

  /// Monthly income/expense totals of the trend window, oldest month first.
  List<MonthlyFinancials> monthsFromModel(sdk.DashboardSummary model) => [
    for (final point in model.monthlyTrend)
      MonthlyFinancials(
        monthStart: point.monthStart,
        incomeCents: point.incomeCents,
        expenseCents: point.expenseCents,
      ),
  ];

  /// Merged activity feed across invoicing, accounting and time tracking,
  /// newest first — mirroring the client-side composition it replaces.
  ///
  /// Still-running time entries have no duration yet and never enter the
  /// feed, exactly like in `CompositeDashboardRepository`.
  List<RecentActivityItem> activityFromModel(sdk.DashboardSummary model) {
    final items = <RecentActivityItem>[
      for (final invoice in model.recentInvoices)
        InvoiceActivity(
          invoice: _invoices.fromModel(invoice),
          at: invoice.issueDate,
        ),
      for (final transaction in model.recentTransactions)
        TransactionActivity(transaction: _transactions.fromModel(transaction)),
      for (final entry in model.recentTimeEntries)
        if (entry.stoppedAt != null && entry.durationMinutes != null)
          TimeActivity(
            minutes: entry.durationMinutes!,
            at: entry.startedAt,
            project: entry.projectName,
          ),
    ]..sort((a, b) => b.at.compareTo(a.at));
    return items;
  }

  /// One receivables line; a `null` [DebtorLine.displayName] means "no
  /// displayable customer" for the UI to replace with a localized label.
  DebtorLine debtorFromModel(sdk.DebtorSummary model) => DebtorLine(
    customerId: model.customerId,
    displayName: model.customerName,
    outstandingCents: model.openTotalCents,
    invoiceCount: model.openCount,
  );

  /// Open (sent + overdue) receivables of the business.
  ReceivablesSummary receivablesFromModel(sdk.ReceivablesSummary model) {
    return ReceivablesSummary(
      outstandingTotalCents: model.openTotalCents,
      debtors: [for (final debtor in model.debtors) debtorFromModel(debtor)],
      overdueInvoices: model.overdueInvoices.map(_invoices.fromModel).toList(),
    );
  }

  /// Assembles all dashboard sections from a single server response.
  DashboardSummary summaryFromModel(sdk.DashboardSummary model) {
    return DashboardSummary(
      months: monthsFromModel(model),
      activity: activityFromModel(model),
      receivables: receivablesFromModel(model.receivables),
      generatedAt: model.generatedAt,
    );
  }
}
