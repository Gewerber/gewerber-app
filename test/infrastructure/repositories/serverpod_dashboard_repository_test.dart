import 'package:flutter_test/flutter_test.dart';
import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;

import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/repositories/dashboard_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/dashboard_remote_data_source.dart';
import 'package:gewerber_app/infrastructure/mappers/dashboard_mapper.dart';
import 'package:gewerber_app/infrastructure/mappers/invoice_mapper.dart';
import 'package:gewerber_app/infrastructure/mappers/transaction_mapper.dart';
import 'package:gewerber_app/infrastructure/repositories/serverpod_dashboard_repository.dart';

/// Hand-written fake of the transport layer: records the request parameters
/// and answers with either a canned summary or a thrown error.
class _FakeRemoteDataSource implements DashboardRemoteDataSource {
  _FakeRemoteDataSource({this.result});

  sdk.DashboardSummary? result;
  Object? error;

  final List<({int? trendMonths, int? recentLimit})> calls = [];

  @override
  Future<sdk.DashboardSummary> getSummary({
    int? trendMonths,
    int? recentLimit,
    int? overdueLimit,
    int? debtorLimit,
  }) async {
    calls.add((trendMonths: trendMonths, recentLimit: recentLimit));
    if (error != null) throw error!;
    return result!;
  }
}

sdk.DashboardSummary _summary() => sdk.DashboardSummary(
  generatedAt: DateTime.utc(2026, 8, 24, 9),
  asOf: DateTime.utc(2026, 8, 24, 9),
  trendFrom: DateTime.utc(2026, 8, 1),
  trendTo: DateTime.utc(2026, 8, 31),
  kpis: sdk.DashboardKpis(
    periodFrom: DateTime.utc(2026, 8, 1),
    periodTo: DateTime.utc(2026, 8, 31),
    incomeCents: 0,
    expenseCents: 0,
    profitCents: 0,
    totalMinutes: 0,
    billableMinutes: 0,
    roundedMinutes: 0,
  ),
  monthlyTrend: [
    sdk.MonthlyTrendPoint(
      monthStart: DateTime.utc(2026, 8, 1),
      incomeCents: 250000,
      expenseCents: 100000,
      profitCents: 150000,
    ),
  ],
  recentInvoices: [],
  recentTransactions: [],
  recentTimeEntries: [],
  receivables: sdk.ReceivablesSummary(
    openInvoicesCount: 1,
    openTotalCents: 90000,
    overdueCount: 0,
    overdueTotalCents: 0,
    debtors: [
      sdk.DebtorSummary(
        customerId: null,
        customerName: null,
        openCount: 1,
        openTotalCents: 90000,
        overdueTotalCents: 0,
      ),
    ],
    overdueInvoices: [],
  ),
);

void main() {
  late _FakeRemoteDataSource remote;
  late ServerpodDashboardRepository repository;

  setUp(() {
    remote = _FakeRemoteDataSource(result: _summary());
    repository = ServerpodDashboardRepository(
      remote,
      const DashboardMapper(InvoiceMapper(), TransactionMapper()),
    );
  });

  group('success path', () {
    test('monthlyFinancials clamps the window and maps the trend', () async {
      final months = await repository.monthlyFinancials(months: 99);

      expect(
        remote.calls.single.trendMonths,
        DashboardRepository.maxTrendMonths,
      );
      expect(months.single.incomeCents, 250000);
      expect(months.single.profitCents, 150000);
    });

    test('recentActivity forwards the feed limit', () async {
      await repository.recentActivity(limit: 5);

      expect(remote.calls.single.recentLimit, 5);
    });

    test('receivables maps debtors including unknown customers', () async {
      final receivables = await repository.receivables();

      expect(receivables.outstandingTotalCents, 90000);
      final anonymous = receivables.debtors.single;
      expect(anonymous.customerId, isNull);
      expect(anonymous.displayName, isNull);
    });

    test('summary assembles all sections from one round trip', () async {
      final summary = await repository.summary(months: 6);

      expect(remote.calls.single.trendMonths, 6);
      expect(summary.months.single.incomeCents, 250000);
      expect(summary.activity, isEmpty);
      expect(summary.receivables.debtors.single.displayName, isNull);
      expect(summary.generatedAt, DateTime.utc(2026, 8, 24, 9));
    });
  });

  group('failure path', () {
    test('propagates the NetworkException raised by the data source', () async {
      remote
        ..result = null
        ..error = const NetworkException();

      // Transport errors reach callers as AppExceptions so the cubit maps
      // them to failures per section.
      await expectLater(
        repository.receivables(),
        throwsA(isA<NetworkException>()),
      );
      await expectLater(
        repository.monthlyFinancials(months: 6),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
