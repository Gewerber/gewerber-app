import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/accounting/accounting_cubit.dart';
import 'package:gewerber_app/application/dashboard/dashboard_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_state.dart';
import 'package:gewerber_app/application/time_tracking/time_entries_cubit.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/common/section_card.dart';
import 'package:gewerber_app/presentation/widgets/dashboard/profit_change.dart';
import 'package:gewerber_app/presentation/widgets/dashboard/recent_activity_card.dart';
import 'package:gewerber_app/presentation/widgets/dashboard/receivables_card.dart';
import 'package:gewerber_app/presentation/widgets/dashboard/trends_section_card.dart';

/// Breakpoint at which the dashboard switches from a single column to the
/// two-column layout (tablet landscape / desktop).
const double _twoColumnBreakpoint = 900;

/// DashboardScreen — overview of open invoices, this month's P&L and tracked
/// time, with quick actions into the modules, plus the v2 sections (trends,
/// recent activity, receivables) loaded through [DashboardCubit].
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// Whether the last P&L load succeeded (its cubit reports success via
  /// return value, not via state).
  bool _plOk = false;

  /// Whether the last time-report load succeeded.
  bool _timeOk = false;

  @override
  void initState() {
    super.initState();
    _load();
    // v2 sections load independently of the legacy cubits.
    context.read<DashboardCubit>().loadAll();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    // First day of the current month to the last day, inclusive.
    final from = DateTime(now.year, now.month);
    final to = DateTime(now.year, now.month + 1, 0, 23, 59);

    final invoiceCubit = context.read<InvoiceCubit>();
    final accountingCubit = context.read<AccountingCubit>();
    final timeCubit = context.read<TimeEntriesCubit>();

    // Fire all three concurrently; the invoice cubit surfaces failures in its
    // own state, the two report loads report success by return value.
    final plFuture = accountingCubit.loadReport(from, to);
    final timeFuture = timeCubit.loadReport(from, to);
    await invoiceCubit.load();
    final plOk = await plFuture;
    final timeOk = await timeFuture;

    if (!mounted) return;
    setState(() {
      _plOk = plOk;
      _timeOk = timeOk;
    });
  }

  /// Pull-to-refresh reloads the v1 data and every dashboard section.
  Future<void> _refreshAll() {
    return Future.wait([_load(), context.read<DashboardCubit>().loadAll()]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeDashboard)),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= _twoColumnBreakpoint;
            final openInvoices = _OpenInvoicesSection(onRetry: _load);
            final monthResult = _MonthResultSection(ok: _plOk, onRetry: _load);
            final trackedTime = _TrackedTimeSection(
              ok: _timeOk,
              onRetry: _load,
            );
            const trends = TrendsSectionCard();
            const activity = RecentActivityCard();
            const receivables = ReceivablesCard();

            return ListView(
              padding: const EdgeInsets.all(GewerberTokens.space16),
              children: [
                Text(
                  l10n.dashboardQuickActions,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: GewerberTokens.space8),
                _QuickActions(),
                const SizedBox(height: GewerberTokens.space16),
                if (wide) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: openInvoices),
                      const SizedBox(width: GewerberTokens.space12),
                      Expanded(child: monthResult),
                    ],
                  ),
                  const SizedBox(height: GewerberTokens.space12),
                  trackedTime,
                  const SizedBox(height: GewerberTokens.space12),
                  trends,
                  const SizedBox(height: GewerberTokens.space12),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: RecentActivityCard()),
                      SizedBox(width: GewerberTokens.space12),
                      Expanded(child: ReceivablesCard()),
                    ],
                  ),
                ] else ...[
                  openInvoices,
                  const SizedBox(height: GewerberTokens.space12),
                  monthResult,
                  const SizedBox(height: GewerberTokens.space12),
                  trackedTime,
                  const SizedBox(height: GewerberTokens.space12),
                  trends,
                  const SizedBox(height: GewerberTokens.space12),
                  activity,
                  const SizedBox(height: GewerberTokens.space12),
                  receivables,
                ],
                const SizedBox(height: GewerberTokens.space32),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Quick actions into the modules.
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: GewerberTokens.space8,
      runSpacing: GewerberTokens.space8,
      children: [
        FilledButton.icon(
          onPressed: () => context.push(RouteNames.invoiceCreate),
          icon: const Icon(Icons.receipt_long_outlined),
          label: Text(l10n.dashboardActionNewInvoice),
        ),
        FilledButton.tonalIcon(
          onPressed: () => context.push(RouteNames.timeTimer),
          icon: const Icon(Icons.timer_outlined),
          label: Text(l10n.dashboardActionTimer),
        ),
        FilledButton.tonalIcon(
          onPressed: () => context.push(RouteNames.accountingEntryCreate),
          icon: const Icon(Icons.account_balance_wallet_outlined),
          label: Text(l10n.dashboardActionTransaction),
        ),
      ],
    );
  }
}

/// Open invoices: outstanding total plus open/overdue/draft counts.
class _OpenInvoicesSection extends StatelessWidget {
  const _OpenInvoicesSection({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<InvoiceCubit>().state;

    return SectionCard(
      title: l10n.dashboardOpenInvoicesTitle,
      onTap: () => context.go(RouteNames.invoicing),
      accentColor: Theme.of(context).colorScheme.primary,
      child: switch (state.status) {
        InvoiceViewStatus.initial ||
        InvoiceViewStatus.loading => const SectionCardLoading(),
        InvoiceViewStatus.failure => SectionCardError(onRetry: onRetry),
        InvoiceViewStatus.loaded => _InvoicesBody(state: state),
      },
    );
  }
}

class _InvoicesBody extends StatelessWidget {
  const _InvoicesBody({required this.state});

