import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/dashboard/dashboard_cubit.dart';
import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_cubit.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/domain/repositories/dashboard_repository.dart';
import 'package:gewerber_app/domain/repositories/invoice_repository.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/invoice_detail_screen.dart';
import 'package:gewerber_app/presentation/widgets/dashboard/month_bar_chart.dart';
import 'package:gewerber_app/presentation/widgets/dashboard/receivables_card.dart';
import 'package:gewerber_app/presentation/widgets/dashboard/recent_activity_card.dart';
import 'package:gewerber_app/presentation/widgets/dashboard/trends_section_card.dart';

/// Widget tests for the dashboard v2 section cards.
///
/// The sections are public widgets driven by the [DashboardCubit] state, so
/// every test pumps a real cubit on top of a hand-written repository fake
/// (no mockito) and exercises the loaded / empty / failure rendering plus
/// the overdue-invoice navigation.

/// Hand-written [DashboardRepository] fake with canned responses and
/// per-section error switches.
class _FakeDashboardRepository implements DashboardRepository {
  List<MonthlyFinancials> months = const [];
  List<RecentActivityItem> activity = const [];
  ReceivablesSummary receivablesValue = const ReceivablesSummary(
    outstandingTotalCents: 0,
    debtors: [],
    overdueInvoices: [],
  );

  Exception? trendsError;
  Exception? activityError;
  Exception? receivablesError;

  int trendsCalls = 0;
  int activityCalls = 0;
  int receivablesCalls = 0;

  /// Window size of the most recent trend request.
  int lastRequestedMonths = 0;

