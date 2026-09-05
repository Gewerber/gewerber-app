import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:gewerber_app/application/business/business_cubit.dart';
import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/invoice_templates/invoice_template_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_cubit.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/repositories/invoice_template_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_business_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_customer_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_invoice_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_invoice_template_repository.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/invoice_create_screen.dart';

void main() {
  setUpAll(() async {
    // Date formatting uses the German default locale (see core/utils/format).
    await initializeDateFormatting('de_DE');
  });

  Future<InvoiceCubit> pumpCreateScreen(
    WidgetTester tester, {
    required InvoiceTemplateRepository templateRepository,
    required MockInvoiceRepository invoiceRepository,
    Invoice? invoice,
    MockCustomerRepository? customerRepository,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final invoiceCubit = InvoiceCubit(invoiceRepository);
    final customers = customerRepository ?? MockCustomerRepository();
    final customerCubit = CustomerCubit(customers)..load();
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Scaffold()),
        GoRoute(
          path: '/create',
          builder: (context, state) => const InvoiceCreateScreen(),
        ),
        GoRoute(
          path: '/edit',
          builder: (context, state) => InvoiceCreateScreen(invoice: invoice),
        ),
      ],
    );
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<BusinessCubit>.value(
            value: BusinessCubit(MockBusinessRepository()),
          ),
          BlocProvider<CustomerCubit>.value(value: customerCubit),
          BlocProvider<InvoiceCubit>.value(value: invoiceCubit),
          BlocProvider<InvoiceTemplateCubit>.value(
            value: InvoiceTemplateCubit(templateRepository),
          ),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    // Push the screen so saving can pop back.
    router.push(invoice == null ? '/create' : '/edit');
    await tester.pumpAndSettle();
    return invoiceCubit;
  }

  Future<void> fillAndSave(WidgetTester tester) async {
    await tester.tap(find.text('No customer'));
    await tester.pumpAndSettle();
    // Close the dropdown without changing the selection.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Beratung');

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('new invoices carry the default template id', (tester) async {
    final templateRepository = MockInvoiceTemplateRepository();
    await templateRepository.create(name: 'Standard');
    await templateRepository.create(name: 'Letterhead', isDefault: true);
    final invoiceRepository = MockInvoiceRepository();

    final invoiceCubit = await pumpCreateScreen(
      tester,
      templateRepository: templateRepository,
      invoiceRepository: invoiceRepository,
    );
    await fillAndSave(tester);

    expect(invoiceCubit.state.invoices.single.templateId, 2);
  });

  testWidgets('new-invoice form announces the applied default template', (
    tester,
  ) async {
    final templateRepository = MockInvoiceTemplateRepository();
    await templateRepository.create(name: 'Letterhead', isDefault: true);
    final invoiceRepository = MockInvoiceRepository();

    await pumpCreateScreen(
      tester,
      templateRepository: templateRepository,
      invoiceRepository: invoiceRepository,
    );

    // Unobtrusive indicator once the default template resolved.
    expect(find.textContaining('Applying template'), findsOneWidget);
    expect(find.textContaining('Letterhead'), findsOneWidget);
  });

  testWidgets('no indicator without a default template', (tester) async {
    final templateRepository = MockInvoiceTemplateRepository();
    await templateRepository.create(name: 'Standard');

    await pumpCreateScreen(
      tester,
      templateRepository: templateRepository,
      invoiceRepository: MockInvoiceRepository(),
    );

    expect(find.textContaining('Applying template'), findsNothing);
  });

  testWidgets('creating without a default template leaves the id empty', (
    tester,
  ) async {
    final invoiceCubit = await pumpCreateScreen(
      tester,
      templateRepository: MockInvoiceTemplateRepository(),
      invoiceRepository: MockInvoiceRepository(),
    );
    await fillAndSave(tester);

    expect(invoiceCubit.state.invoices.single.templateId, isNull);
  });

  testWidgets('editing never applies the default template prefill', (
    tester,
  ) async {
    final templateRepository = MockInvoiceTemplateRepository();
    // A default template exists, but edits must not touch the association.
    await templateRepository.create(name: 'Letterhead', isDefault: true);
    final invoiceRepository = MockInvoiceRepository();
    final draft = await invoiceRepository.create(items: const []);

    final invoiceCubit = await pumpCreateScreen(
      tester,
      templateRepository: templateRepository,
      invoiceRepository: invoiceRepository,
      invoice: draft,
    );
    await fillAndSave(tester);

    // The stored draft keeps its (empty) template association — the
    // default template was NOT applied in edit mode.
    final result = await invoiceRepository.get(draft.id);
    expect(result.invoice.templateId, isNull);
    expect(invoiceCubit.state.invoices, isEmpty);
  });

  testWidgets('reverse-charge chip appears for customers with a VAT ID', (
    tester,
  ) async {
    final customerRepository = MockCustomerRepository();
    await customerRepository.create(name: 'ACME GmbH', vatId: 'DE123456789');
    await customerRepository.create(name: 'Private Client');

    await pumpCreateScreen(
      tester,
      templateRepository: MockInvoiceTemplateRepository(),
      invoiceRepository: MockInvoiceRepository(),
      customerRepository: customerRepository,
    );

    // Hidden while no customer is selected.
    expect(find.byIcon(Icons.swap_horiz_outlined), findsNothing);

    // Select the customer carrying a USt-IdNr. — the chip appears.
    await tester.tap(find.text('No customer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ACME GmbH').last);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.swap_horiz_outlined), findsOneWidget);

    // Choosing a customer without a VAT ID hides it again.
    await tester.tap(find.text('ACME GmbH').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Private Client').last);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.swap_horiz_outlined), findsNothing);
  });
}
