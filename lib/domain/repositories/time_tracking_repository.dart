import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';

/// Contract for time tracking operations (projects, tasks, entries, timer).
abstract interface class TimeTrackingRepository {
  // ── Projects ────────────────────────────────────────────────────────────

  /// Lists projects, optionally filtered by [status].
  Future<List<Project>> listProjects({ProjectStatus? status});

  /// Creates a new project.
  Future<Project> createProject({
    required String name,
    int? customerId,
    int? hourlyRateCents,
    String? notes,
  });

  /// Updates an existing project.
  Future<Project> updateProject(Project project);

  /// Deletes a project and its tasks.
  Future<void> deleteProject(int projectId);

  // ── Tasks ───────────────────────────────────────────────────────────────

  /// Lists the tasks of a project.
  Future<List<Task>> listTasks(int projectId);

  /// Creates a task within a project.
  Future<Task> createTask({
    required int projectId,
    required String name,
    int? hourlyRateCents,
  });

  /// Updates an existing task.
  Future<Task> updateTask(Task task);

  // ── Time entries ────────────────────────────────────────────────────────

  /// Lists time entries with optional filters.
  Future<List<TimeEntry>> listEntries({
    int? projectId,
    int? taskId,
    DateTime? from,
    DateTime? to,
    bool? billable,
    int? limit,
  });

  /// Creates a manual time entry.
  Future<TimeEntry> createEntry({
    required DateTime startedAt,
    required int durationMinutes,
    int? projectId,
    int? taskId,
    String? description,
    bool billable = false,
  });

  /// Updates an existing time entry.
  Future<TimeEntry> updateEntry(TimeEntry entry);

  /// Deletes a time entry.
  Future<void> deleteEntry(int timeEntryId);

  // ── Timer ───────────────────────────────────────────────────────────────

  /// Returns the currently running timer, or `null` when none is running.
  Future<TimeEntry?> runningEntry();

  /// Starts a timer. Only one timer may run per business.
  Future<TimeEntry> startTimer({
    int? projectId,
    int? taskId,
    String? description,
    bool billable = false,
  });

  /// Stops the running timer and stores the (rounded) duration.
  Future<TimeEntry> stopTimer();

  // ── Reports ─────────────────────────────────────────────────────────────

  /// Aggregates stopped time entries of the period into a report.
  Future<TimeReport> report(DateTime from, DateTime to, {int? projectId});

  // ── Billing ─────────────────────────────────────────────────────────────

  /// Turns the unbilled billable time entries of [projectId] into a new
  /// draft invoice and marks them as invoiced. Without [timeEntryIds] all
  /// unbilled billable entries of the [from]–[to] period are billed; with
  /// [timeEntryIds] only those entries are billed (they must be stopped,
  /// billable, not yet invoiced and belong to [projectId]). The invoice is
  /// associated with [customerId] when given; [issueDate] overrides the
  /// default "today".
  Future<Invoice> createInvoice({
    required int projectId,
    DateTime? from,
    DateTime? to,
    int? customerId,
    DateTime? issueDate,
    List<int>? timeEntryIds,
  });
}
