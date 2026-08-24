import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/recurring_schedules/recurring_schedule_cubit.dart';
import 'package:gewerber_app/application/recurring_schedules/recurring_schedule_state.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/recurring_schedule.dart';
import 'package:gewerber_app/domain/repositories/recurring_schedule_repository.dart';

class _FakeRecurringScheduleRepository implements RecurringScheduleRepository {
  _FakeRecurringScheduleRepository({
    List<RecurringSchedule>? schedules,
    this.failLoad = false,
    this.failSave = false,
  }) : _schedules = {
         for (final schedule in schedules ?? const <RecurringSchedule>[])
           schedule.invoiceId: schedule,
       };

  final Map<int, RecurringSchedule> _schedules;
  bool failLoad;
  bool failSave;

  /// Clear flags captured by the last [update] call.
  bool lastUpdateClearedEndDate = false;
  bool lastUpdateClearedMaxOccurrences = false;

  @override
  Future<List<RecurringSchedule>> list({int? limit, int? offset}) async {
    if (failLoad) throw const NetworkException();
    final all = _schedules.values.toList()
      ..sort((a, b) => a.effectiveNextDate.compareTo(b.effectiveNextDate));
    return all.skip(offset ?? 0).take(limit ?? all.length).toList();
  }

  @override
  Future<RecurringSchedule> get(int invoiceId) async {
    final schedule = _schedules[invoiceId];
    if (schedule == null) throw const NotFoundException();
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
    if (failSave) throw const NetworkException();
    if (_schedules.containsKey(invoiceId)) {
      throw const ConflictException('already scheduled');
    }
    final schedule = RecurringSchedule(
      invoiceId: invoiceId,
      invoiceNumber: 'RE-$invoiceId',
      interval: interval,
      issueDate: nextRecurrenceDate ?? DateTime(2026, 8, 1),
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
    if (failSave) throw const NetworkException();
    lastUpdateClearedEndDate = clearRecurrenceEndDate;
    lastUpdateClearedMaxOccurrences = clearMaxOccurrences;
    final current = _schedules[schedule.invoiceId];
    if (current == null) throw const NotFoundException();
    // Mirror the server contract: `null` keeps the current value; the
    // clear flags remove the limit regardless of the field value.
    final updated = RecurringSchedule(
      invoiceId: current.invoiceId,
      invoiceNumber: current.invoiceNumber,
      interval: interval ?? current.interval,
      issueDate: current.issueDate,
      customerId: current.customerId,
      nextRecurrenceDate: nextRecurrenceDate ?? current.nextRecurrenceDate,
      recurrenceEndDate: clearRecurrenceEndDate
          ? null
          : (recurrenceEndDate ?? current.recurrenceEndDate),
      recurrenceMaxOccurrences: clearMaxOccurrences
          ? null
          : (recurrenceMaxOccurrences ?? current.recurrenceMaxOccurrences),
      recurrenceOccurrencesCreated: current.recurrenceOccurrencesCreated,
    );
    _schedules[current.invoiceId] = updated;
    return updated;
  }

  @override
  Future<void> cancel(int invoiceId) async {
    if (failSave) throw const NetworkException();
    if (!_schedules.containsKey(invoiceId)) throw const NotFoundException();
    _schedules.remove(invoiceId);
  }
}

RecurringSchedule _schedule(
  int invoiceId, {
  DateTime? next,
  RecurrenceInterval interval = RecurrenceInterval.monthly,
}) {
  return RecurringSchedule(
    invoiceId: invoiceId,
    invoiceNumber: 'RE-$invoiceId',
    interval: interval,
    issueDate: next ?? DateTime(2026, 9, 1),
    nextRecurrenceDate: next,
  );
}

void main() {
  test('starts in the initial state', () {
    final cubit = RecurringScheduleCubit(_FakeRecurringScheduleRepository());

    expect(cubit.state.status, RecurringScheduleViewStatus.initial);
    expect(cubit.state.schedules, isEmpty);
  });

  test('load emits loading then loaded with the schedules', () async {
    final cubit = RecurringScheduleCubit(
      _FakeRecurringScheduleRepository(schedules: [_schedule(1)]),
    );
    final states = <RecurringScheduleViewStatus>[];
    cubit.stream.listen((state) => states.add(state.status));

    await cubit.load();
    await Future<void>.delayed(Duration.zero);

    expect(states, [
      RecurringScheduleViewStatus.loading,
      RecurringScheduleViewStatus.loaded,
    ]);
    expect(cubit.state.schedules.single.invoiceId, 1);
  });

  test('load failure maps to a failure state', () async {
    final cubit = RecurringScheduleCubit(
      _FakeRecurringScheduleRepository(failLoad: true),
    );

    await cubit.load();

    expect(cubit.state.status, RecurringScheduleViewStatus.failure);
    expect(cubit.state.failure, isA<NetworkFailure>());
  });

  test('attach appends the schedule and returns true', () async {
    final cubit = RecurringScheduleCubit(_FakeRecurringScheduleRepository());

    final saved = await cubit.attach(
      invoiceId: 7,
      interval: RecurrenceInterval.quarterly,
      recurrenceMaxOccurrences: 4,
    );

    expect(saved, isTrue);
    final schedule = cubit.state.schedules.single;
    expect(schedule.invoiceId, 7);
    expect(schedule.interval, RecurrenceInterval.quarterly);
    expect(schedule.recurrenceMaxOccurrences, 4);
    expect(cubit.state.isSaving, isFalse);
  });

  test(
    'conflicting attach exposes ConflictFailure and returns false',
    () async {
      final cubit = RecurringScheduleCubit(
        _FakeRecurringScheduleRepository(schedules: [_schedule(1)]),
      );
      await cubit.load();

      final saved = await cubit.attach(
        invoiceId: 1,
        interval: RecurrenceInterval.weekly,
      );

      expect(saved, isFalse);
      expect(cubit.state.failure, isA<ConflictFailure>());
      expect(cubit.state.schedules.single.interval, RecurrenceInterval.monthly);
      expect(cubit.state.isSaving, isFalse);
    },
  );

  test('update replaces the matching schedule', () async {
    final cubit = RecurringScheduleCubit(
      _FakeRecurringScheduleRepository(schedules: [_schedule(1)]),
    );
    await cubit.load();

    final saved = await cubit.update(
      _schedule(1),
      interval: RecurrenceInterval.yearly,
    );

    expect(saved, isTrue);
    expect(cubit.state.schedules.single.interval, RecurrenceInterval.yearly);
  });

  test('update forwards the clear flags to the repository', () async {
    final repository = _FakeRecurringScheduleRepository(
      schedules: [
        RecurringSchedule(
          invoiceId: 1,
          invoiceNumber: 'RE-1',
          interval: RecurrenceInterval.monthly,
          issueDate: DateTime(2026, 9, 1),
          nextRecurrenceDate: DateTime(2026, 9, 1),
          recurrenceEndDate: DateTime(2026, 12, 31),
          recurrenceMaxOccurrences: 12,
        ),
      ],
    );
    final cubit = RecurringScheduleCubit(repository);
    await cubit.load();

    final saved = await cubit.update(
      cubit.state.schedules.single,
      interval: RecurrenceInterval.monthly,
      recurrenceEndDate: null,
      recurrenceMaxOccurrences: null,
      clearRecurrenceEndDate: true,
      clearMaxOccurrences: true,
    );

    expect(saved, isTrue);
    expect(repository.lastUpdateClearedEndDate, isTrue);
    expect(repository.lastUpdateClearedMaxOccurrences, isTrue);
    // Both limits are lifted on the returned schedule.
    expect(cubit.state.schedules.single.recurrenceEndDate, isNull);
    expect(cubit.state.schedules.single.recurrenceMaxOccurrences, isNull);
  });

  test('update failure exposes the failure and keeps the list', () async {
    final cubit = RecurringScheduleCubit(
      _FakeRecurringScheduleRepository(
        schedules: [_schedule(1)],
        failSave: true,
      ),
    );
    await cubit.load();

    final saved = await cubit.update(
      _schedule(1),
      interval: RecurrenceInterval.yearly,
    );

    expect(saved, isFalse);
    expect(cubit.state.failure, isA<NetworkFailure>());
    expect(cubit.state.schedules.single.interval, RecurrenceInterval.monthly);
  });

  test('cancel removes the schedule from the list', () async {
    final cubit = RecurringScheduleCubit(
      _FakeRecurringScheduleRepository(schedules: [_schedule(1), _schedule(2)]),
    );
    await cubit.load();

    final cancelled = await cubit.cancel(1);

    expect(cancelled, isTrue);
    expect(cubit.state.schedules.single.invoiceId, 2);
  });

  test('cancelling an unknown schedule surfaces NotFoundFailure', () async {
    final cubit = RecurringScheduleCubit(_FakeRecurringScheduleRepository());
    await cubit.load();

    final cancelled = await cubit.cancel(42);

    expect(cancelled, isFalse);
    expect(cubit.state.failure, isA<NotFoundFailure>());
  });

  test('saved schedules stay sorted by effective next date', () async {
    final cubit = RecurringScheduleCubit(
      _FakeRecurringScheduleRepository(
        schedules: [
          _schedule(1, next: DateTime(2026, 10, 1)),
          _schedule(2, next: DateTime(2026, 9, 1)),
        ],
      ),
    );
    await cubit.load();

    await cubit.attach(
      invoiceId: 3,
      interval: RecurrenceInterval.daily,
      nextRecurrenceDate: DateTime(2026, 8, 15),
    );

    expect(
      cubit.state.schedules.map((schedule) => schedule.invoiceId).toList(),
      [3, 2, 1],
    );
  });
}
