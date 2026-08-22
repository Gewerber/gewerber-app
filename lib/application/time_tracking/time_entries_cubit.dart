import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/time_tracking/time_entries_state.dart';
import 'package:gewerber_app/core/errors/error_handler.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/repositories/time_tracking_repository.dart';

/// Owns the time entries, the running timer and the time report of the
/// active business.
@LazySingleton()
class TimeEntriesCubit extends Cubit<TimeEntriesState> {
  TimeEntriesCubit(this._repository) : super(const TimeEntriesState());

  final TimeTrackingRepository _repository;

  /// Loads the recent entries and restores a running timer, if any.
  Future<void> load() async {
    if (state.isLoading) return;
    emit(
      state.copyWith(status: TimeEntriesViewStatus.loading, clearFailure: true),
    );
    try {
      final entries = await _repository.listEntries(limit: 30);
      final running = await _repository.runningEntry();
      if (isClosed) return;
      emit(
        TimeEntriesState(
          status: TimeEntriesViewStatus.loaded,
          entries: entries.where((entry) => !entry.isRunning).toList(),
          running: running,
        ),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: TimeEntriesViewStatus.failure,
          failure: mapAppException(e),
        ),
      );
    } on Exception {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: TimeEntriesViewStatus.failure,
          failure: const NetworkFailure(),
        ),
      );
    }
  }

  /// Starts a timer. Returns `true` on success.
  Future<bool> startTimer({
    int? projectId,
    int? taskId,
    String? description,
    bool billable = false,
  }) async {
    if (state.isTimerBusy) return false;
    emit(state.copyWith(isTimerBusy: true));
    try {
      final running = await _repository.startTimer(
        projectId: projectId,
        taskId: taskId,
        description: description,
        billable: billable,
      );
      if (!isClosed) {
        emit(state.copyWith(running: running, isTimerBusy: false));
      }
      return true;
    } on Exception {
      if (!isClosed) emit(state.copyWith(isTimerBusy: false));
      return false;
    }
  }

  /// Stops the running timer. Returns `true` on success.
  Future<bool> stopTimer() async {
    if (state.isTimerBusy || !state.hasRunningTimer) return false;
    emit(state.copyWith(isTimerBusy: true));
    try {
      final stopped = await _repository.stopTimer();
      if (!isClosed) {
        emit(
          state.copyWith(
            running: null,
            isTimerBusy: false,
            entries: [stopped, ...state.entries],
          ),
        );
      }
      return true;
    } on Exception {
      if (!isClosed) emit(state.copyWith(isTimerBusy: false));
      return false;
    }
  }

  /// Creates a manual time entry. Returns `true` on success.
  Future<bool> createEntry({
    required DateTime startedAt,
    required int durationMinutes,
    int? projectId,
    int? taskId,
    String? description,
    bool billable = false,
  }) async {
    try {
      final entry = await _repository.createEntry(
        startedAt: startedAt,
        durationMinutes: durationMinutes,
        projectId: projectId,
        taskId: taskId,
        description: description,
        billable: billable,
      );
      if (!isClosed) {
        emit(state.copyWith(entries: [entry, ...state.entries]));
      }
      return true;
    } on Exception {
      return false;
    }
  }

  /// Deletes a time entry. Returns `true` on success.
  Future<bool> deleteEntry(int timeEntryId) async {
    try {
      await _repository.deleteEntry(timeEntryId);
      if (!isClosed) {
        emit(
          state.copyWith(
            entries: state.entries
                .where((entry) => entry.id != timeEntryId)
                .toList(),
          ),
        );
      }
      return true;
    } on Exception {
      return false;
    }
  }

  /// Loads the time report for the period. Returns `true` on success.
  Future<bool> loadReport(DateTime from, DateTime to, {int? projectId}) async {
    try {
      final report = await _repository.report(from, to, projectId: projectId);
      if (!isClosed) {
        emit(state.copyWith(report: report));
      }
      return true;
    } on Exception {
      return false;
    }
  }
}
