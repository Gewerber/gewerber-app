import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/time_billing/billing_estimate.dart';
import 'package:gewerber_app/application/time_billing/time_billing_cubit.dart';
import 'package:gewerber_app/application/time_billing/time_billing_state.dart';
import 'package:gewerber_app/application/time_tracking/projects_cubit.dart';
import 'package:gewerber_app/application/time_tracking/projects_state.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';

/// TimeBillingScreen — turns unbilled billable time entries of a project
/// into a draft invoice via `timeEntry.createInvoice`.
///
/// The entry list below previews what will be billed; individual entries
/// can be unchecked, and only the remaining ones are sent as
/// `timeEntryIds` to the server.
class TimeBillingScreen extends StatefulWidget {
  const TimeBillingScreen({super.key});

  @override
  State<TimeBillingScreen> createState() => _TimeBillingScreenState();
}

class _TimeBillingScreenState extends State<TimeBillingScreen> {
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    final projects = context.read<ProjectsCubit>();
    if (projects.state.status == ProjectsViewStatus.initial) {
      projects.load(includeArchived: false);
    }
    // Task rates are needed for the per-entry estimates; the billing cubit
    // may hold a selection from a previous visit.
    final selectedProjectId = context.read<TimeBillingCubit>().state.projectId;
    if (selectedProjectId != null &&
        projects.state.tasks[selectedProjectId] == null) {
      projects.loadTasks(selectedProjectId);
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_from ?? now) : (_to ?? now),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _from = picked;
      } else {
        _to = picked;
      }
    });
    await context.read<TimeBillingCubit>().setPeriod(
      from: _from,
      to: _to?.add(const Duration(days: 1)),
    );
  }

  Future<void> _createInvoice() async {
    final l10n = AppLocalizations.of(context);
    final invoice = await context.read<TimeBillingCubit>().createInvoice();
    if (!mounted || invoice == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.timeBillingSuccess(invoice.number))),
    );
    // Open the created invoice; the billing screen stays in the stack so
    // navigating back returns to the (now empty) preview.
    context.push(RouteNames.invoiceDetail, extra: invoice);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<TimeBillingCubit>().state;
    final projectsState = context.watch<ProjectsCubit>().state;
    final projects = projectsState.projects
        .where((project) => !project.isArchived)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.timeBillingTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.timeBillingSubtitle),
                const SizedBox(height: GewerberTokens.space16),
                DropdownButtonFormField<int>(
                  initialValue: state.projectId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.timerProjectLabel,
                    prefixIcon: const Icon(Icons.folder_outlined),
                  ),
                  items: [
                    for (final project in projects)
                      DropdownMenuItem<int>(
                        value: project.id,
                        child: Text(project.name),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      context.read<TimeBillingCubit>().setProject(value);
                      // Task rates feed the per-entry estimates.
                      final tasks = context
                          .read<ProjectsCubit>()
                          .state
                          .tasks[value];
                      if (tasks == null) {
                        context.read<ProjectsCubit>().loadTasks(value);
                      }
                    }
                  },
                ),
                const SizedBox(height: GewerberTokens.space12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(isStart: true),
                        icon: const Icon(Icons.event_outlined, size: 18),
                        label: Text(
                          _from == null
                              ? l10n.timeBillingFrom
                              : formatDate(_from!),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GewerberTokens.space8,
                      ),
                      child: Text(l10n.timeReportUntil),
                    ),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(isStart: false),
                        icon: const Icon(Icons.event_outlined, size: 18),
                        label: Text(
                          _to == null ? l10n.timeBillingTo : formatDate(_to!),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.commonClear,
                      icon: const Icon(Icons.filter_alt_off_outlined),
                      onPressed: (_from == null && _to == null)
                          ? null
                          : () {
                              setState(() {
                                _from = null;
                                _to = null;
                              });
                              context.read<TimeBillingCubit>().setPeriod(
                                from: null,
                                to: null,
                              );
                            },
                    ),
                  ],
                ),
                if (state.failure != null) ...[
                  const SizedBox(height: GewerberTokens.space16),
                  Text(
                    switch (state.failure) {
                      // The selection was rejected (e.g. entries billed in
                      // parallel); the cubit refreshes the preview so the
                      // user sees the current server state.
                      ValidationFailure() => l10n.timeBillingSelectionInvalid,
                      _ => l10n.timeBillingLoadError,
                    },
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: GewerberTokens.space24),
                _EntryPreview(
                  state: state,
                  project: projectsState.projects
                      .where((project) => project.id == state.projectId)
                      .firstOrNull,
                  tasks: state.projectId == null
                      ? const []
                      : projectsState.tasksOf(state.projectId!),
                  onToggle: context.read<TimeBillingCubit>().toggleEntry,
                ),
                const SizedBox(height: GewerberTokens.space24),
                FilledButton.icon(
                  onPressed:
                      state.hasSelectedEntries &&
                          !state.isCreating &&
                          !state.isLoadingEntries
                      ? _createInvoice
                      : null,
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: GewerberTokens.space4,
                    ),
                    child: state.isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.timeBillingCreateButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Preview of the entries that will be billed, with a checkbox per entry
/// (all selected by default), a per-entry and total euro estimate over the
/// selected rows (task rate first, then the project rate; "—" when no rate
/// is defined) and an estimate disclaimer.
class _EntryPreview extends StatelessWidget {
  const _EntryPreview({
    required this.state,
    required this.project,
    required this.tasks,
    required this.onToggle,
  });

  final TimeBillingState state;

  /// The project being billed, if still loaded.
  final Project? project;

  /// Tasks of the selected project (source of task-level hourly rates).
  final List<Task> tasks;

  /// Called when the user checks/unchecks an entry.
  final ValueChanged<int> onToggle;

  /// Placeholder for entries without any applicable hourly rate.
  static const String _noEstimate = '—';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    final header = Text(
      l10n.timeBillingEntriesTitle,
      style: Theme.of(context).textTheme.titleMedium,
    );

    if (!state.hasSelection) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: GewerberTokens.space8),
          Text(
            l10n.timeBillingPickProject,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      );
    }

    if (state.isLoadingEntries) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const Padding(
            padding: EdgeInsets.symmetric(vertical: GewerberTokens.space16),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (state.unbilledEntries.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: GewerberTokens.space8),
          Text(
            l10n.timeBillingEmpty,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      );
    }

    // Totals cover only the entries that are still checked.
    final selectedEntries = state.unbilledEntries
        .where((entry) => !state.deselectedEntryIds.contains(entry.id))
        .toList();
    final totalMinutes = selectedEntries.fold<int>(
      0,
      (sum, entry) => sum + (entry.durationMinutes ?? 0),
    );
    final estimatedCents = totalEstimatedCents(
      selectedEntries,
      project: project,
      tasks: tasks,
    );
    // Selected entries without a task/project rate show no estimate at all.
    final hasEstimates = selectedEntries.any(
      (entry) =>
          estimateEntryCents(entry, project: project, tasks: tasks) != null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: GewerberTokens.space8),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              for (final entry in state.unbilledEntries)
                ListTile(
                  dense: true,
                  leading: Checkbox(
                    value: !state.deselectedEntryIds.contains(entry.id),
                    onChanged: (_) => onToggle(entry.id),
                  ),
                  onTap: () => onToggle(entry.id),
                  title: Text(
                    entry.description ?? l10n.timerNoTask,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${formatDate(entry.startedAt)} · '
                    '${formatMinutes(entry.durationMinutes ?? 0)}',
                  ),
                  trailing: switch (estimateEntryCents(
                    entry,
                    project: project,
                    tasks: tasks,
                  )) {
                    null => Text(
                      _noEstimate,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    final cents => Text(formatCents(cents)),
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: GewerberTokens.space12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.timeBillingTotalMinutes(totalMinutes)),
            Text(
              formatMinutes(totalMinutes),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        if (hasEstimates) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.timeBillingEstimatedTotal),
              Text(
                formatCents(estimatedCents),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: GewerberTokens.space4),
          Text(
            l10n.timeBillingEstimateDisclaimer,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}
