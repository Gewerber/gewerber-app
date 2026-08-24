import 'package:gewerber_app/domain/entities/dashboard.dart';

/// Contract for aggregated dashboard data.
///
/// Composes existing module repositories (invoicing, accounting, time
/// tracking, customers) into dashboard-ready snapshots. All methods may
/// throw `AppException`s; callers map them to failures per section.
abstract interface class DashboardRepository {
  /// Monthly income/expense totals for the last [months] months including
  /// the month of [anchor], oldest first.
  ///
  /// [anchor] defaults to "now"; [months] is capped so the trend stays a
  /// compact overview.
  Future<List<MonthlyFinancials>> monthlyFinancials({
    required int months,
    DateTime? anchor,
  });

  /// The [limit] most recent events across invoicing, accounting and time
  /// tracking, newest first. [anchor] defaults to "now".
  Future<List<RecentActivityItem>> recentActivity({
    int limit = defaultActivityLimit,
    DateTime? anchor,
  });

  /// Open (sent + overdue) receivables grouped per customer plus the overdue
  /// invoices sorted by urgency.
  Future<ReceivablesSummary> receivables();

  /// Assembles all dashboard sections in one call.
  ///
  /// Convenience over the three granular methods; section loaders that need
  /// independent retry semantics call those directly instead.
  Future<DashboardSummary> summary({required int months, DateTime? anchor});

  /// Default size of the activity feed.
  static const int defaultActivityLimit = 8;
}
