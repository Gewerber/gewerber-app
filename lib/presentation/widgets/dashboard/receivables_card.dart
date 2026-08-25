import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/dashboard/dashboard_cubit.dart';
import 'package:gewerber_app/application/dashboard/dashboard_state.dart';
import 'package:gewerber_app/core/theme/gewerber_tokens.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/common/section_card.dart';

/// Maximum number of debtors and overdue invoices shown on the dashboard;
/// the full lists live in the invoicing module.
const int _maxDebtors = 3;
const int _maxOverdue = 3;

/// Dashboard section with open receivables: total, top debtors and the most
/// urgent overdue invoices.
class ReceivablesCard extends StatelessWidget {
  const ReceivablesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<DashboardCubit>().state;

    return SectionCard(
      title: l10n.dashboardReceivablesTitle,
      // The full debtor list lives in the customers module; push it so the
      // dashboard stays underneath.
      onTap: () => context.push(RouteNames.customers),
      child: switch (state.receivablesStatus) {
        DashboardSectionStatus.initial ||
        DashboardSectionStatus.loading => const SectionCardLoading(),
        DashboardSectionStatus.failure => SectionCardError(
          onRetry: () => context.read<DashboardCubit>().loadReceivables(),
        ),
        DashboardSectionStatus.loaded => _ReceivablesBody(
          receivables: state.receivables,
        ),
      },
    );
  }
}

class _ReceivablesBody extends StatelessWidget {
  const _ReceivablesBody({required this.receivables});

  final ReceivablesSummary? receivables;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = receivables;

    if (summary == null || summary.debtors.isEmpty) {
      return Text(
        l10n.dashboardReceivablesEmpty,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatCents(summary.outstandingTotalCents),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: GewerberTokens.space8),
        for (final (index, debtor)
            in summary.debtors.take(_maxDebtors).indexed) ...[
          if (index > 0) const SizedBox(height: GewerberTokens.space4),
          _DebtorRow(debtor: debtor),
        ],
        // "View all" hint when more debtors exist than are shown.
        if (summary.debtors.length > _maxDebtors)
          Padding(
            padding: const EdgeInsets.only(top: GewerberTokens.space4),
            child: Text(
              l10n.dashboardViewAll,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        const Divider(height: GewerberTokens.space24),
        Text(
          l10n.dashboardOverdueTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: GewerberTokens.space8),
        if (summary.overdueInvoices.isEmpty)
          Text(
            l10n.dashboardNoOverdue,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          )
        else
          for (final (index, invoice)
              in summary.overdueInvoices.take(_maxOverdue).indexed) ...[
            if (index > 0) const SizedBox(height: GewerberTokens.space4),
            _OverdueRow(invoice: invoice),
          ],
      ],
    );
  }
}

/// One debtor line: display name plus outstanding amount and invoice count.
class _DebtorRow extends StatelessWidget {
  const _DebtorRow({required this.debtor});

  final DebtorLine debtor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    // Invoices without a customer assignment render a localized fallback.
    final name = debtor.displayName.isEmpty
        ? l10n.invoiceNoCustomer
        : debtor.displayName;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(
                l10n.dashboardDebtorInvoicesCount(debtor.invoiceCount),
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Text(
          formatCents(debtor.outstandingCents),
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// One overdue invoice line that opens the invoice detail screen.
class _OverdueRow extends StatelessWidget {
  const _OverdueRow({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(GewerberTokens.radiusButton),
      onTap: () => context.push(RouteNames.invoiceDetail, extra: invoice),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: GewerberTokens.space2),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invoice.number,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.dashboardDueOn(invoice.dueDate ?? invoice.issueDate),
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: GewerberTokens.space8),
            Text(formatCents(invoice.totalCents)),
            const SizedBox(width: GewerberTokens.space8),
            SectionBadge(
              label: l10n.dashboardOverdueTitle,
              color: colors.error,
            ),
          ],
        ),
      ),
    );
  }
}