  @override
  Future<List<MonthlyFinancials>> monthlyFinancials({
    required int months,
    DateTime? anchor,
  }) async {
    trendsCalls++;
    lastRequestedMonths = months;
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

MonthlyFinancials _month(int month, int incomeCents, int expenseCents) =>
    MonthlyFinancials(
      monthStart: DateTime(2026, month),
      incomeCents: incomeCents,
      expenseCents: expenseCents,
    );

/// Three months with a rising profit; the newest month is +71 % over the
/// previous one.
List<MonthlyFinancials> _trendMonths() => [
  _month(4, 100000, 60000),
  _month(5, 120000, 50000),
  _month(6, 150000, 30000),
];

Invoice _overdueInvoice({int id = 41}) => Invoice(
  id: id,
  number: 'RE-2026-041',
  status: InvoiceStatus.overdue,
  issueDate: DateTime(2026, 7, 2),
  dueDate: DateTime(2026, 8, 1),
  totalCents: 250000,
);

ReceivablesSummary _receivables() => ReceivablesSummary(
  outstandingTotalCents: 320000,
  debtors: [
    DebtorLine(
      customerId: 1,
      displayName: 'Alpha GmbH',
      outstandingCents: 200000,
      invoiceCount: 2,
    ),
    DebtorLine(
      customerId: null,
      displayName: '',
      outstandingCents: 80000,
      invoiceCount: 1,
    ),
    DebtorLine(
      customerId: 3,
      displayName: 'Beta AG',
      outstandingCents: 40000,
      invoiceCount: 1,
    ),
    DebtorLine(
      customerId: 4,
      displayName: 'Gamma OHG',
      outstandingCents: 10000,
      invoiceCount: 3,
    ),
  ],
  overdueInvoices: [_overdueInvoice()],
);

List<RecentActivityItem> _activity() => [
  InvoiceActivity(
    invoice: Invoice(
      id: 39,
      number: 'RE-2026-039',
      status: InvoiceStatus.sent,
      issueDate: DateTime(2026, 8, 20),
      totalCents: 90000,
    ),
    at: DateTime(2026, 8, 20),
  ),
  TimeActivity(minutes: 125, project: 'Website', at: DateTime(2026, 8, 19)),
  TransactionActivity(
    transaction: AccountingTransaction(
      id: 7,
      type: TransactionType.income,
      category: TransactionCategory.salesRevenue,
      occurredAt: DateTime(2026, 8, 18),
      amountCents: 15000,
      description: 'Stripe payout',
    ),
  ),
];

void main() {
  setUpAll(configureDependencies);

  /// Loads all sections once and pumps [section] inside a localized
  /// MaterialApp wired to a cubit over [fake].
  Future<void> pumpSection(
    WidgetTester tester, {
    required _FakeDashboardRepository fake,
    required Widget section,
  }) async {
    final cubit = DashboardCubit(fake);
    addTearDown(cubit.close);
    await cubit.loadAll();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: BlocProvider<DashboardCubit>.value(
              value: cubit,
              child: section,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('TrendsSectionCard', () {
    testWidgets('renders chart, legend and change line when loaded', (
      tester,
    ) async {
      final fake = _FakeDashboardRepository()..months = _trendMonths();
      await pumpSection(tester, fake: fake, section: const TrendsSectionCard());

      expect(find.text('Last 6 months'), findsOneWidget);
      expect(find.byType(MonthBarChart), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      // Newest month's profit vs. the previous one (+71 %).
      expect(find.textContaining('+71%'), findsOneWidget);
      // The window switcher offers the twelve-month view.
      expect(find.text('12M'), findsOneWidget);
    });

    testWidgets('switching to 12M reloads with the wider window', (
      tester,
    ) async {
      final fake = _FakeDashboardRepository()..months = _trendMonths();
      await pumpSection(tester, fake: fake, section: const TrendsSectionCard());
      expect(fake.lastRequestedMonths, 6);

      await tester.tap(find.text('12M'));
      await tester.pumpAndSettle();

      expect(fake.trendsCalls, 2);
      expect(fake.lastRequestedMonths, 12);
      expect(find.text('Last 12 months'), findsOneWidget);
    });

    testWidgets('shows the empty state when no data was recorded', (
      tester,
    ) async {
      await pumpSection(
        tester,
        fake: _FakeDashboardRepository(),
        section: const TrendsSectionCard(),
      );

      expect(find.byType(MonthBarChart), findsNothing);
      expect(find.text('No income or expenses recorded yet.'), findsOneWidget);
    });

    testWidgets('retry re-runs only the failed trends section', (tester) async {
      final fake = _FakeDashboardRepository()
        ..trendsError = const NetworkException();
      await pumpSection(tester, fake: fake, section: const TrendsSectionCard());

      expect(find.text("Some data couldn't be loaded."), findsOneWidget);
      expect(find.text('Last 6 months'), findsOneWidget);

      fake.trendsError = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(fake.trendsCalls, 2);
      // The initial loadAll already counted one call per other section.
      expect(fake.activityCalls, 1);
      expect(fake.receivablesCalls, 1);
      expect(find.text('Last 6 months'), findsOneWidget);
    });
  });

  group('RecentActivityCard', () {
    testWidgets('renders invoice, time and transaction entries', (
      tester,
    ) async {
      final fake = _FakeDashboardRepository()..activity = _activity();
      await pumpSection(
        tester,
        fake: fake,
        section: const RecentActivityCard(),
      );

      expect(find.text('Recent activity'), findsOneWidget);
      expect(find.text('Invoice RE-2026-039 created'), findsOneWidget);
      expect(find.text('2h 05m tracked'), findsOneWidget);
      expect(find.text('Website'), findsOneWidget);
      expect(find.text('Transaction booked'), findsOneWidget);
      expect(find.textContaining('+150,00'), findsOneWidget);
    });

    testWidgets('shows the empty state without events', (tester) async {
      await pumpSection(
        tester,
        fake: _FakeDashboardRepository(),
        section: const RecentActivityCard(),
      );

      expect(find.text('Nothing going on yet.'), findsOneWidget);
    });

    testWidgets('retry re-runs only the failed activity section', (
      tester,
    ) async {
      final fake = _FakeDashboardRepository()
        ..activityError = const NetworkException();
      await pumpSection(
        tester,
        fake: fake,
        section: const RecentActivityCard(),
      );

      expect(find.text("Some data couldn't be loaded."), findsOneWidget);

      fake.activityError = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(fake.activityCalls, 2);
      expect(fake.trendsCalls, 1);
      expect(fake.receivablesCalls, 1);
      expect(find.text('Nothing going on yet.'), findsOneWidget);
    });
  });

  group('ReceivablesCard', () {
    testWidgets('renders total, top debtors and the overdue row when loaded', (
      tester,
    ) async {
      final fake = _FakeDashboardRepository()
        ..receivablesValue = _receivables();
      await pumpSection(tester, fake: fake, section: const ReceivablesCard());

      expect(find.text('Receivables'), findsOneWidget);
      expect(find.textContaining('3.200,00'), findsOneWidget);
      expect(find.text('Alpha GmbH'), findsOneWidget);
      expect(find.text('2 invoices'), findsOneWidget);
      // Only the "no customer" bucket renders the localized fallback name.
      expect(find.text('No customer'), findsOneWidget);
      // A fourth debtor exists but only three are shown, hence the hint.
      expect(find.text('Gamma OHG'), findsNothing);
      expect(find.text('View all'), findsOneWidget);
      // Overdue block: title, number, amount, due date and badge.
      expect(find.text('Overdue'), findsNWidgets(2)); // section + badge
      expect(find.text('RE-2026-041'), findsOneWidget);
      expect(find.textContaining('2.500,00'), findsOneWidget);
      expect(find.textContaining('Due'), findsOneWidget);
      expect(find.text('Nothing overdue.'), findsNothing);
    });

    testWidgets('tapping an overdue row pushes the invoice detail screen', (
      tester,
    ) async {
      // The detail screen resolves the invoice against the mock invoicing
      // store, so seed it with a matching record first.
      final invoiceRepo = getIt<InvoiceRepository>();
      var seeded = await invoiceRepo.create(
        items: const [
          InvoiceItem(description: 'Beratung', unitPriceCents: 250000),
        ],
      );
      seeded = await invoiceRepo.markSent(seeded.id);
      addTearDown(() => invoiceRepo.delete(seeded.id));

      final extraInvoice = Invoice(
        id: seeded.id,
        number: 'RE-2026-041',
        status: InvoiceStatus.overdue,
        issueDate: DateTime(2026, 7, 2),
        dueDate: DateTime(2026, 8, 1),
        totalCents: 250000,
      );

      final fake = _FakeDashboardRepository()
        ..receivablesValue = ReceivablesSummary(
          outstandingTotalCents: 250000,
          // Real data always groups every open invoice under a customer
          // bucket (possibly the "no customer" one), so include one debtor.
          debtors: const [
            DebtorLine(
              customerId: null,
              displayName: '',
              outstandingCents: 250000,
              invoiceCount: 1,
            ),
          ],
          overdueInvoices: [extraInvoice],
        );

      final cubit = DashboardCubit(fake);
      addTearDown(cubit.close);
      await cubit.loadAll();

      final router = GoRouter(
        initialLocation: '/test-dashboard',
        routes: [
          GoRoute(
            path: '/test-dashboard',
            builder: (_, _) => BlocProvider<DashboardCubit>.value(
              value: cubit,
              child: const Scaffold(
                body: SingleChildScrollView(child: ReceivablesCard()),
              ),
            ),
          ),
          GoRoute(
            path: RouteNames.invoiceDetail,
            builder: (_, state) => MultiBlocProvider(
              providers: [
                BlocProvider<InvoiceCubit>.value(value: getIt<InvoiceCubit>()),
                BlocProvider<CustomerCubit>.value(
                  value: getIt<CustomerCubit>(),
                ),
              ],
              child: InvoiceDetailScreen(invoice: state.extra! as Invoice),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('RE-2026-041'));
      await tester.pumpAndSettle();

      expect(find.byType(InvoiceDetailScreen), findsOneWidget);
    });

    testWidgets('shows the empty state when nobody owes anything', (
      tester,
    ) async {
      await pumpSection(
        tester,
        fake: _FakeDashboardRepository(),
        section: const ReceivablesCard(),
      );

      expect(find.text('No open invoices. All settled!'), findsOneWidget);
      expect(find.text('Overdue'), findsNothing);
    });

    testWidgets('retry re-runs only the failed receivables section', (
      tester,
    ) async {
      final fake = _FakeDashboardRepository()
        ..receivablesError = const NetworkException();
      await pumpSection(tester, fake: fake, section: const ReceivablesCard());

      expect(find.text("Some data couldn't be loaded."), findsOneWidget);

      fake.receivablesError = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(fake.receivablesCalls, 2);
      expect(fake.trendsCalls, 1);
      expect(fake.activityCalls, 1);
      expect(find.text('No open invoices. All settled!'), findsOneWidget);
    });
  });

  group('MonthBarChart', () {
    testWidgets('renders bars, stays hit-testable and exposes semantics', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: MonthBarChart(months: _trendMonths())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MonthBarChart), findsOneWidget);

      // Hit-testing the plot area must not throw; target the painter's
      // CustomPaint because the wrapping Column itself is not a hit target.
      final plot = find.descendant(
        of: find.byType(MonthBarChart),
        matching: find.byType(CustomPaint),
      );
      expect(plot, findsOneWidget);
      await tester.tap(plot.first);
      expect(tester.takeException(), isNull);

      // The textual summary for screen readers covers every plotted month.
      expect(
        find.bySemanticsLabel(RegExp(r'^Apr:.*Jun:', dotAll: true)),
        findsOneWidget,
      );

      semantics.dispose();
    });
  });
}
