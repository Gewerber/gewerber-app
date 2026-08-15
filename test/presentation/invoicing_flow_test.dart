import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/customer_edit_screen.dart';
import 'package:gewerber_app/presentation/screens/home/customers_screen.dart';
import 'package:gewerber_app/presentation/screens/home/dashboard_screen.dart';
import 'package:gewerber_app/presentation/screens/home/invoice_create_screen.dart';
import 'package:gewerber_app/presentation/screens/home/invoice_detail_screen.dart';
import 'package:gewerber_app/presentation/screens/home/invoicing_screen.dart';
import 'package:gewerber_app/presentation/screens/onboarding/onboarding_screen.dart';

void main() {
  setUpAll(configureDependencies);

  testWidgets('create a customer and an invoice from the shell', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    appRouter.go(RouteNames.splash);
    await tester.pumpWidget(const GewerberApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Explore the demo'));
    await tester.pumpAndSettle();

    if (find.byType(OnboardingScreen).evaluate().isNotEmpty) {
      await tester.enterText(find.byType(TextFormField), 'Demo GmbH');
      await tester.tap(find.text('Create business'));
      await tester.pumpAndSettle();
    }
    expect(find.byType(DashboardScreen), findsOneWidget);

    // Invoicing -> customers.
    await tester.tap(find.text('Invoicing'));
    await tester.pumpAndSettle();
    expect(find.byType(InvoicingScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.people_outline));
    await tester.pumpAndSettle();
    expect(find.byType(CustomersScreen), findsOneWidget);

    // Create a customer.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(CustomerEditScreen), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Anna Muster');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(CustomersScreen), findsOneWidget);
    expect(find.text('Anna Muster'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Back to invoicing and create an invoice for the customer.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(InvoicingScreen), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(InvoiceCreateScreen), findsOneWidget);

    // The freshly created customer is selectable.
    await tester.tap(find.text('No customer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Anna Muster').last);
    await tester.pumpAndSettle();

    // Add an item and save.
    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Beratung');
    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Back on the invoicing list with the new invoice.
    expect(find.byType(InvoicingScreen), findsOneWidget);
    expect(find.text('RE-1'), findsOneWidget);

    // Open the invoice detail: customer, line item and draft actions.
    await tester.tap(find.text('RE-1'));
    await tester.pumpAndSettle();
    expect(find.byType(InvoiceDetailScreen), findsOneWidget);
    expect(find.text('Anna Muster'), findsOneWidget);
    expect(find.text('Beratung'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(InvoicingScreen), findsOneWidget);
  });
}
