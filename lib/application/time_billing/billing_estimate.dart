/// Estimate calculations for the billing preview of
/// `timeEntry.createInvoice`.
///
/// The server computes the actual invoice amounts, so these numbers are a
/// client-side estimate only. Per entry the task's hourly rate wins over the
/// project's; when neither defines a rate there is no estimate (`null`).
library;

import 'package:gewerber_app/domain/entities/time_tracking.dart';

/// Estimated billing amount of [entry] in cents, or `null` when neither the
/// entry's task nor [project] defines an hourly rate.
///
/// `durationMinutes × hourlyRateCents ÷ 60`, rounded to whole cents. The
/// task rate wins (`task ?? project`); a task without its own rate falls
/// back to the project's.
int? estimateEntryCents(
  TimeEntry entry, {
  required Project? project,
  required List<Task> tasks,
}) {
  final minutes = entry.durationMinutes;
  if (minutes == null) return null;

  int? taskRateCents;
  final taskId = entry.taskId;
  if (taskId != null) {
    for (final task in tasks) {
      if (task.id == taskId) {
        taskRateCents = task.hourlyRateCents;
        break;
      }
    }
  }
  final rateCents = taskRateCents ?? project?.hourlyRateCents;
  if (rateCents == null || rateCents < 0) return null;

  return (minutes * rateCents / 60).round();
}

/// Summed estimate over [entries] in cents. Entries without an estimable
/// rate contribute nothing; callers surface them individually as "no
/// estimate".
int totalEstimatedCents(
  List<TimeEntry> entries, {
  required Project? project,
  required List<Task> tasks,
}) {
  var total = 0;
  for (final entry in entries) {
    total += estimateEntryCents(entry, project: project, tasks: tasks) ?? 0;
  }
  return total;
}
