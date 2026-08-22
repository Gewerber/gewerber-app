import 'package:equatable/equatable.dart';

/// Project lifecycle status, mirroring the server's `ProjectStatus` enum.
enum ProjectStatus {
  active,
  archived;

  static ProjectStatus fromName(String name) {
    return ProjectStatus.values.firstWhere(
      (value) => value.name == name,
      orElse: () => ProjectStatus.active,
    );
  }
}

/// Task status, mirroring the server's `TaskStatus` enum.
enum TaskStatus {
  open,
  done;

  static TaskStatus fromName(String name) {
    return TaskStatus.values.firstWhere(
      (value) => value.name == name,
      orElse: () => TaskStatus.open,
    );
  }
}

/// A billable project of the business.
class Project extends Equatable {
  const Project({
    required this.id,
    required this.name,
    this.status = ProjectStatus.active,
    this.customerId,
    this.hourlyRateCents,
    this.notes,
  });

  final int id;
  final String name;
  final ProjectStatus status;
  final int? customerId;
  final int? hourlyRateCents;
  final String? notes;

  bool get isArchived => status == ProjectStatus.archived;

  Project copyWith({
    String? name,
    ProjectStatus? status,
    Object? customerId = _sentinel,
    Object? hourlyRateCents = _sentinel,
    Object? notes = _sentinel,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      status: status ?? this.status,
      customerId: customerId is int? ? customerId : this.customerId,
      hourlyRateCents: hourlyRateCents is int?
          ? hourlyRateCents
          : this.hourlyRateCents,
      notes: notes is String? ? notes : this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    status,
    customerId,
    hourlyRateCents,
    notes,
  ];
}

/// A task within a project.
class Task extends Equatable {
  const Task({
    required this.id,
    required this.projectId,
    required this.name,
    this.status = TaskStatus.open,
    this.hourlyRateCents,
  });

  final int id;
  final int projectId;
  final String name;
  final TaskStatus status;
  final int? hourlyRateCents;

  bool get isDone => status == TaskStatus.done;

  Task copyWith({
    String? name,
    TaskStatus? status,
    Object? hourlyRateCents = _sentinel,
  }) {
    return Task(
      id: id,
      projectId: projectId,
      name: name ?? this.name,
      status: status ?? this.status,
      hourlyRateCents: hourlyRateCents is int?
          ? hourlyRateCents
          : this.hourlyRateCents,
    );
  }

  @override
  List<Object?> get props => [id, projectId, name, status, hourlyRateCents];
}

/// A recorded time entry. A running timer is an entry without [stoppedAt].
class TimeEntry extends Equatable {
  const TimeEntry({
    required this.id,
    required this.startedAt,
    this.projectId,
    this.taskId,
    this.description,
    this.stoppedAt,
    this.durationMinutes,
    this.billable = false,
    this.invoicedAt,
  });

  final int id;
  final int? projectId;
  final int? taskId;
  final String? description;
  final DateTime startedAt;
  final DateTime? stoppedAt;
  final int? durationMinutes;
  final bool billable;
  final DateTime? invoicedAt;

  /// Whether this entry is a running timer.
  bool get isRunning => stoppedAt == null;

  TimeEntry copyWith({
    Object? projectId = _sentinel,
    Object? taskId = _sentinel,
    Object? description = _sentinel,
    DateTime? startedAt,
    Object? stoppedAt = _sentinel,
    Object? durationMinutes = _sentinel,
    bool? billable,
    Object? invoicedAt = _sentinel,
  }) {
    return TimeEntry(
      id: id,
      projectId: projectId is int? ? projectId : this.projectId,
      taskId: taskId is int? ? taskId : this.taskId,
      description: description is String? ? description : this.description,
      startedAt: startedAt ?? this.startedAt,
      stoppedAt: stoppedAt is DateTime? ? stoppedAt : this.stoppedAt,
      durationMinutes: durationMinutes is int?
          ? durationMinutes
          : this.durationMinutes,
      billable: billable ?? this.billable,
      invoicedAt: invoicedAt is DateTime? ? invoicedAt : this.invoicedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    taskId,
    description,
    startedAt,
    stoppedAt,
    durationMinutes,
    billable,
    invoicedAt,
  ];
}

/// One aggregation line of a time report (per project/task).
class TimeReportLine extends Equatable {
  const TimeReportLine({
    required this.entryCount,
    required this.totalMinutes,
    required this.billableMinutes,
    required this.roundedMinutes,
    this.projectId,
    this.projectName,
    this.taskId,
    this.taskName,
  });

  final int? projectId;
  final String? projectName;
  final int? taskId;
  final String? taskName;
  final int entryCount;
  final int totalMinutes;
  final int billableMinutes;
  final int roundedMinutes;

  @override
  List<Object?> get props => [
    projectId,
    projectName,
    taskId,
    taskName,
    entryCount,
    totalMinutes,
    billableMinutes,
    roundedMinutes,
  ];
}

/// Aggregated time report for a period.
class TimeReport extends Equatable {
  const TimeReport({
    required this.from,
    required this.to,
    required this.totalMinutes,
    required this.billableMinutes,
    required this.roundedMinutes,
    this.lines = const [],
  });

  final DateTime from;
  final DateTime to;
  final int totalMinutes;
  final int billableMinutes;
  final int roundedMinutes;
  final List<TimeReportLine> lines;

  @override
  List<Object?> get props => [
    from,
    to,
    totalMinutes,
    billableMinutes,
    roundedMinutes,
    lines,
  ];
}

const Object _sentinel = Object();
