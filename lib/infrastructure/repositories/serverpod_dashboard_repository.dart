import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/domain/repositories/dashboard_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/dashboard_remote_data_source.dart';
import 'package:gewerber_app/infrastructure/mappers/dashboard_mapper.dart';

/// [DashboardRepository] backed by the server-side `dashboard.getSummary`
/// endpoint.
///
/// Every method is a single round trip; the server assembles trends, the
/// activity feed and receivables and clamps all list sizes itself.
@LazySingleton(as: DashboardRepository, env: [AppEnvironment.authLive])
class ServerpodDashboardRepository implements DashboardRepository {
  ServerpodDashboardRepository(this._remote, this._mapper);

  final DashboardRemoteDataSource _remote;
  final DashboardMapper _mapper;

  @override
  Future<List<MonthlyFinancials>> monthlyFinancials({
    required int months,
    DateTime? anchor,
  }) async {
    final dto = await _remote.getSummary(
      trendMonths: months.clamp(1, DashboardRepository.maxTrendMonths),
    );
    return _mapper.monthsFromModel(dto);
  }

  @override
  Future<List<RecentActivityItem>> recentActivity({
    int limit = DashboardRepository.defaultActivityLimit,
    DateTime? anchor,
  }) async {
    final dto = await _remote.getSummary(recentLimit: limit);
    return _mapper.activityFromModel(dto);
  }

  @override
  Future<ReceivablesSummary> receivables() async {
    // The server's default debtor/overdue caps comfortably cover the card.
    final dto = await _remote.getSummary();
    return _mapper.receivablesFromModel(dto.receivables);
  }

  @override
  Future<DashboardSummary> summary({
    required int months,
    DateTime? anchor,
  }) async {
    final dto = await _remote.getSummary(
      trendMonths: months.clamp(1, DashboardRepository.maxTrendMonths),
      recentLimit: DashboardRepository.defaultActivityLimit,
    );
    return _mapper.summaryFromModel(dto);
  }
}
