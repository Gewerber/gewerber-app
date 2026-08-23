import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';
import 'package:gewerber_app/domain/repositories/time_tracking_repository.dart';

/// In-memory [TimeTrackingRepository] backing the demo experience and the
/// widget tests. Data lives for the app session only.
@LazySingleton(as: TimeTrackingRepository, env: [AppEnvironment.authMock])
class MockTimeTrackingRepository implements TimeTrackingRepository {
  final List<Project> _projects = [];
  final List<Task> _tasks = [];
  final List<TimeEntry> _entries = [];
  int _nextProjectId = 1;
  int _nextTaskId = 1;
  int _nextEntryId = 1;
  int _nextInvoiceId = 1;

  // ── Projects ────────────────────────────────────────────────────────────

  @override
  Future<List<Project>> listProjects({ProjectStatus? status}) async {
    return _projects
        .where((project) => status == null || project.status == status)
        .toList();
  }

  @override
  Future<Project> createProject({
    required String name,
    int? customerId,
    int? hourlyRateCents,
    String? notes,
  }) async {
    final project = Project(
      id: _nextProjectId++,
      name: name,
      customerId: customerId,
      hourlyRateCents: hourlyRateCents,
      notes: notes,
    );
    _projects.add(project);
    return project;
  }

  @override
  Future<Project> updateProject(Project project) async {
    final index = _projects.indexWhere((value) => value.id == project.id);
    if (index < 0) throw StateError('Unknown project id ${project.id}');
    _projects[index] = project;
    return project;
  }

  @override
  Future<void> deleteProject(int projectId) async {
    _projects.removeWhere((value) => value.id == projectId);
    _tasks.removeWhere((value) => value.projectId == projectId);
  }

  // ── Tasks ───────────────────────────────────────────────────────────────

