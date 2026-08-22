import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/domain/entities/time_tracking.dart';

/// Maps between the domain time tracking entities and the protocol models.
@Injectable()
class TimeTrackingMapper {
  const TimeTrackingMapper();

  Project projectFromModel(sdk.Project model) {
    return Project(
      id: model.id ?? -1,
      name: model.name,
      status: ProjectStatus.fromName(model.status.name),
      customerId: model.customerId,
      hourlyRateCents: model.hourlyRateCents,
      notes: model.notes,
    );
  }

  Task taskFromModel(sdk.Task model) {
    return Task(
      id: model.id ?? -1,
      projectId: model.projectId,
      name: model.name,
      status: TaskStatus.fromName(model.status.name),
      hourlyRateCents: model.hourlyRateCents,
    );
  }

  TimeEntry entryFromModel(sdk.TimeEntry model) {
    return TimeEntry(
      id: model.id ?? -1,
      projectId: model.projectId,
      taskId: model.taskId,
      description: model.description,
      startedAt: model.startedAt,
      stoppedAt: model.stoppedAt,
      durationMinutes: model.durationMinutes,
      billable: model.billable,
      invoicedAt: model.invoicedAt,
    );
  }

  TimeReportLine reportLineFromModel(sdk.TimeReportLine model) {
    return TimeReportLine(
      projectId: model.projectId,
      projectName: model.projectName,
      taskId: model.taskId,
      taskName: model.taskName,
      entryCount: model.entryCount,
      totalMinutes: model.totalMinutes,
      billableMinutes: model.billableMinutes,
      roundedMinutes: model.roundedMinutes,
    );
  }

  TimeReport reportFromModel(sdk.TimeReport model) {
    return TimeReport(
      from: model.from,
      to: model.to,
      totalMinutes: model.totalMinutes,
      billableMinutes: model.billableMinutes,
      roundedMinutes: model.roundedMinutes,
      lines: model.lines.map(reportLineFromModel).toList(),
    );
  }

  sdk.ProjectStatus toProtocolProjectStatus(ProjectStatus status) =>
      sdk.ProjectStatus.values.byName(status.name);

  sdk.TaskStatus toProtocolTaskStatus(TaskStatus status) =>
      sdk.TaskStatus.values.byName(status.name);
}
