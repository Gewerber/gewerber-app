import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/dashboard/dashboard_cubit.dart';
import 'package:gewerber_app/application/dashboard/dashboard_state.dart';
import 'package:gewerber_app/core/theme/gewerber_colors.dart';
import 'package:gewerber_app/core/theme/gewerber_tokens.dart';
import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/common/section_card.dart';
import 'package:gewerber_app/presentation/widgets/dashboard/month_bar_chart.dart';
import 'package:gewerber_app/presentation/widgets/dashboard/profit_change.dart';

/// Dashboard trends section: monthly income/expense bar chart plus the
/// month-over-month profit change.
class TrendsSectionCard extends StatelessWidget {
  const TrendsSectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<DashboardCubit>().state;

    return SectionCard(
      title: l10n.dashboardTrendsTitle,
      onTap: () => context.go(RouteNames.accountingReport),
      child: switch (state.trendsStatus) {
        DashboardSectionStatus.initial ||
        DashboardSectionStatus.loading => const SectionCardLoading(),
        DashboardSectionStatus.failure => SectionCardError(
          onRetry: () => context.read<DashboardCubit>().loadTrends(),
        ),
        DashboardSectionStatus.loaded when state.months.isEmpty => Text(
          l10n.dashboardTrendsEmpty,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        DashboardSectionStatus.loaded => _TrendsBody(state: state),
      },
    );
  }
}

class _TrendsBody extends StatelessWidget {
  const _TrendsBody({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MonthBarChart(
          months: state.months,
          windowMonths: state.trendMonths,
          onWindowChanged: (months) =>
              context.read<DashboardCubit>().loadTrends(months: months),
        ),
        // Month-over-month profit change of the newest plotted month.
        _ChangeLine(months: state.months),
      ],
    );
  }
}

/// `Δ%` of the newest month's profit against the previous one.
class _ChangeLine extends StatelessWidget {
  const _ChangeLine({required this.months});

  final List<MonthlyFinancials> months;

  @override
  Widget build(BuildContext context) {
    final change = profitChangePercent(
      months,
      Localizations.localeOf(context).toString(),
    );
    if (change == null) return const SizedBox.shrink();
    final positive = !change.startsWith('-');

    return Padding(
      padding: const EdgeInsets.only(top: GewerberTokens.space8),
      child: Row(
        children: [
          Icon(
            positive ? Icons.trending_up : Icons.trending_down,
            size: 16,
            color: positive ? GewerberColors.success : GewerberColors.error,
          ),
          const SizedBox(width: GewerberTokens.space4),
          Expanded(
            child: Text(
              AppLocalizations.of(context).dashboardChangeVsPrevious(change),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