  @override
  Future<List<Task>> listTasks(int projectId) async {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  @override
  Future<Task> createTask({
    required int projectId,
    required String name,
    int? hourlyRateCents,
  }) async {
    final task = Task(
      id: _nextTaskId++,
      projectId: projectId,
      name: name,
      hourlyRateCents: hourlyRateCents,
    );
    _tasks.add(task);
    return task;
  }

  @override
  Future<Task> updateTask(Task task) async {
    final index = _tasks.indexWhere((value) => value.id == task.id);
    if (index < 0) throw StateError('Unknown task id ${task.id}');
    _tasks[index] = task;
    return task;
  }

  // ── Time entries ────────────────────────────────────────────────────────

  @override
  Future<List<TimeEntry>> listEntries({
    int? projectId,
    int? taskId,
    DateTime? from,
    DateTime? to,
    bool? billable,
    int? limit,
  }) async {
    final result =
        _entries
            .where(
              (entry) =>
                  (projectId == null || entry.projectId == projectId) &&
                  (taskId == null || entry.taskId == taskId) &&
                  (from == null || !entry.startedAt.isBefore(from)) &&
                  (to == null || !entry.startedAt.isAfter(to)) &&
                  (billable == null || entry.billable == billable),
            )
            .toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return limit == null ? result : result.take(limit).toList();
  }

  @override
  Future<TimeEntry> createEntry({
    required DateTime startedAt,
    required int durationMinutes,
    int? projectId,
    int? taskId,
    String? description,
    bool billable = false,
  }) async {
    final entry = TimeEntry(
      id: _nextEntryId++,
      startedAt: startedAt,
      stoppedAt: startedAt.add(Duration(minutes: durationMinutes)),
      durationMinutes: durationMinutes,
      projectId: projectId,
      taskId: taskId,
      description: description,
      billable: billable,
    );
    _entries.add(entry);
    return entry;
  }

  @override
  Future<TimeEntry> updateEntry(TimeEntry entry) async {
    final index = _entries.indexWhere((value) => value.id == entry.id);
    if (index < 0) throw StateError('Unknown time entry id ${entry.id}');
    _entries[index] = entry;
    return entry;
  }

  @override
  Future<void> deleteEntry(int timeEntryId) async {
    _entries.removeWhere((value) => value.id == timeEntryId);
  }

  // ── Timer ───────────────────────────────────────────────────────────────

  @override
  Future<TimeEntry?> runningEntry() async {
    return _entries.where((entry) => entry.isRunning).firstOrNull;
  }

  @override
  Future<TimeEntry> startTimer({
    int? projectId,
    int? taskId,
    String? description,
    bool billable = false,
  }) async {
    if (await runningEntry() != null) {
      throw StateError('A timer is already running');
    }
    final entry = TimeEntry(
      id: _nextEntryId++,
      startedAt: DateTime.now(),
      projectId: projectId,
      taskId: taskId,
      description: description,
      billable: billable,
    );
    _entries.add(entry);
    return entry;
  }

  @override
  Future<TimeEntry> stopTimer() async {
    final running = _entries.where((entry) => entry.isRunning).firstOrNull;
    if (running == null) throw StateError('No timer is running');
    final stoppedAt = DateTime.now();
    final duration = stoppedAt.difference(running.startedAt).inMinutes;
    final stopped = TimeEntry(
      id: running.id,
      startedAt: running.startedAt,
      stoppedAt: stoppedAt,
      durationMinutes: duration,
      projectId: running.projectId,
      taskId: running.taskId,
      description: running.description,
      billable: running.billable,
    );
    final index = _entries.indexWhere((value) => value.id == running.id);
    _entries[index] = stopped;
    return stopped;
  }

  // ── Reports ─────────────────────────────────────────────────────────────

  @override
  Future<TimeReport> report(
    DateTime from,
    DateTime to, {
    int? projectId,
  }) async {
    final stopped = _entries.where(
      (entry) =>
          !entry.isRunning &&
          !entry.startedAt.isBefore(from) &&
          !entry.startedAt.isAfter(to) &&
          (projectId == null || entry.projectId == projectId),
    );

    final lines = <TimeReportLine>[];
    final byProject = <int?, List<TimeEntry>>{};
    for (final entry in stopped) {
      byProject.putIfAbsent(entry.projectId, () => []).add(entry);
    }
    for (final MapEntry(:key, :value) in byProject.entries) {
      final total = value.fold<int>(
        0,
        (sum, entry) => sum + (entry.durationMinutes ?? 0),
      );
      final billable = value
          .where((entry) => entry.billable)
          .fold<int>(0, (sum, entry) => sum + (entry.durationMinutes ?? 0));
      final project = _projects.where((p) => p.id == key).firstOrNull;
      lines.add(
        TimeReportLine(
          projectId: key,
          projectName: project?.name,
          entryCount: value.length,
          totalMinutes: total,
          billableMinutes: billable,
          roundedMinutes: total,
        ),
      );
    }

    final totalMinutes = lines.fold<int>(
      0,
      (sum, line) => sum + line.totalMinutes,
    );
    final billableMinutes = lines.fold<int>(
      0,
      (sum, line) => sum + line.billableMinutes,
    );
    return TimeReport(
      from: from,
      to: to,
      totalMinutes: totalMinutes,
      billableMinutes: billableMinutes,
      roundedMinutes: totalMinutes,
      lines: lines,
    );
  }

  // ── Billing ─────────────────────────────────────────────────────────────

  @override
  Future<Invoice> createInvoice({
    required int projectId,
    DateTime? from,
    DateTime? to,
    int? customerId,
    DateTime? issueDate,
  }) async {
    final billable = _entries
        .where(
          (entry) =>
              entry.projectId == projectId &&
              !entry.isRunning &&
              entry.billable &&
              entry.invoicedAt == null &&
              (from == null || !entry.startedAt.isBefore(from)) &&
              (to == null || !entry.startedAt.isAfter(to)),
        )
        .toList();
    if (billable.isEmpty) {
      throw StateError('No unbilled billable entries for project $projectId');
    }

    final now = DateTime.now();
    final invoicedAt = now;
    for (final entry in billable) {
      final index = _entries.indexWhere((value) => value.id == entry.id);
      _entries[index] = entry.copyWith(invoicedAt: invoicedAt);
    }

    final project = _projects.where((p) => p.id == projectId).firstOrNull;
    final totalCents = billable.fold<int>(0, (sum, entry) {
      final task = _tasks.where((t) => t.id == entry.taskId).firstOrNull;
      final rateCents = task?.hourlyRateCents ?? project?.hourlyRateCents ?? 0;
      return sum + ((entry.durationMinutes ?? 0) * rateCents / 60).round();
    });

    final invoice = Invoice(
      id: _nextInvoiceId++,
      number: 'RE-TIME-$_nextInvoiceId',
      customerId: customerId ?? project?.customerId,
      issueDate: issueDate ?? now,
      subtotalCents: totalCents,
      vatTotalCents: 0,
      totalCents: totalCents,
    );
    return invoice;
  }
}
