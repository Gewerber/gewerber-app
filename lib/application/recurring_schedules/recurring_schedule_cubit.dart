import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/recurring_schedules/recurring_schedule_state.dart';
import 'package:gewerber_app/core/errors/error_handler.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/recurring_schedule.dart';
import 'package:gewerber_app/domain/repositories/recurring_schedule_repository.dart';

/// Owns the recurring invoice schedules of the active business.
@LazySingleton()
class RecurringScheduleCubit extends Cubit<RecurringScheduleState> {
  RecurringScheduleCubit(this._repository)
    : super(const RecurringScheduleState());

  final RecurringScheduleRepository _repository;

  /// Loads the schedules, upcoming next issue first.
  Future<void> load() async {
    if (state.isLoading) return;
    emit(
      state.copyWith(
        status: RecurringScheduleViewStatus.loading,
        clearFailure: true,
      ),
    );
    try {
      final schedules = await _repository.list();
      if (isClosed) return;
      emit(
        RecurringScheduleState(
          status: RecurringScheduleViewStatus.loaded,
          schedules: schedules,
        ),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: RecurringScheduleViewStatus.failure,
          failure: mapAppException(e),
        ),
      );
    } on Exception {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: RecurringScheduleViewStatus.failure,
          failure: const NetworkFailure(),
        ),
      );
    }
  }

  /// Attaches a new schedule to an existing invoice.
  ///
  /// Returns `true` on success. On failure the mapped [Failure] is exposed
  /// via the state (e.g. `ConflictFailure` when the invoice already has a
  /// schedule).
  Future<bool> attach({
    required int invoiceId,
    required RecurrenceInterval interval,
    DateTime? nextRecurrenceDate,
    DateTime? recurrenceEndDate,
    int? recurrenceMaxOccurrences,
  }) async {
    if (state.isSaving) return false;
    emit(state.copyWith(isSaving: true, clearFailure: true));
    try {
      final schedule = await _repository.attach(
        invoiceId: invoiceId,
        interval: interval,
        nextRecurrenceDate: nextRecurrenceDate,
        recurrenceEndDate: recurrenceEndDate,
        recurrenceMaxOccurrences: recurrenceMaxOccurrences,
      );
      if (!isClosed) emit(_saved(schedule));
      return true;
    } on AppException catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isSaving: false, failure: mapAppException(e)));
      }
      return false;
    } on Exception {
      if (!isClosed) {
        emit(state.copyWith(isSaving: false, failure: const NetworkFailure()));
      }
      return false;
    }
  }

  /// Updates an existing schedule (`null` arguments keep their value).
  ///
  /// The clear flags lift an end date / occurrence limit entirely; they
  /// take precedence over the corresponding field argument.
  ///
  /// Returns `true` on success; failures are exposed like in [attach].
  Future<bool> update(
    RecurringSchedule schedule, {
    RecurrenceInterval? interval,
    DateTime? nextRecurrenceDate,
    DateTime? recurrenceEndDate,
    int? recurrenceMaxOccurrences,
    bool clearRecurrenceEndDate = false,
    bool clearMaxOccurrences = false,
  }) async {
    if (state.isSaving) return false;
    emit(state.copyWith(isSaving: true, clearFailure: true));
    try {
      final updated = await _repository.update(
        schedule,
        interval: interval,
        nextRecurrenceDate: nextRecurrenceDate,
        recurrenceEndDate: recurrenceEndDate,
        recurrenceMaxOccurrences: recurrenceMaxOccurrences,
        clearRecurrenceEndDate: clearRecurrenceEndDate,
        clearMaxOccurrences: clearMaxOccurrences,
      );
      if (!isClosed) emit(_saved(updated));
      return true;
    } on AppException catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isSaving: false, failure: mapAppException(e)));
      }
      return false;
    } on Exception {
      if (!isClosed) {
        emit(state.copyWith(isSaving: false, failure: const NetworkFailure()));
      }
      return false;
    }
  }

  /// Cancels the schedule attached to [invoiceId]. Already materialized
  /// invoices are kept (server-side rule).
  ///
  /// Returns `true` on success; failures are exposed like in [attach].
  Future<bool> cancel(int invoiceId) async {
    if (state.isSaving) return false;
    emit(state.copyWith(isSaving: true, clearFailure: true));
    try {
      await _repository.cancel(invoiceId);
      if (!isClosed) {
        emit(
          RecurringScheduleState(
            status: RecurringScheduleViewStatus.loaded,
            schedules: state.schedules
                .where((schedule) => schedule.invoiceId != invoiceId)
                .toList(),
          ),
        );
      }
      return true;
    } on NotFoundException catch (e) {
      // The schedule vanished server-side — drop it from the list too.
      if (!isClosed) {
        emit(
          state.copyWith(
            isSaving: false,
            failure: mapAppException(e),
            schedules: state.schedules
                .where((schedule) => schedule.invoiceId != invoiceId)
                .toList(),
          ),
        );
      }
      return false;
    } on AppException catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isSaving: false, failure: mapAppException(e)));
      }
      return false;
    } on Exception {
      if (!isClosed) {
        emit(state.copyWith(isSaving: false, failure: const NetworkFailure()));
      }
      return false;
    }
  }

  /// Inserts or replaces [saved] in the list, keeping the upcoming-first
  /// ordering of the server list endpoint.
  RecurringScheduleState _saved(RecurringSchedule saved) {
    final schedules = [
      for (final current in state.schedules)
        if (current.invoiceId == saved.invoiceId) saved else current,
    ];
    if (!schedules.any((schedule) => schedule.invoiceId == saved.invoiceId)) {
      schedules.add(saved);
    }
    schedules.sort(
      (a, b) => a.effectiveNextDate.compareTo(b.effectiveNextDate),
    );
    return RecurringScheduleState(
      status: RecurringScheduleViewStatus.loaded,
      schedules: schedules,
    );
  }
}
