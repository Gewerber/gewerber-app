import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/recurring_schedules/recurring_schedule_cubit.dart';
import 'package:gewerber_app/application/recurring_schedules/recurring_schedule_state.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/customer.dart';
import 'package:gewerber_app/domain/entities/recurring_schedule.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/common/shimmer_loader.dart';

/// RecurringSchedulesScreen — list of the active business's recurring
/// invoice schedules, upcoming next issue first.
class RecurringSchedulesScreen extends StatefulWidget {
  const RecurringSchedulesScreen({super.key});

  @override
  State<RecurringSchedulesScreen> createState() =>
      _RecurringSchedulesScreenState();
}

class _RecurringSchedulesScreenState extends State<RecurringSchedulesScreen> {
  @override
  void initState() {
    super.initState();
    // The invoicing module preloads neither schedules nor customers; make
    // sure both are present when this screen is opened.
    final cubit = context.read<RecurringScheduleCubit>();
    if (cubit.state.status == RecurringScheduleViewStatus.initial) {
      cubit.load();
    }
    context.read<CustomerCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<RecurringScheduleCubit>().state;
    final customers = context.watch<CustomerCubit>().state.customers;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recurringTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.recurringScheduleEdit),
        icon: const Icon(Icons.add),
        label: Text(l10n.recurringAdd),
      ),
      body: switch (state.status) {
        RecurringScheduleViewStatus.initial ||
        RecurringScheduleViewStatus.loading => const Center(
          child: ShimmerLoader(lines: 5, height: 16),
        ),
        RecurringScheduleViewStatus.failure => Center(
          child: Text(l10n.recurringLoadError),
        ),
        RecurringScheduleViewStatus.loaded when state.schedules.isEmpty =>
          _EmptyState(),
        RecurringScheduleViewStatus.loaded => ListView.separated(
          padding: const EdgeInsets.all(GewerberTokens.space16),
          itemCount: state.schedules.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final schedule = state.schedules[index];
            return _ScheduleTile(schedule: schedule, customers: customers);
          },
        ),
      },
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({required this.schedule, required this.customers});

  final RecurringSchedule schedule;
  final List<Customer> customers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final customer = customers
        .where((candidate) => candidate.id == schedule.customerId)
        .firstOrNull;
    final customerName = customer?.displayName ?? l10n.invoiceNoCustomer;

    final constraints = [
      if (schedule.recurrenceEndDate != null)
        l10n.recurringEndsOn(formatDate(schedule.recurrenceEndDate!)),
      if (schedule.recurrenceMaxOccurrences != null)
        l10n.recurringStopsAfter(schedule.recurrenceMaxOccurrences!),
    ].join(' · ');

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(Icons.event_repeat, color: colors.onSurfaceVariant),
        ),
        title: Text('${schedule.invoiceNumber} · $customerName'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_intervalLabel(l10n, schedule.interval)}'
              ' · ${formatDate(schedule.effectiveNextDate)}',
            ),
            if (constraints.isNotEmpty)
              Text(
                constraints,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
          ],
        ),
        onTap: () =>
            context.push(RouteNames.recurringScheduleEdit, extra: schedule),
      ),
    );
  }

  String _intervalLabel(AppLocalizations l10n, RecurrenceInterval interval) {
    return switch (interval) {
      RecurrenceInterval.daily => l10n.recurringIntervalDaily,
      RecurrenceInterval.weekly => l10n.recurringIntervalWeekly,
      RecurrenceInterval.monthly => l10n.recurringIntervalMonthly,
      RecurrenceInterval.quarterly => l10n.recurringIntervalQuarterly,
      RecurrenceInterval.yearly => l10n.recurringIntervalYearly,
    };
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GewerberTokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_repeat, size: 56, color: colors.outline),
            const SizedBox(height: GewerberTokens.space16),
            Text(l10n.recurringEmpty, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
