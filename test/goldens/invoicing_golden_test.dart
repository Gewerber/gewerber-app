import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/repositories/customer_repository.dart';
import 'package:gewerber_app/domain/repositories/invoice_repository.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/invoicing_screen.dart';

import 'golden_test_helper.dart';

/// Golden tests for the invoicing list, backed by fixed invoice fixtures
/// (absolute issue dates and amounts — nothing derived from the wall clock).
void main() {
  setUpAll(() async {
    configureDependencies();
    configureGoldenEnvironment();
    await _seedFixtures();
  });

  testWidgets('invoicing list — phone layout', (tester) async {
    await pumpAuthenticatedApp(tester, size: goldenPhoneSize);

    appRouter.go(RouteNames.invoicing);
    await tester.pumpAndSettle();

    expect(find.byType(InvoicingScreen), findsOneWidget);
    await expectLater(
      find.byType(GewerberApp),
      matchesGoldenFile('invoicing_list_phone_390x844.png'),
    );
  });

  testWidgets('invoicing list — wide layout', (tester) async {
    await pumpAuthenticatedApp(tester, size: goldenWideSize);

    appRouter.go(RouteNames.invoicing);
    await tester.pumpAndSettle();

    expect(find.byType(InvoicingScreen), findsOneWidget);
    await expectLater(
      find.byType(GewerberApp),
      matchesGoldenFile('invoicing_list_wide_900x1280.png'),
    );
  });
}

Future<void> _seedFixtures() async {
  final customers = getIt<CustomerRepository>();
  final muller = await customers.create(
    name: 'Erika Muster',
    companyName: 'Müller GmbH',
    email: 'erika@mueller.example',
  );
  final schmidt = await customers.create(
    name: 'Jonas Schmidt',
    companyName: 'Schmidt & Co. KG',
    email: 'jonas@schmidt.example',
  );

  final invoices = getIt<InvoiceRepository>();

  // RE-1 · sent · Müller GmbH · 2.498,00 €
  final sent = await invoices.create(
    customerId: muller.id,
    issueDate: DateTime(2026, 7, 2),
    dueDate: DateTime(2026, 7, 16),
    items: const [
      InvoiceItem(
        description: 'Beratung Cloud-Migration',
        quantity: 4,
        unitPriceCents: 55000,
        lineTotalCents: 220000,
      ),
      InvoiceItem(
        description: 'Schulung Team',
        quantity: 1,
        unitPriceCents: 29800,
        lineTotalCents: 29800,
      ),
    ],
  );
  await invoices.update(
    _withAmounts(sent, InvoiceStatus.sent, subtotalCents: 249800),
    items: const [
      InvoiceItem(
        description: 'Beratung Cloud-Migration',
        quantity: 4,
        unitPriceCents: 55000,
        lineTotalCents: 220000,
      ),
      InvoiceItem(
        description: 'Schulung Team',
        quantity: 1,
        unitPriceCents: 29800,
        lineTotalCents: 29800,
      ),
    ],
  );

  // RE-2 · paid · Schmidt & Co. KG
  final paid = await invoices.create(
    customerId: schmidt.id,
    issueDate: DateTime(2026, 6, 18),
    dueDate: DateTime(2026, 7, 2),
    items: const [
      InvoiceItem(
        description: 'Onboarding Buchhaltung',
        quantity: 1,
        unitPriceCents: 89000,
        lineTotalCents: 89000,
      ),
    ],
  );
  final paidSent = await invoices.markSent(paid.id);
  await invoices.update(
    _withAmounts(paidSent, InvoiceStatus.paid, subtotalCents: 89000),
    items: const [
      InvoiceItem(
        description: 'Onboarding Buchhaltung',
        quantity: 1,
        unitPriceCents: 89000,
        lineTotalCents: 89000,
      ),
    ],
  );

  // RE-3 · overdue · Müller GmbH · due date in the past.
  final overdue = await invoices.create(
    customerId: muller.id,
    issueDate: DateTime(2026, 6, 30),
    dueDate: DateTime(2026, 7, 14),
    items: const [
      InvoiceItem(
        description: 'Website-Relaunch',
        quantity: 1,
        unitPriceCents: 149500,
        lineTotalCents: 149500,
      ),
    ],
  );
  final overdueSent = await invoices.markSent(overdue.id);
  await invoices.update(
    _withAmounts(overdueSent, InvoiceStatus.overdue, subtotalCents: 149500),
    items: const [
      InvoiceItem(
        description: 'Website-Relaunch',
        quantity: 1,
        unitPriceCents: 149500,
        lineTotalCents: 149500,
      ),
    ],
  );

  // RE-4 · draft · no customer yet.
  final draft = await invoices.create(
    issueDate: DateTime(2026, 8, 20),
    dueDate: DateTime(2026, 9, 3),
    items: const [
      InvoiceItem(
        description: 'Pflichtenheft (Entwurf)',
        quantity: 1,
        unitPriceCents: 50800,
        lineTotalCents: 50800,
      ),
    ],
  );
  await invoices.update(
    _withAmounts(draft, InvoiceStatus.draft, subtotalCents: 50800),
    items: const [
      InvoiceItem(
        description: 'Pflichtenheft (Entwurf)',
        quantity: 1,
        unitPriceCents: 50800,
        lineTotalCents: 50800,
      ),
    ],
  );

  // The invoice detail screen resolves the customer name from this cubit.
  // ignore: unawaited_futures
  getIt<CustomerCubit>().load();
}

/// The mock repository creates invoices without totals; rebuild the entity
/// with the fixture's exact amounts and status.
Invoice _withAmounts(
  Invoice invoice,
  InvoiceStatus status, {
  required int subtotalCents,
}) {
  return Invoice(
    id: invoice.id,
    number: invoice.number,
    status: status,
    customerId: invoice.customerId,
    issueDate: invoice.issueDate,
    dueDate: invoice.dueDate,
    serviceDateFrom: invoice.serviceDateFrom,
    serviceDateTo: invoice.serviceDateTo,
    notes: invoice.notes,
    templateId: invoice.templateId,
    subtotalCents: subtotalCents,
    vatTotalCents: 0,
    totalCents: subtotalCents,
  );
}
