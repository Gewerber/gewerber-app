import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/dashboard/dashboard_cubit.dart';
import 'package:gewerber_app/application/dashboard/dashboard_state.dart';
import 'package:gewerber_app/core/theme/gewerber_colors.dart';
import 'package:gewerber_app/core/theme/gewerber_tokens.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/common/section_card.dart';

/// Dashboard section with the most recent events across invoicing, time
/// tracking and accounting. Tapping an entry opens the related module.
class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<DashboardCubit>().state;

    return SectionCard(
      title: l10n.dashboardRecentActivityTitle,
      accentColor: GewerberColors.accentDark,
      child: switch (state.activityStatus) {
        DashboardSectionStatus.initial ||
        DashboardSectionStatus.loading => const SectionCardLoading(),
        DashboardSectionStatus.failure => SectionCardError(
          onRetry: () => context.read<DashboardCubit>().loadActivity(),
        ),
        DashboardSectionStatus.loaded when state.activity.isEmpty => Text(
          l10n.dashboardRecentActivityEmpty,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        DashboardSectionStatus.loaded => Column(
          children: [
            for (final (index, item) in state.activity.indexed) ...[
              if (index > 0) const Divider(height: GewerberTokens.space16),
              _ActivityTile(item: item),
            ],
          ],
        ),
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});

  final RecentActivityItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    final (icon, title, subtitle, trailing, onTap) = switch (item) {
      InvoiceActivity(:final invoice) => (
        Icons.receipt_long_outlined,
        l10n.dashboardActivityInvoiceCreated(invoice.number),
        null,
        formatCents(invoice.totalCents),
        () => context.push(RouteNames.invoiceDetail, extra: invoice),
      ),
      TimeActivity(:final minutes, :final project) => (
        Icons.timer_outlined,
        l10n.dashboardActivityTimeTracked(formatMinutes(minutes)),
        project,
        null,
        () => context.go(RouteNames.timeReport),
      ),
      TransactionActivity(:final transaction) => (
        Icons.account_balance_wallet_outlined,
        l10n.dashboardActivityTransaction,
        transaction.description,
        (transaction.type == TransactionType.income ? '+' : '-') +
            formatCents(transaction.amountCents),
        () => context.push(RouteNames.accountingEntryEdit, extra: transaction),
      ),
    };

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, size: 20, color: colors.onSurfaceVariant),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
      trailing: trailing == null
          ? null
          : Text(
              trailing,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
      onTap: onTap,
    );
  }
}
