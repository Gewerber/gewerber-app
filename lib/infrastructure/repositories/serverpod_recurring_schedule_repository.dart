import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/recurring_schedule.dart';
import 'package:gewerber_app/domain/repositories/recurring_schedule_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/recurring_schedule_remote_data_source.dart';

/// Serverpod-backed [RecurringScheduleRepository].
@LazySingleton(as: RecurringScheduleRepository, env: [AppEnvironment.authLive])
class ServerpodRecurringScheduleRepository
    implements RecurringScheduleRepository {
  ServerpodRecurringScheduleRepository(this._dataSource);

  final RecurringScheduleRemoteDataSource _dataSource;

  @override
  Future<List<RecurringSchedule>> list({int? limit, int? offset}) =>
      _guard(() => _dataSource.list(limit: limit, offset: offset));

  @override
  Future<RecurringSchedule> get(int invoiceId) =>
      _guard(() => _dataSource.get(invoiceId));

  @override
  Future<RecurringSchedule> attach({
    required int invoiceId,
    required RecurrenceInterval interval,
    DateTime? nextRecurrenceDate,
    DateTime? recurrenceEndDate,
    int? recurrenceMaxOccurrences,
  }) => _guard(
    () => _dataSource.attach(
      invoiceId: invoiceId,
      interval: interval,
      nextRecurrenceDate: nextRecurrenceDate,
      recurrenceEndDate: recurrenceEndDate,
      recurrenceMaxOccurrences: recurrenceMaxOccurrences,
    ),
  );

  @override
  Future<RecurringSchedule> update(
    RecurringSchedule schedule, {
    RecurrenceInterval? interval,
    DateTime? nextRecurrenceDate,
    DateTime? recurrenceEndDate,
    int? recurrenceMaxOccurrences,
    bool clearRecurrenceEndDate = false,
    bool clearMaxOccurrences = false,
  }) => _guard(
    () => _dataSource.update(
      schedule,
      interval: interval,
      nextRecurrenceDate: nextRecurrenceDate,
      recurrenceEndDate: recurrenceEndDate,
      recurrenceMaxOccurrences: recurrenceMaxOccurrences,
      clearRecurrenceEndDate: clearRecurrenceEndDate,
      clearMaxOccurrences: clearMaxOccurrences,
    ),
  );

  @override
  Future<void> cancel(int invoiceId) =>
      _guard(() => _dataSource.cancel(invoiceId));

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
