import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:gewerber_app/application/business/business_cubit.dart';
import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/invoice_templates/invoice_template_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_cubit.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_business_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_customer_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_invoice_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_invoice_template_repository.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/invoice_create_screen.dart';

/// Repository whose create always reports the free-tier quota as exhausted.
class _QuotaLimitedRepository extends MockInvoiceRepository {
  @override
  Future<Invoice> create({
    required List<InvoiceItem> items,
    int? customerId,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? serviceDateFrom,
    DateTime? serviceDateTo,
    String? notes,
    int? templateId,
  }) async {
    throw const InvoiceLimitReachedException(limit: 3);
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('de_DE');
  });

  Future<void> pumpCreateScreen(
    WidgetTester tester, {
    required bool withPlansRoute,
  }) async {
    tester.view.physicalSize = const Size(900, 1700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/create',
      routes: [
        GoRoute(
          path: '/create',
          builder: (context, state) => const InvoiceCreateScreen(),
        ),
        if (withPlansRoute)
          GoRoute(
            path: '/subscription/plans',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Plans screen'))),
          ),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<BusinessCubit>.value(
            value: BusinessCubit(MockBusinessRepository()),
          ),
          BlocProvider<CustomerCubit>.value(
            value: CustomerCubit(MockCustomerRepository())..load(),
          ),
          BlocProvider<InvoiceCubit>.value(
            value: InvoiceCubit(_QuotaLimitedRepository()),
          ),
          BlocProvider<InvoiceTemplateCubit>.value(
            value: InvoiceTemplateCubit(MockInvoiceTemplateRepository()),
          ),
        ],
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> fillAndSave(WidgetTester tester) async {
    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Beratung');

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('quota error opens a dialog with the localized limit message', (
    tester,
  ) async {
    await pumpCreateScreen(tester, withPlansRoute: false);
    await fillAndSave(tester);

    expect(
      find.textContaining("free plan's monthly limit (3 invoices)"),
      findsOneWidget,
    );
  });

  testWidgets('upgrade action is hidden when the plans route is absent', (
    tester,
  ) async {
    await pumpCreateScreen(tester, withPlansRoute: false);
    await fillAndSave(tester);

    expect(find.text('View plans'), findsNothing);
  });

  testWidgets('upgrade action navigates to the plans route when present', (
    tester,
  ) async {
    await pumpCreateScreen(tester, withPlansRoute: true);
    await fillAndSave(tester);

    expect(find.text('View plans'), findsOneWidget);
    await tester.tap(find.text('View plans'));
    await tester.pumpAndSettle();

    expect(find.text('Plans screen'), findsOneWidget);
  });
}
