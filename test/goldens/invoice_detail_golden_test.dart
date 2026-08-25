import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/repositories/customer_repository.dart';
import 'package:gewerber_app/domain/repositories/invoice_repository.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/invoice_detail_screen.dart';

import 'golden_test_helper.dart';

/// Golden tests for the invoice detail screen with a fixed fixture invoice
/// (sent status, two line items, one recorded payment with a pinned date).
void main() {
  setUpAll(() async {
    configureDependencies();
    configureGoldenEnvironment();
    await _seedFixture();
  });

  testWidgets('invoice detail — phone layout', (tester) async {
    await pumpAuthenticatedApp(tester, size: goldenPhoneSize);

    appRouter.go(RouteNames.invoiceDetail, extra: _fixtureInvoice);
    await tester.pumpAndSettle();

    expect(find.byType(InvoiceDetailScreen), findsOneWidget);
    await expectLater(
      find.byType(GewerberApp),
      matchesGoldenFile('invoice_detail_phone_390x844.png'),
    );
  });

  testWidgets('invoice detail — wide layout', (tester) async {
    await pumpAuthenticatedApp(tester, size: goldenWideSize);

    appRouter.go(RouteNames.invoiceDetail, extra: _fixtureInvoice);
    await tester.pumpAndSettle();

    expect(find.byType(InvoiceDetailScreen), findsOneWidget);
    await expectLater(
      find.byType(GewerberApp),
      matchesGoldenFile('invoice_detail_wide_900x1280.png'),
    );
  });
}

/// The fixture invoice handed to the detail route; kept as a top-level so
/// both tests deep-link with the identical entity.
Invoice? _fixtureInvoice;

Future<void> _seedFixture() async {
  final customer = await getIt<CustomerRepository>().create(
    name: 'Erika Muster',
    companyName: 'Müller GmbH',
    email: 'erika@mueller.example',
  );

  final invoices = getIt<InvoiceRepository>();
  final created = await invoices.create(
    customerId: customer.id,
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

  _fixtureInvoice = await invoices.update(
    Invoice(
      id: created.id,
      number: created.number,
      status: InvoiceStatus.sent,
      customerId: created.customerId,
      issueDate: created.issueDate,
      dueDate: created.dueDate,
      subtotalCents: 249800,
      vatTotalCents: 0,
      totalCents: 249800,
    ),
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

  // Partial payment with a pinned date so the payment card renders
  // deterministically.
  await invoices.recordPayment(
    invoiceId: created.id,
    amountCents: 100000,
    paidAt: DateTime(2026, 7, 18),
    reference: 'SEPA-2026-0718',
  );

  // The detail screen resolves the customer display name from this cubit;
  // deep-linking skips the invoicing list that normally loads it.
  await getIt<CustomerCubit>().load();
}
