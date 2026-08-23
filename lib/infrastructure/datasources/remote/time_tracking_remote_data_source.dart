import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';
import 'package:gewerber_app/infrastructure/core/serverpod_client_factory.dart';
import 'package:gewerber_app/infrastructure/mappers/invoice_mapper.dart';
import 'package:gewerber_app/infrastructure/mappers/time_tracking_mapper.dart';

/// Transport-level time tracking calls against the Serverpod backend.
///
/// Every serverpod exception is translated into an [AppException] so higher
/// layers stay free of transport details.
@LazySingleton(env: [AppEnvironment.authLive])
class TimeTrackingRemoteDataSource {
  TimeTrackingRemoteDataSource(
    this._clientFactory,
    this._mapper,
    this._invoiceMapper,
  );

  final ServerpodClientFactory _clientFactory;
  final TimeTrackingMapper _mapper;
  final InvoiceMapper _invoiceMapper;

  sdk.Client get _client => _clientFactory.client;

  // ── Projects ────────────────────────────────────────────────────────────

  Future<List<Project>> listProjects({ProjectStatus? status}) async {
    try {
      final models = await _client.project.list(
        status: status == null ? null : _mapper.toProtocolProjectStatus(status),
      );
      return models.map(_mapper.projectFromModel).toList();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<Project> createProject({
    required String name,
    int? customerId,
    int? hourlyRateCents,
    String? notes,
  }) async {
    try {
      final model = await _client.project.create(
        sdk.CreateProjectRequest(
          name: name,
          customerId: customerId,
          hourlyRateCents: hourlyRateCents,
          notes: notes,
        ),
      );
      return _mapper.projectFromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<Project> updateProject(Project project) async {
    try {
      final model = await _client.project.update(
        sdk.UpdateProjectRequest(
          projectId: project.id,
          name: project.name,
          status: _mapper.toProtocolProjectStatus(project.status),
          customerId: project.customerId,
          hourlyRateCents: project.hourlyRateCents,
          notes: project.notes,
        ),
      );
      return _mapper.projectFromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<void> deleteProject(int projectId) async {
    try {
      await _client.project.delete(projectId);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  // ── Tasks ───────────────────────────────────────────────────────────────

  Future<List<Task>> listTasks(int projectId) async {
    try {
      final models = await _client.project.getTasks(projectId);
      return models.map(_mapper.taskFromModel).toList();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<Task> createTask({
    required int projectId,
    required String name,
    int? hourlyRateCents,
  }) async {
    try {
      final model = await _client.task.create(
        sdk.CreateTaskRequest(
          projectId: projectId,
          name: name,
          hourlyRateCents: hourlyRateCents,
        ),
      );
      return _mapper.taskFromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<Task> updateTask(Task task) async {
    try {
      final model = await _client.task.update(
        sdk.UpdateTaskRequest(
          taskId: task.id,
          name: task.name,
          status: _mapper.toProtocolTaskStatus(task.status),
          hourlyRateCents: task.hourlyRateCents,
        ),
      );
      return _mapper.taskFromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  // ── Time entries ────────────────────────────────────────────────────────

  Future<List<TimeEntry>> listEntries({
    int? projectId,
    int? taskId,
    DateTime? from,
    DateTime? to,
    bool? billable,
    int? limit,
  }) async {
    try {
      final models = await _client.timeEntry.list(
        projectId: projectId,
        taskId: taskId,
        from: from,
        to: to,
        billable: billable,
        limit: limit,
      );
      return models.map(_mapper.entryFromModel).toList();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<TimeEntry> createEntry({
    required DateTime startedAt,
    required int durationMinutes,
    int? projectId,
    int? taskId,
    String? description,
    bool billable = false,
  }) async {
    try {
      final model = await _client.timeEntry.create(
        sdk.CreateTimeEntryRequest(
          startedAt: startedAt,
          durationMinutes: durationMinutes,
          projectId: projectId,
          taskId: taskId,
          description: description,
          billable: billable,
        ),
      );
      return _mapper.entryFromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<TimeEntry> updateEntry(TimeEntry entry) async {
    try {
      final model = await _client.timeEntry.update(
        sdk.UpdateTimeEntryRequest(
          timeEntryId: entry.id,
          projectId: entry.projectId,
          taskId: entry.taskId,
          description: entry.description,
          startedAt: entry.startedAt,
          durationMinutes: entry.durationMinutes ?? 0,
          billable: entry.billable,
        ),
      );
      return _mapper.entryFromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<void> deleteEntry(int timeEntryId) async {
    try {
      await _client.timeEntry.delete(timeEntryId);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  // ── Timer ───────────────────────────────────────────────────────────────

  Future<TimeEntry?> runningEntry() async {
    try {
      // The running timer is the entry without a stop time; the list is
      // sorted by start time descending, so it comes first.
      final models = await _client.timeEntry.list(limit: 20);
      final running = models.where((model) => model.stoppedAt == null);
      if (running.isEmpty) return null;
      return _mapper.entryFromModel(running.first);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<TimeEntry> startTimer({
    int? projectId,
    int? taskId,
    String? description,
    bool billable = false,
  }) async {
    try {
      final model = await _client.timeEntry.startTimer(
        sdk.StartTimerRequest(
          projectId: projectId,
          taskId: taskId,
          description: description,
          billable: billable,
        ),
      );
      return _mapper.entryFromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<TimeEntry> stopTimer() async {
    try {
      final model = await _client.timeEntry.stopTimer();
      return _mapper.entryFromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  // ── Reports ─────────────────────────────────────────────────────────────

  Future<TimeReport> report(
    DateTime from,
    DateTime to, {
    int? projectId,
  }) async {
    try {
      final model = await _client.timeEntry.report(
        from,
        to,
        projectId: projectId,
      );
      return _mapper.reportFromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  // ── Billing ─────────────────────────────────────────────────────────────

  Future<Invoice> createInvoice({
    required int projectId,
    DateTime? from,
    DateTime? to,
    int? customerId,
    DateTime? issueDate,
  }) async {
    try {
      final model = await _client.timeEntry.createInvoice(
        sdk.CreateTimeEntriesInvoiceRequest(
          projectId: projectId,
          from: from,
          to: to,
          customerId: customerId,
          issueDate: issueDate,
        ),
      );
      return _invoiceMapper.fromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }
}
