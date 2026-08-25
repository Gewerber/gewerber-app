import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/dashboard/dashboard_cubit.dart';
import 'package:gewerber_app/application/dashboard/dashboard_state.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/repositories/dashboard_repository.dart';

/// Hand-written fake (no mockito), mirroring the house test style.
class _FakeDashboardRepository implements DashboardRepository {
  _FakeDashboardRepository({this.months = const [], this.activity = const []});

  List<MonthlyFinancials> months;
  final List<RecentActivityItem> activity;
  ReceivablesSummary receivablesValue = const ReceivablesSummary(
    outstandingTotalCents: 0,
    debtors: [],
    overdueInvoices: [],
  );

  /// When set, trend fetches block until the completer resolves.
  Completer<void>? trendsGate;

  int trendsCalls = 0;
  int activityCalls = 0;
  int receivablesCalls = 0;

  Exception? trendsError;
  Exception? activityError;
  Exception? receivablesError;

  @override
  Future<List<MonthlyFinancials>> monthlyFinancials({
    required int months,
    DateTime? anchor,
  }) async {
    trendsCalls++;
    if (trendsGate != null) await trendsGate!.future;
    if (trendsError != null) throw trendsError!;
    return this.months;
  }

  @override
  Future<List<RecentActivityItem>> recentActivity({
    int limit = DashboardRepository.defaultActivityLimit,
    DateTime? anchor,
  }) async {
    activityCalls++;
    if (activityError != null) throw activityError!;
    return activity;
  }

  @override
  Future<ReceivablesSummary> receivables() async {
    receivablesCalls++;
    if (receivablesError != null) throw receivablesError!;
    return receivablesValue;
  }

  @override
  Future<DashboardSummary> summary({
    required int months,
    DateTime? anchor,
  }) async {
    final results = await Future.wait([
      monthlyFinancials(months: months, anchor: anchor),
      recentActivity(anchor: anchor),
      receivables(),
    ]);
    return DashboardSummary(
      months: results[0] as List<MonthlyFinancials>,
      activity: results[1] as List<RecentActivityItem>,
      receivables: results[2] as ReceivablesSummary,
      generatedAt: DateTime.now(),
    );
  }
}

MonthlyFinancials month(int monthOfYear, int incomeCents) => MonthlyFinancials(
  monthStart: DateTime(2026, monthOfYear),
  incomeCents: incomeCents,
  expenseCents: 1000,
);

void main() {
  test('loadAll settles every section into loaded', () async {
    final repository =
        _FakeDashboardRepository(
            months: [month(7, 5000), month(8, 7000)],
            activity: [
              InvoiceActivity(
                invoice: Invoice(
                  id: 1,
                  number: 'RE-1',
                  issueDate: DateTime(2026),
                ),
                at: DateTime(2026),
              ),
            ],
          )
          ..receivablesValue = const ReceivablesSummary(
            outstandingTotalCents: 4200,
            debtors: [
              DebtorLine(
                customerId: 1,
                displayName: 'Müller GmbH',
                outstandingCents: 4200,
                invoiceCount: 1,
              ),
            ],
            overdueInvoices: [],
          );

    final cubit = DashboardCubit(repository);
    await cubit.loadAll();

    expect(cubit.state.trendsStatus, DashboardSectionStatus.loaded);
    expect(cubit.state.activityStatus, DashboardSectionStatus.loaded);
    expect(cubit.state.receivablesStatus, DashboardSectionStatus.loaded);
    expect(cubit.state.months, hasLength(2));
    expect(cubit.state.activity.single, isA<InvoiceActivity>());
    expect(cubit.state.receivables?.outstandingTotalCents, 4200);
  });

  test('a failing section does not break the others', () async {
    final repository = _FakeDashboardRepository()
      ..trendsError = const NetworkException('offline');

    final cubit = DashboardCubit(repository);
    await cubit.loadAll();

    expect(cubit.state.trendsStatus, DashboardSectionStatus.failure);
    expect(cubit.state.trendsFailure, isA<NetworkFailure>());
    // Isolation: the healthy sections still loaded.
    expect(cubit.state.activityStatus, DashboardSectionStatus.loaded);
    expect(cubit.state.receivablesStatus, DashboardSectionStatus.loaded);
  });

  test('maps AppExceptions to their domain failure', () async {
    final repository = _FakeDashboardRepository()
      ..receivablesError = const NotFoundException();

    final cubit = DashboardCubit(repository);
    await cubit.loadReceivables();

    expect(cubit.state.receivablesStatus, DashboardSectionStatus.failure);
    expect(cubit.state.receivablesFailure, isA<NotFoundFailure>());
  });

  test('retry re-runs only the failed section', () async {
    final repository = _FakeDashboardRepository()
      ..activityError = const NetworkException('offline');

    final cubit = DashboardCubit(repository);
    await cubit.loadAll();
    expect(repository.activityCalls, 1);
    expect(repository.trendsCalls, 1);

    repository.activityError = null;
    await cubit.loadActivity();

    expect(repository.activityCalls, 2);
    // Trends and receivables were not refetched.
    expect(repository.trendsCalls, 1);
    expect(repository.receivablesCalls, 1);
    expect(cubit.state.activityStatus, DashboardSectionStatus.loaded);
  });

  test('refresh keeps stale data while loading and after failure', () async {
    final repository = _FakeDashboardRepository(months: [month(8, 1000)]);
    final cubit = DashboardCubit(repository);
    await cubit.loadTrends();
    expect(cubit.state.months.single.incomeCents, 1000);

    // Next load fails; the stale months must survive.
    repository.trendsError = const NetworkException('offline');
    await cubit.loadTrends();

    expect(cubit.state.trendsStatus, DashboardSectionStatus.failure);
    expect(cubit.state.months.single.incomeCents, 1000);

    // Recovery replaces the stale data.
    repository.trendsError = null;
    repository.months = [month(9, 2500)];
    await cubit.loadTrends();
    expect(cubit.state.months.single.incomeCents, 2500);
  });

  test('loadTrends switches the window between 6 and 12 months', () async {
    final repository = _FakeDashboardRepository(months: [month(8, 1000)]);
    final cubit = DashboardCubit(repository);

    await cubit.loadTrends();
    expect(cubit.state.trendMonths, 6);

    await cubit.loadTrends(months: 12);
    expect(cubit.state.trendMonths, 12);

    // Values beyond the contract cap are clamped.
    await cubit.loadTrends(months: 99);
    expect(cubit.state.trendMonths, DashboardRepository.maxTrendMonths);
  });

  test('skips a reload while the same section is already loading', () async {
    final repository = _FakeDashboardRepository(months: [month(8, 1000)]);
    final gate = Completer<void>();
    repository.trendsGate = gate;

    final cubit = DashboardCubit(repository);
    final first = cubit.loadTrends();
    // Let the first call reach its await before issuing the second one.
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.trendsStatus, DashboardSectionStatus.loading);
    await cubit.loadTrends(); // Must be a no-op while still loading.

    gate.complete();
    await first;

    expect(repository.trendsCalls, 1);
    expect(cubit.state.trendsStatus, DashboardSectionStatus.loaded);
  });
}
