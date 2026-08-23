import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';
import 'package:gewerber_app/domain/repositories/time_tracking_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/time_tracking_remote_data_source.dart';

/// Serverpod-backed [TimeTrackingRepository].
@LazySingleton(as: TimeTrackingRepository, env: [AppEnvironment.authLive])
class ServerpodTimeTrackingRepository implements TimeTrackingRepository {
  ServerpodTimeTrackingRepository(this._dataSource);

  final TimeTrackingRemoteDataSource _dataSource;

  @override
  Future<List<Project>> listProjects({ProjectStatus? status}) {
    return _guard(() => _dataSource.listProjects(status: status));
  }

  @override
  Future<Project> createProject({
    required String name,
    int? customerId,
    int? hourlyRateCents,
    String? notes,
  }) {
    return _guard(
      () => _dataSource.createProject(
        name: name,
        customerId: customerId,
        hourlyRateCents: hourlyRateCents,
        notes: notes,
      ),
    );
  }

  @override
  Future<Project> updateProject(Project project) {
    return _guard(() => _dataSource.updateProject(project));
  }

  @override
  Future<void> deleteProject(int projectId) {
    return _guard(() => _dataSource.deleteProject(projectId));
  }

  @override
  Future<List<Task>> listTasks(int projectId) {
    return _guard(() => _dataSource.listTasks(projectId));
  }

  @override
  Future<Task> createTask({
    required int projectId,
    required String name,
    int? hourlyRateCents,
  }) {
    return _guard(
      () => _dataSource.createTask(
        projectId: projectId,
        name: name,
        hourlyRateCents: hourlyRateCents,
      ),
    );
  }

  @override
  Future<Task> updateTask(Task task) {
    return _guard(() => _dataSource.updateTask(task));
  }

  @override
  Future<List<TimeEntry>> listEntries({
    int? projectId,
    int? taskId,
    DateTime? from,
    DateTime? to,
    bool? billable,
    int? limit,
  }) {
    return _guard(
      () => _dataSource.listEntries(
        projectId: projectId,
        taskId: taskId,
        from: from,
        to: to,
        billable: billable,
        limit: limit,
      ),
    );
  }

  @override
  Future<TimeEntry> createEntry({
    required DateTime startedAt,
    required int durationMinutes,
    int? projectId,
    int? taskId,
    String? description,
    bool billable = false,
  }) {
    return _guard(
      () => _dataSource.createEntry(
        startedAt: startedAt,
        durationMinutes: durationMinutes,
        projectId: projectId,
        taskId: taskId,
        description: description,
        billable: billable,
      ),
    );
  }

  @override
  Future<TimeEntry> updateEntry(TimeEntry entry) {
    return _guard(() => _dataSource.updateEntry(entry));
  }

  @override
  Future<void> deleteEntry(int timeEntryId) {
    return _guard(() => _dataSource.deleteEntry(timeEntryId));
  }

  @override
  Future<TimeEntry?> runningEntry() {
    return _guard(() => _dataSource.runningEntry());
  }

  @override
  Future<TimeEntry> startTimer({
    int? projectId,
    int? taskId,
    String? description,
    bool billable = false,
  }) {
    return _guard(
      () => _dataSource.startTimer(
        projectId: projectId,
        taskId: taskId,
        description: description,
        billable: billable,
      ),
    );
  }

  @override
  Future<TimeEntry> stopTimer() {
    return _guard(() => _dataSource.stopTimer());
  }

  @override
  Future<TimeReport> report(DateTime from, DateTime to, {int? projectId}) {
    return _guard(() => _dataSource.report(from, to, projectId: projectId));
  }

  @override
  Future<Invoice> createInvoice({
    required int projectId,
    DateTime? from,
    DateTime? to,
    int? customerId,
    DateTime? issueDate,
  }) {
    return _guard(
      () => _dataSource.createInvoice(
        projectId: projectId,
        from: from,
        to: to,
        customerId: customerId,
        issueDate: issueDate,
      ),
    );
  }

  /// Runs [action] and rethrows [AppException]s, wrapping any other error as
  /// a [NetworkException].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }
}
