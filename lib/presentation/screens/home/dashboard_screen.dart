import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/accounting/accounting_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_state.dart';
import 'package:gewerber_app/application/time_tracking/time_entries_cubit.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';

/// DashboardScreen — overview of open invoices, this month's P&L and tracked
/// time, with quick actions into the modules.
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeDashboard)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(GewerberTokens.space16),
          children: [
            Text(
              l10n.dashboardQuickActions,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: GewerberTokens.space8),
            Wrap(
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
                  onPressed: () =>
                      context.push(RouteNames.accountingEntryCreate),
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  label: Text(l10n.dashboardActionTransaction),
                ),
              ],
            ),
            const SizedBox(height: GewerberTokens.space16),
            _OpenInvoicesSection(onRetry: _load),
            const SizedBox(height: GewerberTokens.space12),
            _MonthResultSection(ok: _plOk, onRetry: _load),
            const SizedBox(height: GewerberTokens.space12),
            _TrackedTimeSection(ok: _timeOk, onRetry: _load),
            const SizedBox(height: GewerberTokens.space32),
          ],
        ),
      ),
    );
  }
}

/// Shell for a dashboard section card with an optional tap-through target.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.onTap});

  final String title;
  final Widget child;

  /// When set, the whole card navigates to the module on tap.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(GewerberTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                ],
              ),
              const SizedBox(height: GewerberTokens.space12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline loading placeholder of a section body.
class _SectionLoading extends StatelessWidget {
  const _SectionLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: GewerberTokens.space16),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

/// Inline error of a section body with a retry action.
class _SectionError extends StatelessWidget {
  const _SectionError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dashboardLoadError,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
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

    return _SectionCard(
      title: l10n.dashboardOpenInvoicesTitle,
      onTap: () => context.go(RouteNames.invoicing),
      child: switch (state.status) {
        InvoiceViewStatus.initial ||
        InvoiceViewStatus.loading => const _SectionLoading(),
        InvoiceViewStatus.failure => _SectionError(onRetry: onRetry),
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
            _Badge(
              label: l10n.dashboardInvoicesOpenCount(open.length),
              color: colors.primary,
            ),
            if (overdueCount > 0)
              _Badge(
                label: l10n.dashboardInvoicesOverdueCount(overdueCount),
                color: colors.error,
              ),
            if (draftCount > 0)
              _Badge(
                label: l10n.dashboardInvoicesDraftCount(draftCount),
                color: colors.onSurfaceVariant,
              ),
          ],
        ),
      ],
    );
  }
}

/// This month's P&L: income, expenses and profit.
class _MonthResultSection extends StatelessWidget {
  const _MonthResultSection({required this.ok, required this.onRetry});

  final bool ok;

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final report = context.watch<AccountingCubit>().state.report;

    return _SectionCard(
      title: l10n.dashboardMonthTitle,
      onTap: () => context.go(RouteNames.accounting),
      child: switch ((report, ok)) {
        (final report?, _) => _AmountRow(
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
        (null, true) => _SectionError(onRetry: onRetry),
        (null, false) => const _SectionLoading(),
      },
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

    return _SectionCard(
      title: l10n.dashboardTrackedTimeTitle,
      onTap: () => context.go(RouteNames.timeTracking),
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
        (null, true) => _SectionError(onRetry: onRetry),
        (null, false) => const _SectionLoading(),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.$1,
                  style: textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: GewerberTokens.space2),
                Text(
                  entry.$2,
                  style: textTheme.titleMedium?.copyWith(color: entry.$3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Small rounded count badge used in the invoice summary.
class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GewerberTokens.space8,
        vertical: GewerberTokens.space2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GewerberTokens.radiusChip),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
