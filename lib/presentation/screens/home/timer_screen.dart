import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/time_tracking/projects_cubit.dart';
import 'package:gewerber_app/application/time_tracking/time_entries_cubit.dart';
import 'package:gewerber_app/application/time_tracking/time_entries_state.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// TimerScreen — start/stop a stopwatch-style timer and review recent entries.
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  int? _projectId;
  int? _taskId;
  bool _billable = true;
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TimeEntriesCubit>().load();
    context.read<ProjectsCubit>().load();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final l10n = AppLocalizations.of(context);
    final success = await context.read<TimeEntriesCubit>().startTimer(
      projectId: _projectId,
      taskId: _taskId,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      billable: _billable,
    );
    if (!mounted) return;
    if (success) {
      _descriptionController.clear();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.timerStartError)));
    }
  }

  Future<void> _stop() async {
    final l10n = AppLocalizations.of(context);
    final success = await context.read<TimeEntriesCubit>().stopTimer();
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.timerStopError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<TimeEntriesCubit>().state;
    final projects = context
        .watch<ProjectsCubit>()
        .state
        .projects
        .where((project) => !project.isArchived)
        .toList();
    final tasksOfSelected = _projectId == null
        ? const <Task>[]
        : context.read<ProjectsCubit>().state.tasksOf(_projectId!);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.timeTimerTitle)),
      body: switch (state.status) {
        TimeEntriesViewStatus.initial || TimeEntriesViewStatus.loading =>
          const Center(child: CircularProgressIndicator()),
        TimeEntriesViewStatus.failure => Center(
          child: Text(l10n.timerLoadError),
        ),
        TimeEntriesViewStatus.loaded => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (state.running != null)
              _RunningTimerCard(
                entry: state.running!,
                projects: projects,
                isBusy: state.isTimerBusy,
                onStop: _stop,
              )
            else
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(GewerberTokens.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.timerStartTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: GewerberTokens.space16),
                      DropdownButtonFormField<int>(
                        initialValue: _projectId,
                        decoration: InputDecoration(
                          labelText: l10n.timerProjectLabel,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(l10n.timerNoProject),
                          ),
                          for (final project in projects)
                            DropdownMenuItem(
                              value: project.id,
                              child: Text(project.name),
                            ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _projectId = value;
                            _taskId = null;
                          });
                          if (value != null) {
                            context.read<ProjectsCubit>().loadTasks(value);
                          }
                        },
                      ),
                      const SizedBox(height: GewerberTokens.space12),
                      DropdownButtonFormField<int>(
                        initialValue: _taskId,
                        decoration: InputDecoration(
                          labelText: l10n.timerTaskLabel,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(l10n.timerNoTask),
                          ),
                          for (final task in tasksOfSelected)
                            DropdownMenuItem(
                              value: task.id,
                              child: Text(task.name),
                            ),
                        ],
                        onChanged: _projectId == null
                            ? null
                            : (value) => setState(() => _taskId = value),
                      ),
                      const SizedBox(height: GewerberTokens.space12),
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: l10n.timerDescriptionLabel,
                        ),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.timerBillableLabel),
                        value: _billable,
                        onChanged: (value) => setState(() => _billable = value),
                      ),
                      FilledButton.icon(
                        onPressed: state.isTimerBusy ? null : _start,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(l10n.timerStart),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: GewerberTokens.space24),
            Text(
              l10n.timerRecentTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: GewerberTokens.space8),
            if (state.entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: GewerberTokens.space16,
                ),
                child: Text(l10n.timerEntriesEmpty),
              )
            else
              for (final entry in state.entries.take(15))
                _EntryTile(
                  entry: entry,
                  projects: projects,
                  onDelete: () =>
                      context.read<TimeEntriesCubit>().deleteEntry(entry.id),
                ),
          ],
        ),
      },
    );
  }
}

class _RunningTimerCard extends StatelessWidget {
  const _RunningTimerCard({
    required this.entry,
    required this.projects,
    required this.isBusy,
    required this.onStop,
  });

  final TimeEntry entry;
  final List<Project> projects;
  final bool isBusy;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final project = projects.where((p) => p.id == entry.projectId).firstOrNull;

    return Card(
      margin: EdgeInsets.zero,
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(GewerberTokens.space16),
        child: Column(
          children: [
            // The visible title carries the running state ("Timer
            // running") — perceivable without the container color alone.
            Semantics(
              header: true,
              child: Text(
                l10n.timerRunningTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: GewerberTokens.space8),
            // Rebuilds every second to update the elapsed time.
            StreamBuilder<void>(
              stream: Stream<void>.periodic(const Duration(seconds: 1)),
              builder: (context, _) {
                final elapsed = DateTime.now().difference(entry.startedAt);
                return Text(
                  _formatElapsed(elapsed),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
            if (project != null || (entry.description ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: GewerberTokens.space8),
                child: Text(
                  [
                    if (project != null) project.name,
                    if ((entry.description ?? '').isNotEmpty)
                      entry.description!,
                  ].join(' · '),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.onPrimaryContainer),
                ),
              ),
            const SizedBox(height: GewerberTokens.space16),
            FilledButton.icon(
              onPressed: isBusy ? null : onStop,
              icon: const Icon(Icons.stop),
              label: Text(l10n.timerStop),
            ),
          ],
        ),
      ),
    );
  }

  String _formatElapsed(Duration elapsed) {
    final hours = elapsed.inHours.toString().padLeft(2, '0');
    final minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.projects,
    required this.onDelete,
  });

  final TimeEntry entry;
  final List<Project> projects;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final project = projects.where((p) => p.id == entry.projectId).firstOrNull;
    final title = [
      if (project != null) project.name,
      if ((entry.description ?? '').isNotEmpty) entry.description!,
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        // The billable state is otherwise conveyed by icon color alone.
        leading: Semantics(
          label: entry.billable
              ? l10n.timerBillableLabel
              : l10n.timerNotBillable,
          child: Icon(
            entry.billable ? Icons.attach_money : Icons.money_off,
            color: entry.billable ? colors.primary : colors.outline,
          ),
        ),
        title: Text(
          title.isEmpty ? '–' : title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${formatDate(entry.startedAt)} ${formatTime(entry.startedAt)}',
        ),
        trailing: Text(formatMinutes(entry.durationMinutes ?? 0)),
        onLongPress: onDelete,
      ),
    );
  }
}
