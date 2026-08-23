import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/time_billing/billing_estimate.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';

void main() {
  final project = Project(id: 1, name: 'Website', hourlyRateCents: 5000);
  final tasks = [
    Task(id: 11, projectId: 1, name: 'Design', hourlyRateCents: 6000),
    // A task without its own rate falls back to the project rate.
    const Task(id: 12, projectId: 1, name: 'Meetings'),
  ];

  TimeEntry entry(int id, {int? taskId, int minutes = 60}) {
    return TimeEntry(
      id: id,
      projectId: 1,
      taskId: taskId,
      startedAt: DateTime(2026, 8, 10),
      stoppedAt: DateTime(2026, 8, 10, 1),
      durationMinutes: minutes,
      billable: true,
    );
  }

  group('estimateEntryCents', () {
    test('uses the task rate when the task defines one', () {
      // 90 min × 6000 ¢/h ÷ 60 = 9000 ¢.
      expect(
        estimateEntryCents(
          entry(1, taskId: 11, minutes: 90),
          project: project,
          tasks: tasks,
        ),
        9000,
      );
    });

    test('falls back to the project rate when the task has none', () {
      // 30 min × 5000 ¢/h ÷ 60 = 2500 ¢.
      expect(
        estimateEntryCents(
          entry(2, taskId: 12, minutes: 30),
          project: project,
          tasks: tasks,
        ),
        2500,
      );
    });

    test('falls back to the project rate for task-less entries', () {
      expect(
        estimateEntryCents(
          entry(3, taskId: null, minutes: 120),
          project: project,
          tasks: tasks,
        ),
        10000,
      );
    });

    test('yields no estimate when neither task nor project define a rate', () {
      final unpricedProject = Project(id: 2, name: 'Internal');
      expect(
        estimateEntryCents(
          entry(4, taskId: null),
          project: unpricedProject,
          tasks: tasks,
        ),
        isNull,
      );
      // Unknown task id with an unpriced project as well.
      expect(
        estimateEntryCents(
          entry(5, taskId: 99),
          project: unpricedProject,
          tasks: tasks,
        ),
        isNull,
      );
    });

    test('rounds fractional cents to the nearest cent', () {
      // 20 min × 3500 ¢/h ÷ 60 = 1166.67 → 1167 ¢.
      final pricedTask = [
        Task(id: 13, projectId: 1, name: 'Odd', hourlyRateCents: 3500),
      ];
      expect(
        estimateEntryCents(
          entry(6, taskId: 13, minutes: 20),
          project: null,
          tasks: pricedTask,
        ),
        1167,
      );
    });
  });

  group('totalEstimatedCents', () {
    test('sums the per-entry estimates', () {
      final entries = [
        entry(1, taskId: 11, minutes: 60), // 6000
        entry(2, taskId: 12, minutes: 30), // 2500
        entry(3, taskId: null, minutes: 15), // 1250
      ];
      expect(
        totalEstimatedCents(entries, project: project, tasks: tasks),
        9750,
      );
    });

    test('skips entries without any applicable rate', () {
      final unpricedProject = Project(id: 2, name: 'Internal');
      final entries = [
        entry(1, taskId: 11, minutes: 60), // 6000 (task rate)
        entry(2, taskId: null, minutes: 60), // no rate anywhere
      ];
      expect(
        totalEstimatedCents(entries, project: unpricedProject, tasks: tasks),
        6000,
      );
    });

    test('is zero without estimable entries', () {
      expect(
        totalEstimatedCents(
          [entry(1, taskId: null)],
          project: null,
          tasks: tasks,
        ),
        0,
      );
    });
  });
}
