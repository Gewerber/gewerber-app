import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/time_billing/time_billing_cubit.dart';
import 'package:gewerber_app/application/time_billing/time_billing_state.dart';
import 'package:gewerber_app/application/time_tracking/projects_cubit.dart';
import 'package:gewerber_app/application/time_tracking/projects_state.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';

/// TimeBillingScreen — turns unbilled billable time entries of a project
/// into a draft invoice via `timeEntry.createInvoice`.
///
/// The server endpoint bills by project (+ optional period), so the entry
/// list below is a read-only preview of what will be billed — individual
/// entries cannot be deselected.
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
    final projects = context
        .watch<ProjectsCubit>()
        .state
        .projects
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
                    l10n.timeBillingLoadError,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: GewerberTokens.space24),
                _EntryPreview(state: state),
                const SizedBox(height: GewerberTokens.space24),
                FilledButton.icon(
                  onPressed:
                      state.hasSelection &&
                          state.unbilledEntries.isNotEmpty &&
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

/// Read-only preview of the entries that will be billed, with an estimated
/// total based on the project's hourly rate.
class _EntryPreview extends StatelessWidget {
  const _EntryPreview({required this.state});

  final TimeBillingState state;

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

    final totalMinutes = state.unbilledEntries.fold<int>(
      0,
      (sum, entry) => sum + (entry.durationMinutes ?? 0),
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
                  title: Text(
                    entry.description ?? l10n.timerNoTask,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${formatDate(entry.startedAt)} · '
                    '${formatMinutes(entry.durationMinutes ?? 0)}',
                  ),
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
      ],
    );
  }
}
