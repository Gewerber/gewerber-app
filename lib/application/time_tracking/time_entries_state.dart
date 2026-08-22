import 'package:equatable/equatable.dart';

import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';

/// Loading state of the time entries view.
enum TimeEntriesViewStatus { initial, loading, loaded, failure }

/// Immutable time entries state (entries, running timer, report).
class TimeEntriesState extends Equatable {
  const TimeEntriesState({
    this.status = TimeEntriesViewStatus.initial,
    this.entries = const [],
    this.running,
    this.isTimerBusy = false,
    this.report,
    this.failure,
  });

  final TimeEntriesViewStatus status;

  /// Recent stopped time entries.
  final List<TimeEntry> entries;

  /// The currently running timer, or `null` when none is running.
  final TimeEntry? running;

  /// Whether a timer start/stop call is in flight.
  final bool isTimerBusy;

  /// The last loaded time report, if any.
  final TimeReport? report;

  final Failure? failure;

  bool get isLoading => status == TimeEntriesViewStatus.loading;

  bool get hasRunningTimer => running != null;

  TimeEntriesState copyWith({
    TimeEntriesViewStatus? status,
    List<TimeEntry>? entries,
    Object? running = _sentinel,
    bool? isTimerBusy,
    Object? report = _sentinel,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return TimeEntriesState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      running: running is TimeEntry? ? running : this.running,
      isTimerBusy: isTimerBusy ?? this.isTimerBusy,
      report: report is TimeReport? ? report : this.report,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
    status,
    entries,
    running,
    isTimerBusy,
    report,
    failure,
  ];
}

const Object _sentinel = Object();
