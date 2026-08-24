import 'package:equatable/equatable.dart';

import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/recurring_schedule.dart';

/// Loading state of the recurring-schedule list.
enum RecurringScheduleViewStatus { initial, loading, loaded, failure }

/// Immutable recurring-schedule state.
class RecurringScheduleState extends Equatable {
  const RecurringScheduleState({
    this.status = RecurringScheduleViewStatus.initial,
    this.schedules = const [],
    this.isSaving = false,
    this.failure,
  });

  final RecurringScheduleViewStatus status;
  final List<RecurringSchedule> schedules;

  /// Whether an attach/update/cancel request is currently in flight.
  final bool isSaving;

  /// Failure of the last failed operation (load or save).
  final Failure? failure;

  bool get isLoading => status == RecurringScheduleViewStatus.loading;

  RecurringScheduleState copyWith({
    RecurringScheduleViewStatus? status,
    List<RecurringSchedule>? schedules,
    bool? isSaving,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return RecurringScheduleState(
      status: status ?? this.status,
      schedules: schedules ?? this.schedules,
      isSaving: isSaving ?? this.isSaving,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, schedules, isSaving, failure];
}
