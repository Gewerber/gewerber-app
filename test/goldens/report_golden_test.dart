import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/domain/repositories/accounting_repository.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/report_screen.dart';

import 'golden_test_helper.dart';

/// Golden tests for the accounting report screen (P&L, "this month" preset).
///
/// Determinism: the report renders amounts, category names and counts only —
/// no dates. The fixture transactions are placed at noon of the **first day
/// of the current calendar month**, which is inside the "this month" window
/// on every possible run date (window end is "today 23:59", and the first
/// day has passed by noon at the latest). The rendered numbers therefore do
/// not depend on when the goldens are generated.
void main() {
  setUpAll(() async {
    configureDependencies();
    configureGoldenEnvironment();
    await _seedFixtures();
  });

  testWidgets('report — phone layout', (tester) async {
    await pumpAuthenticatedApp(tester, size: goldenPhoneSize);

    appRouter.go(RouteNames.accountingReport);
    await tester.pumpAndSettle();

    expect(find.byType(ReportScreen), findsOneWidget);
    await expectLater(
      find.byType(GewerberApp),
      matchesGoldenFile('report_phone_390x844.png'),
    );
  });

  testWidgets('report — wide layout', (tester) async {
    await pumpAuthenticatedApp(tester, size: goldenWideSize);

    appRouter.go(RouteNames.accountingReport);
    await tester.pumpAndSettle();

    expect(find.byType(ReportScreen), findsOneWidget);
    await expectLater(
      find.byType(GewerberApp),
      matchesGoldenFile('report_wide_900x1280.png'),
    );
  });
}

DateTime _firstDayOfCurrentMonthAtNoon() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1, 12);
}

Future<void> _seedFixtures() async {
  final accounting = getIt<AccountingRepository>();
  final occurredAt = _firstDayOfCurrentMonthAtNoon();

  await accounting.create(
    type: TransactionType.income,
    category: TransactionCategory.salesRevenue,
    occurredAt: occurredAt,
    amountCents: 185000,
    description: 'Zahlung Müller GmbH',
  );
  await accounting.create(
    type: TransactionType.income,
    category: TransactionCategory.serviceRevenue,
    occurredAt: occurredAt,
    amountCents: 64200,
    description: 'Workshop Buchhaltung',
  );
  await accounting.create(
    type: TransactionType.expense,
    category: TransactionCategory.rent,
    occurredAt: occurredAt,
    amountCents: 85000,
    description: 'Coworking Miete',
  );
  await accounting.create(
    type: TransactionType.expense,
    category: TransactionCategory.office,
    occurredAt: occurredAt,
    amountCents: 4200,
    description: 'Büromaterial',
  );
}
