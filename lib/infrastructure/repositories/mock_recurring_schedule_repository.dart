import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/recurring_schedule.dart';
import 'package:gewerber_app/domain/repositories/recurring_schedule_repository.dart';

/// In-memory [RecurringScheduleRepository] backing the demo experience and
/// the widget tests. Data lives for the app session only.
@LazySingleton(as: RecurringScheduleRepository, env: [AppEnvironment.authMock])
class MockRecurringScheduleRepository implements RecurringScheduleRepository {
  final Map<int, RecurringSchedule> _schedules = {};

  /// Clears all stored schedules (used by tests to isolate scenarios).
  void reset() {
    _schedules.clear();
  }

  @override
  Future<List<RecurringSchedule>> list({int? limit, int? offset}) async {
    final all = _schedules.values.toList()
      ..sort((a, b) => a.effectiveNextDate.compareTo(b.effectiveNextDate));
    final start = offset ?? 0;
    return all.skip(start).take(limit ?? all.length).toList();
  }

  @override
  Future<RecurringSchedule> get(int invoiceId) async {
    final schedule = _schedules[invoiceId];
    if (schedule == null) {
      throw NotFoundException('No schedule for invoice $invoiceId');
    }
    return schedule;
  }

  @override
  Future<RecurringSchedule> attach({
    required int invoiceId,
    required RecurrenceInterval interval,
    DateTime? nextRecurrenceDate,
    DateTime? recurrenceEndDate,
    int? recurrenceMaxOccurrences,
  }) async {
    if (_schedules.containsKey(invoiceId)) {
      throw const ConflictException('Invoice already has a schedule');
    }
    final schedule = RecurringSchedule(
      invoiceId: invoiceId,
      invoiceNumber: 'RE-$invoiceId',
      interval: interval,
      issueDate: nextRecurrenceDate ?? DateTime.now(),
      nextRecurrenceDate: nextRecurrenceDate,
      recurrenceEndDate: recurrenceEndDate,
      recurrenceMaxOccurrences: recurrenceMaxOccurrences,
    );
    _schedules[invoiceId] = schedule;
    return schedule;
  }

  @override
  Future<RecurringSchedule> update(
    RecurringSchedule schedule, {
    RecurrenceInterval? interval,
    DateTime? nextRecurrenceDate,
    DateTime? recurrenceEndDate,
    int? recurrenceMaxOccurrences,
    bool clearRecurrenceEndDate = false,
    bool clearMaxOccurrences = false,
  }) async {
    // Mirror the server contract: `null` keeps the current value; clear
    // flags remove the limit regardless of the field value.
    final current = await get(schedule.invoiceId);
    final updated = current.copyWith(
      interval: interval ?? current.interval,
      nextRecurrenceDate: nextRecurrenceDate ?? current.nextRecurrenceDate,
      recurrenceEndDate: clearRecurrenceEndDate
          ? null
          : (recurrenceEndDate ?? current.recurrenceEndDate),
      recurrenceMaxOccurrences: clearMaxOccurrences
          ? null
          : (recurrenceMaxOccurrences ?? current.recurrenceMaxOccurrences),
    );
    _schedules[current.invoiceId] = updated;
    return updated;
  }

  @override
  Future<void> cancel(int invoiceId) async {
    await get(invoiceId);
    _schedules.remove(invoiceId);
  }
}
