import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/time_tracking/projects_cubit.dart';
import 'package:gewerber_app/application/time_tracking/time_entries_cubit.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/widgets/forms/field_info_icon.dart';

/// TimeEntryCreateScreen — add a manual time entry.
class TimeEntryCreateScreen extends StatefulWidget {
  const TimeEntryCreateScreen({super.key});

  @override
  State<TimeEntryCreateScreen> createState() => _TimeEntryCreateScreenState();
}

class _TimeEntryCreateScreenState extends State<TimeEntryCreateScreen> {
  DateTime _date = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  final _hoursController = TextEditingController(text: '1');
  final _minutesController = TextEditingController(text: '0');
  final _descriptionController = TextEditingController();
  int? _projectId;
  int? _taskId;
  bool _billable = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    context.read<ProjectsCubit>().load();
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  int get _durationMinutes {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    return hours * 60 + minutes;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_durationMinutes <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.timeEntryDurationInvalid)));
      return;
    }
    setState(() => _isSaving = true);
    final startedAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _startTime.hour,
      _startTime.minute,
    );
    final success = await context.read<TimeEntriesCubit>().createEntry(
      startedAt: startedAt,
      durationMinutes: _durationMinutes,
      projectId: _projectId,
      taskId: _taskId,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      billable: _billable,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.timeEntrySaved)));
      context.pop();
    } else {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.timeEntrySaveError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final projects = context
        .watch<ProjectsCubit>()
        .state
        .projects
        .where((project) => !project.isArchived)
        .toList();
    final tasksOfSelected = _projectId == null
        ? const <Task>[]
        : context.read<ProjectsCubit>().state.tasksOf(_projectId!);

    final dateLabel =
        '${_date.year}-${_date.month.toString().padLeft(2, '0')}-'
        '${_date.day.toString().padLeft(2, '0')}';
    final timeLabel =
        '${_startTime.hour.toString().padLeft(2, '0')}:'
        '${_startTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.timeEntryCreateTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(dateLabel),
                ),
              ),
              const SizedBox(width: GewerberTokens.space12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickStartTime,
                  icon: const Icon(Icons.schedule_outlined, size: 18),
                  label: Text(timeLabel),
                ),
              ),
            ],
          ),
          const SizedBox(height: GewerberTokens.space16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.timeEntryHours),
                ),
              ),
              const SizedBox(width: GewerberTokens.space12),
              Expanded(
                child: TextField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.timeEntryMinutes),
                ),
              ),
            ],
          ),
          const SizedBox(height: GewerberTokens.space16),
          DropdownButtonFormField<int>(
            initialValue: _projectId,
            decoration: InputDecoration(labelText: l10n.timerProjectLabel),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.timerNoProject)),
              for (final project in projects)
                DropdownMenuItem(value: project.id, child: Text(project.name)),
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
            decoration: InputDecoration(labelText: l10n.timerTaskLabel),
            items: [
              DropdownMenuItem(value: null, child: Text(l10n.timerNoTask)),
              for (final task in tasksOfSelected)
                DropdownMenuItem(value: task.id, child: Text(task.name)),
            ],
            onChanged: _projectId == null
                ? null
                : (value) => setState(() => _taskId = value),
          ),
          const SizedBox(height: GewerberTokens.space12),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: l10n.timerDescriptionLabel),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Expanded(child: Text(l10n.timerBillableLabel)),
                FieldInfoIcon(
                  infoText: l10n.fieldHintBillableShort,
                  longInfoText: l10n.fieldHintBillableInfo,
                  sheetTitle: l10n.timerBillableLabel,
                ),
              ],
            ),
            value: _billable,
            onChanged: (value) => setState(() => _billable = value),
          ),
          const SizedBox(height: GewerberTokens.space16),
          FilledButton(
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? Text(l10n.invoiceSaving)
                : Text(l10n.invoiceSave),
          ),
        ],
      ),
    );
  }
}