  final InvoiceState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final invoices = state.invoices;
    final open = invoices
        .where(
          (invoice) =>
              invoice.status == InvoiceStatus.sent ||
              invoice.status == InvoiceStatus.overdue,
        )
        .toList();
    final outstandingCents = open.fold<int>(
      0,
      (sum, inv) => sum + inv.totalCents,
    );
    final overdueCount = invoices
        .where((inv) => inv.status == InvoiceStatus.overdue)
        .length;
    final draftCount = invoices.where((inv) => inv.isDraft).length;

    if (open.isEmpty && draftCount == 0) {
      return Text(
        l10n.dashboardOutstandingEmpty,
        style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formatCents(outstandingCents), style: textTheme.headlineSmall),
        const SizedBox(height: GewerberTokens.space8),
        Wrap(
          spacing: GewerberTokens.space8,
          runSpacing: GewerberTokens.space4,
          children: [
            SectionBadge(
              label: l10n.dashboardInvoicesOpenCount(open.length),
              color: colors.primary,
            ),
            if (overdueCount > 0)
              SectionBadge(
                label: l10n.dashboardInvoicesOverdueCount(overdueCount),
                color: colors.error,
              ),
            if (draftCount > 0)
              SectionBadge(
                label: l10n.dashboardInvoicesDraftCount(draftCount),
                color: colors.onSurfaceVariant,
              ),
          ],
        ),
      ],
    );
  }
}

/// This month's P&L: income, expenses, profit plus the trend delta badge.
class _MonthResultSection extends StatelessWidget {
  const _MonthResultSection({required this.ok, required this.onRetry});

  final bool ok;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final report = context.watch<AccountingCubit>().state.report;
    final trendMonths = context.watch<DashboardCubit>().state.months;

    return SectionCard(
      title: l10n.dashboardMonthTitle,
      onTap: () => context.go(RouteNames.accounting),
      accentColor: GewerberColors.accent,
      child: switch ((report, ok)) {
        (final report?, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AmountRow(
              entries: [
                (
                  l10n.reportIncome,
                  formatCents(report.incomeCents),
                  Theme.of(context).colorScheme.primary,
                ),
                (
                  l10n.reportExpenses,
                  formatCents(report.expenseCents),
                  Theme.of(context).colorScheme.error,
                ),
                (l10n.reportProfit, formatCents(report.profitCents), null),
              ],
            ),
            _TrendDeltaBadge(months: trendMonths),
          ],
        ),
        (null, true) => SectionCardError(onRetry: onRetry),
        (null, false) => const SectionCardLoading(),
      },
    );
  }
}

/// Compact Δ% badge fed by the dashboard trends section; hidden until the
/// trend data is available.
class _TrendDeltaBadge extends StatelessWidget {
  const _TrendDeltaBadge({required this.months});

  final List<MonthlyFinancials> months;

  @override
  Widget build(BuildContext context) {
    final change = profitChangePercent(
      months,
      Localizations.localeOf(context).toString(),
    );
    if (change == null) return const SizedBox.shrink();
    final tone = changeTone(change);

    return Padding(
      padding: const EdgeInsets.only(top: GewerberTokens.space8),
      child: SectionBadge(
        label: AppLocalizations.of(context).dashboardChangeVsPrevious(change),
        color: switch (tone) {
          ChangeTone.positive => GewerberColors.success,
          ChangeTone.negative => GewerberColors.error,
          // A flat month is neither up nor down; render it muted.
          ChangeTone.neutral => Theme.of(context).colorScheme.onSurfaceVariant,
        },
      ),
    );
  }
}

/// Tracked time of the current month: total and billable share.
class _TrackedTimeSection extends StatelessWidget {
  const _TrackedTimeSection({required this.ok, required this.onRetry});

  final bool ok;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final report = context.watch<TimeEntriesCubit>().state.report;

    return SectionCard(
      title: l10n.dashboardTrackedTimeTitle,
      onTap: () => context.go(RouteNames.timeTracking),
      accentColor: GewerberColors.accentDark,
      child: switch ((report, ok)) {
        (final report?, _) when report.totalMinutes > 0 => _AmountRow(
          entries: [
            (l10n.timeReportTotal, formatMinutes(report.totalMinutes), null),
            (
              l10n.timeReportBillable,
              formatMinutes(report.billableMinutes),
              Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        (null, true) => SectionCardError(onRetry: onRetry),
        (null, false) => const SectionCardLoading(),
        _ => Text(
          l10n.timeReportEmpty,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      },
    );
  }
}

/// A labelled value row used inside section cards.
class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.entries});

  /// Entries of (label, value, optional accent color).
  final List<(String, String, Color?)> entries;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        for (final (index, entry) in entries.indexed) ...[
          if (index > 0) const SizedBox(width: GewerberTokens.space12),
          Expanded(
            child: MergeSemantics(
              child: entry.$3 != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GewerberTokens.space8,
                        vertical: GewerberTokens.space6,
                      ),
                      decoration: BoxDecoration(
                        color: entry.$3!.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                          GewerberTokens.radiusButton,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.$1,
                            style: textTheme.bodySmall?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: GewerberTokens.space2),
                          Text(
                            entry.$2,
                            style: textTheme.titleMedium?.copyWith(
                              color: entry.$3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.$1,
                          style: textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: GewerberTokens.space2),
                        Text(
                          entry.$2,
                          style: textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ],
    );
  }
}
