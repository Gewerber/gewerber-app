import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/time_tracking/projects_cubit.dart';
import 'package:gewerber_app/application/time_tracking/projects_state.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/widgets/common/empty_state.dart';
import 'package:gewerber_app/presentation/widgets/common/shimmer_loader.dart';

/// ProjectsScreen — projects and their tasks.
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProjectsCubit>().load();
    context.read<CustomerCubit>().load();
  }

  Future<void> _createProject() async {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final rateController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.projectNewTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.projectNameLabel),
            ),
            const SizedBox(height: GewerberTokens.space12),
            TextField(
              controller: rateController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.projectHourlyRateLabel,
                helperText: l10n.projectHourlyRateHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonBack),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonAdd),
          ),
        ],
      ),
    );
    if (created != true || !mounted) return;

    final name = nameController.text.trim();
    if (name.isEmpty) return;
    final cubit = context.read<ProjectsCubit>();
    final success = await cubit.createProject(
      name: name,
      hourlyRateCents: parseEuroInput(rateController.text),
    );
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.projectSaveError)));
    }
  }

  Future<void> _addTask(BuildContext context, int projectId) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.taskNewTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.taskNameLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonBack),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonAdd),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final name = controller.text.trim();
    if (name.isEmpty) return;
    if (!context.mounted) return;
    await context.read<ProjectsCubit>().createTask(
      projectId: projectId,
      name: name,
    );
  }

  Future<void> _deleteProject(Project project) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.projectDeleteTitle),
        content: Text(l10n.projectDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonBack),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.projectDeleteTitle),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<ProjectsCubit>().deleteProject(project.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<ProjectsCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.timeProjectsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'projects-fab',
        onPressed: _createProject,
        icon: const Icon(Icons.add),
        label: Text(l10n.projectNewTitle),
      ),
      body: switch (state.status) {
        ProjectsViewStatus.initial || ProjectsViewStatus.loading =>
          const Center(child: ShimmerLoader(lines: 5, height: 16)),
        ProjectsViewStatus.failure => EmptyState(
          icon: Icons.error_outline,
          message: l10n.projectLoadError,
        ),
        ProjectsViewStatus.loaded when state.projects.isEmpty => EmptyState(
          icon: Icons.folder_outlined,
          message: l10n.projectsEmpty,
        ),
        ProjectsViewStatus.loaded => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final project in state.projects)
              _ProjectTile(
                project: project,
                tasks: state.tasksOf(project.id),
                onExpand: (expanded) {
                  if (expanded) {
                    context.read<ProjectsCubit>().loadTasks(project.id);
                  }
                },
                onAddTask: () => _addTask(context, project.id),
                onToggleTask: (task) =>
                    context.read<ProjectsCubit>().toggleTask(task),
                onToggleArchived: () {
                  final cubit = context.read<ProjectsCubit>();
                  cubit.updateProject(
                    project.copyWith(
                      status: project.isArchived
                          ? ProjectStatus.active
                          : ProjectStatus.archived,
                    ),
                  );
                },
                onDelete: () => _deleteProject(project),
              ),
          ],
        ),
      },
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({
    required this.project,
    required this.tasks,
    required this.onExpand,
    required this.onAddTask,
    required this.onToggleTask,
    required this.onToggleArchived,
    required this.onDelete,
  });

  final Project project;
  final List<Task> tasks;
  final ValueChanged<bool> onExpand;
  final VoidCallback onAddTask;
  final ValueChanged<Task> onToggleTask;
  final VoidCallback onToggleArchived;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final customers = context.watch<CustomerCubit>().state.customers;
    final customer = customers
        .where((c) => c.id == project.customerId)
        .firstOrNull;

    final subtitle = [
      if (customer != null) customer.displayName,
      if (project.hourlyRateCents != null)
        '${formatCents(project.hourlyRateCents!)}/h',
      if (project.isArchived) l10n.projectStatusArchived,
    ].join(' · ');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ExpansionTile(
        leading: Icon(
          project.isArchived
              ? Icons.folder_off_outlined
              : Icons.folder_outlined,
          color: project.isArchived ? colors.outline : colors.primary,
        ),
        title: Text(project.name),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        onExpansionChanged: onExpand,
        childrenPadding: const EdgeInsets.only(
          left: GewerberTokens.space16,
          right: GewerberTokens.space16,
          bottom: GewerberTokens.space8,
        ),
        children: [
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: GewerberTokens.space8,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.tasksEmpty,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            for (final task in tasks)
              CheckboxListTile(
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                value: task.isDone,
                title: Text(task.name),
                onChanged: (_) => onToggleTask(task),
              ),
          TextButton.icon(
            onPressed: onAddTask,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.taskNewTitle),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onToggleArchived,
                child: Text(
                  project.isArchived
                      ? l10n.projectReactivate
                      : l10n.projectArchive,
                ),
              ),
              const SizedBox(width: GewerberTokens.space8),
              TextButton(
                onPressed: onDelete,
                style: TextButton.styleFrom(foregroundColor: colors.error),
                child: Text(l10n.projectDeleteTitle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
