import 'package:equatable/equatable.dart';

import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/domain/repositories/dashboard_repository.dart';

/// Loading state of a single dashboard section.
///
/// Sections load (and fail) independently so one broken endpoint does not
/// blank the whole dashboard.
enum DashboardSectionStatus { initial, loading, loaded, failure }

/// Immutable dashboard state.
///
/// Data is kept across reloads: while a section is `loading` or after a
/// `failure`, the previously loaded values stay available (stale-while-
/// refresh) and the UI renders them with a spinner/error affordance.
class DashboardState extends Equatable {
  const DashboardState({
    this.trendsStatus = DashboardSectionStatus.initial,
    this.activityStatus = DashboardSectionStatus.initial,
    this.receivablesStatus = DashboardSectionStatus.initial,
    this.trendMonths = DashboardRepository.defaultTrendMonths,
    this.months = const [],
    this.activity = const [],
    this.receivables,
    this.trendsFailure,
    this.activityFailure,
    this.receivablesFailure,
  });

  final DashboardSectionStatus trendsStatus;
  final DashboardSectionStatus activityStatus;
  final DashboardSectionStatus receivablesStatus;

  /// Current trend window in months (6 or 12).
  final int trendMonths;

  /// Monthly income/expense totals, oldest first.
  final List<MonthlyFinancials> months;

  /// Recent events across modules, newest first.
  final List<RecentActivityItem> activity;

  final ReceivablesSummary? receivables;

  final Failure? trendsFailure;
  final Failure? activityFailure;
  final Failure? receivablesFailure;

  /// Whether every section has finished loading at least once.
  bool get isSettled =>
      trendsStatus != DashboardSectionStatus.loading &&
      activityStatus != DashboardSectionStatus.loading &&
      receivablesStatus != DashboardSectionStatus.loading;

  DashboardState copyWith({
    DashboardSectionStatus? trendsStatus,
    DashboardSectionStatus? activityStatus,
    DashboardSectionStatus? receivablesStatus,
    int? trendMonths,
    List<MonthlyFinancials>? months,
    List<RecentActivityItem>? activity,
    Object? receivables = _sentinel,
    Failure? trendsFailure,
    Failure? activityFailure,
    Failure? receivablesFailure,
    bool clearTrendsFailure = false,
    bool clearActivityFailure = false,
    bool clearReceivablesFailure = false,
  }) {
    return DashboardState(
      trendsStatus: trendsStatus ?? this.trendsStatus,
      activityStatus: activityStatus ?? this.activityStatus,
      receivablesStatus: receivablesStatus ?? this.receivablesStatus,
      trendMonths: trendMonths ?? this.trendMonths,
      months: months ?? this.months,
      activity: activity ?? this.activity,
      receivables: receivables is ReceivablesSummary?
          ? receivables
          : this.receivables,
      trendsFailure: clearTrendsFailure
          ? null
          : (trendsFailure ?? this.trendsFailure),
      activityFailure: clearActivityFailure
          ? null
          : (activityFailure ?? this.activityFailure),
      receivablesFailure: clearReceivablesFailure
          ? null
          : (receivablesFailure ?? this.receivablesFailure),
    );
  }

  @override
  List<Object?> get props => [
    trendsStatus,
    activityStatus,
    receivablesStatus,
    trendMonths,
    months,
    activity,
    receivables,
    trendsFailure,
    activityFailure,
    receivablesFailure,
  ];
}

const Object _sentinel = Object();
