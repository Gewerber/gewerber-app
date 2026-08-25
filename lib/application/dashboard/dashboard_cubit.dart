import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/dashboard/dashboard_state.dart';
import 'package:gewerber_app/core/errors/error_handler.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/repositories/dashboard_repository.dart';

/// Owns the aggregated dashboard sections (trends, activity, receivables).
///
/// Every section loads and fails independently; a retry only re-runs the
/// section that failed.
@LazySingleton()
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repository) : super(const DashboardState());

  final DashboardRepository _repository;

  /// Loads all sections concurrently.
  Future<void> loadAll() {
    return Future.wait([loadTrends(), loadActivity(), loadReceivables()]);
  }

  /// Loads (or reloads) the monthly trend with a window of [months] months
  /// (capped by the repository contract). Previously loaded months stay in
  /// state while loading and on failure.
  Future<void> loadTrends({int? months}) async {
    if (state.trendsStatus == DashboardSectionStatus.loading) return;
    emit(
      state.copyWith(
        trendsStatus: DashboardSectionStatus.loading,
        clearTrendsFailure: true,
      ),
    );
    try {
      final effectiveMonths = (months ?? state.trendMonths).clamp(
        1,
        DashboardRepository.maxTrendMonths,
      );
      final result = await _repository.monthlyFinancials(
        months: effectiveMonths,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          trendsStatus: DashboardSectionStatus.loaded,
          trendMonths: effectiveMonths,
          months: result,
        ),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          trendsStatus: DashboardSectionStatus.failure,
          trendsFailure: mapAppException(e),
        ),
      );
    } on Exception {
      if (isClosed) return;
      emit(
        state.copyWith(
          trendsStatus: DashboardSectionStatus.failure,
          trendsFailure: const NetworkFailure(),
        ),
      );
    }
  }

  /// Loads (or reloads) the recent activity feed. Previously loaded items
  /// stay in state while loading and on failure.
  Future<void> loadActivity() async {
    if (state.activityStatus == DashboardSectionStatus.loading) return;
    emit(
      state.copyWith(
        activityStatus: DashboardSectionStatus.loading,
        clearActivityFailure: true,
      ),
    );
    try {
      final result = await _repository.recentActivity();
      if (isClosed) return;
      emit(
        state.copyWith(
          activityStatus: DashboardSectionStatus.loaded,
          activity: result,
        ),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          activityStatus: DashboardSectionStatus.failure,
          activityFailure: mapAppException(e),
        ),
      );
    } on Exception {
      if (isClosed) return;
      emit(
        state.copyWith(
          activityStatus: DashboardSectionStatus.failure,
          activityFailure: const NetworkFailure(),
        ),
      );
    }
  }

  /// Loads (or reloads) the receivables summary. The previously loaded value
  /// stays in state while loading and on failure.
  Future<void> loadReceivables() async {
    if (state.receivablesStatus == DashboardSectionStatus.loading) return;
    emit(
      state.copyWith(
        receivablesStatus: DashboardSectionStatus.loading,
        clearReceivablesFailure: true,
      ),
    );
    try {
      final result = await _repository.receivables();
      if (isClosed) return;
      emit(
        state.copyWith(
          receivablesStatus: DashboardSectionStatus.loaded,
          receivables: result,
        ),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          receivablesStatus: DashboardSectionStatus.failure,
          receivablesFailure: mapAppException(e),
        ),
      );
    } on Exception {
      if (isClosed) return;
      emit(
        state.copyWith(
          receivablesStatus: DashboardSectionStatus.failure,
          receivablesFailure: const NetworkFailure(),
        ),
      );
    }
  }
}
