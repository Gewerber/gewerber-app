import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:gewerber_app/application/accounting/accounting_cubit.dart';
import 'package:gewerber_app/application/business/business_cubit.dart';
import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/documents/documents_cubit.dart';
import 'package:gewerber_app/application/invoice_templates/invoice_template_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_cubit.dart';
import 'package:gewerber_app/application/time_tracking/projects_cubit.dart';
import 'package:gewerber_app/application/time_tracking/time_entries_cubit.dart';
import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/domain/entities/document.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/domain/repositories/document_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_accounting_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_business_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_customer_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_invoice_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_invoice_template_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_time_tracking_repository.dart';
import 'package:gewerber_app/infrastructure/services/file_picker_service.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/documents_screen.dart';
import 'package:gewerber_app/presentation/screens/home/home_shell.dart';
import 'package:gewerber_app/presentation/screens/home/invoice_create_screen.dart';
import 'package:gewerber_app/presentation/screens/home/invoicing_screen.dart';
import 'package:gewerber_app/presentation/screens/home/report_screen.dart';
import 'package:gewerber_app/presentation/screens/home/timer_screen.dart';
import 'package:gewerber_app/presentation/widgets/common/module_menu_tile.dart';
import 'package:gewerber_app/presentation/widgets/common/section_card.dart';
import 'package:gewerber_app/presentation/widgets/dashboard/month_bar_chart.dart';

/// Widget tests for the systematic accessibility pass (Etap 2).
///
/// Each test asserts one semantics guarantee added by the pass:
/// header flags on section titles, tooltips/labels on navigation
/// destinations, status text (instead of color-only chips) in the invoice
/// list, merged value+trend nodes, and text equivalents for state that was
/// previously conveyed by icon color alone.

MonthlyFinancials _month(int month, int incomeCents, int expenseCents) =>
    MonthlyFinancials(
      monthStart: DateTime(2026, month),
      incomeCents: incomeCents,
      expenseCents: expenseCents,
    );

/// Document repository whose upload never completes — freezes the view in
/// the `isUploading` state so the in-flight announcement can be asserted.
class _PendingUploadDocumentRepository implements DocumentRepository {
  final _completer = Completer<BusinessDocument>();

  @override
  Future<List<BusinessDocument>> list({
    DocumentKind? kind,
    String? relatedEntityType,
    String? relatedEntityId,
    int? limit,
    int? offset,
  }) async => const <BusinessDocument>[];

  @override
  Future<BusinessDocument?> get(int documentId) async => null;

  @override
  Future<BusinessDocument> upload({
    required int businessId,
    required PickedFileAttachment file,
    DocumentKind kind = DocumentKind.attachment,
    String? relatedEntityType,
    String? relatedEntityId,
  }) => _completer.future;

  @override
  Future<DownloadedDocument> download(BusinessDocument document) {
    throw UnimplementedError();
  }
}

class _StubPickerService implements FilePickerService {
  const _StubPickerService(this.file);

  final PickedFileAttachment file;

  @override
  Future<PickedFileAttachment?> pickSingle({
    List<String>? allowedExtensions,
  }) async => file;
}

void main() {
  setUpAll(() async {
    // Date formatting uses the German default locale (see core/utils/format).
    await initializeDateFormatting('de_DE');
  });

  testWidgets('SectionCard exposes its title as a semantics header', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SectionCard(title: 'Open invoices', child: Text('1.500,00 €')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The section title carries the header trait so screen readers can
    // jump between cards.
    final titleNode = tester.getSemantics(
      find.bySemanticsLabel(RegExp(r'^Open invoices')),
    );
    expect(titleNode.getSemanticsData().flagsCollection.isHeader, isTrue);

    semantics.dispose();
  });

  testWidgets('danger-zone tile announces its destructive context', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ListView(
            children: [
              ModuleMenuTile(
                icon: Icons.folder_outlined,
                title: 'Documents',
                onTap: () {},
              ),
              ModuleMenuTile(
                icon: Icons.delete_forever_outlined,
                title: 'Delete account',
                onTap: () {},
                destructive: true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The destructive entry reads as "Delete account, Danger zone".
    expect(
      find.bySemanticsLabel('Delete account, Danger zone'),
      findsOneWidget,
    );
    // Regular entries stay plain.
    expect(find.bySemanticsLabel(RegExp(r'Documents.*Danger')), findsNothing);

    semantics.dispose();
  });

  testWidgets('month chart semantics are descriptive: months and amounts', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MonthBarChart(
            months: [_month(4, 150000, 60000), _month(5, 120000, 30000)],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The summary names each plotted month and both series with values.
    final node = tester.getSemantics(
      find.bySemanticsLabel(RegExp(r'^Apr', dotAll: true)),
    );
    expect(node.label, contains('Income 1.500,00'));
    expect(node.label, contains('Expenses 600,00'));
    expect(node.label, contains('May'));

    semantics.dispose();
  });

  testWidgets('invoice list tile exposes its status to screen readers', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    final semantics = tester.ensureSemantics();

    final invoiceRepository = MockInvoiceRepository();
    final draft = await invoiceRepository.create(
      items: const [
        InvoiceItem(description: 'Beratung', unitPriceCents: 100000),
      ],
    );
    final sent = await invoiceRepository.create(
      items: const [
        InvoiceItem(description: 'Wartung', unitPriceCents: 200000),
      ],
    );
    await invoiceRepository.markSent(sent.id);

    final router = GoRouter(
      initialLocation: '/invoices',
      routes: [
        GoRoute(
          path: '/invoices',
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider<InvoiceCubit>.value(
                value: InvoiceCubit(invoiceRepository),
              ),
              BlocProvider<CustomerCubit>.value(
                value: CustomerCubit(MockCustomerRepository()),
              ),
            ],
            child: const InvoicingScreen(),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    // Status is part of the tile's accessible label, not only the chip.
    expect(
      find.bySemanticsLabel(RegExp('${draft.number}.*Draft', dotAll: true)),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('${sent.number}.*Sent', dotAll: true)),
      findsOneWidget,
    );

    semantics.dispose();
  });

  testWidgets('bottom navigation destinations expose tooltips', (tester) async {
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;

    final router = _shellRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    for (final label in const [
      'Dashboard',
      'Invoicing',
      'Time',
      'Accounting',
      'Settings',
    ]) {
      expect(find.byTooltip(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('rail destinations keep their visible text labels', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1.0;

    final router = _shellRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    for (final label in const [
      'Dashboard',
      'Invoicing',
      'Time',
      'Accounting',
      'Settings',
    ]) {
      expect(
        find.descendant(
          of: find.byType(NavigationRail),
          matching: find.text(label),
        ),
        findsOneWidget,
        reason: label,
      );
    }
  });

  testWidgets('timer entries announce their billable state as text', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    final repository = MockTimeTrackingRepository();
    final now = DateTime.now();
    await repository.createEntry(
      startedAt: now.subtract(const Duration(hours: 1)),
      durationMinutes: 60,
      description: 'Consulting',
      billable: true,
    );
    await repository.createEntry(
      startedAt: now.subtract(const Duration(hours: 2)),
      durationMinutes: 30,
      description: 'Admin',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<TimeEntriesCubit>.value(
              value: TimeEntriesCubit(repository),
            ),
            BlocProvider<ProjectsCubit>.value(value: ProjectsCubit(repository)),
          ],
          child: const TimerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Billable'), findsWidgets); // visible switch label
    // Each entry row reads with its billable state first ("Billable,
    // Consulting …" / "Not billable, Admin …") instead of color-only icons.
    expect(
      find.bySemanticsLabel(RegExp(r'^Billable\b.*Consulting', dotAll: true)),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'^Not billable\b.*Admin', dotAll: true)),
      findsOneWidget,
    );

    semantics.dispose();
  });

  testWidgets('report summary cards merge label and value into one node', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    final repository = MockAccountingRepository();
    final now = DateTime.now();
    await repository.create(
      type: TransactionType.income,
      category: TransactionCategory.salesRevenue,
      occurredAt: now,
      amountCents: 150000,
      description: 'Project A',
    );
    await repository.create(
      type: TransactionType.expense,
      category: TransactionCategory.office,
      occurredAt: now,
      amountCents: 40000,
      description: 'Rent',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<AccountingCubit>.value(
          value: AccountingCubit(repository),
          child: const ReportScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp(r'^Income\s[\d.,]+')), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Expenses\s[\d.,]+')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'^Profit\s-?[\d.,]+')),
      findsOneWidget,
    );

    semantics.dispose();
  });

  testWidgets('removing an item is distinguishable from deleting the invoice', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;

    final router = GoRouter(
      initialLocation: '/create',
      routes: [
        GoRoute(
          path: '/create',
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider<BusinessCubit>.value(
                value: BusinessCubit(MockBusinessRepository()),
              ),
              BlocProvider<CustomerCubit>.value(
                value: CustomerCubit(MockCustomerRepository()),
              ),
              BlocProvider<InvoiceCubit>.value(
                value: InvoiceCubit(MockInvoiceRepository()),
              ),
              BlocProvider<InvoiceTemplateCubit>.value(
                value: InvoiceTemplateCubit(MockInvoiceTemplateRepository()),
              ),
            ],
            child: const InvoiceCreateScreen(),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();

    // The line-item action no longer borrows the "Delete invoice" label.
    expect(find.byTooltip('Remove item'), findsOneWidget);
    expect(find.byTooltip('Delete invoice'), findsNothing);
  });

  testWidgets('document upload announces its in-flight state as text', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    final semantics = tester.ensureSemantics();

    final businessCubit = BusinessCubit(MockBusinessRepository());
    addTearDown(businessCubit.close);
    await businessCubit.create(name: 'Demo GmbH');

    final documentsCubit = DocumentsCubit(
      _PendingUploadDocumentRepository(),
      const _StubPickerService(
        PickedFileAttachment(fileName: 'receipt.pdf', bytes: [1, 2, 3]),
      ),
    );
    addTearDown(documentsCubit.close);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<DocumentsCubit>.value(value: documentsCubit),
            BlocProvider<BusinessCubit>.value(value: businessCubit),
          ],
          child: const Scaffold(body: SafeArea(child: DocumentsView())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Upload file'));
    await tester.pump();

    // Visible progress text while the upload is in flight.
    expect(find.text('Uploading…'), findsOneWidget);
    // The button is disabled while uploading.
    expect(
      tester
          .widget<FilledButton>(
            find.ancestor(
              of: find.text('Upload file'),
              matching: find.byType(FilledButton),
            ),
          )
          .enabled,
      isFalse,
    );

    semantics.dispose();
  });
}

/// Minimal authenticated shell with five branches for the navigation tests.
GoRouter _shellRouter() {
  Widget branch(_, _) => const Scaffold(body: SizedBox.shrink());
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(navigationShell: shell),
        branches: [
          for (final path in [
            '/dashboard',
            '/invoicing',
            '/time',
            '/accounting',
            '/settings',
          ])
            StatefulShellBranch(
              routes: [GoRoute(path: path, builder: branch)],
            ),
        ],
      ),
    ],
  );
}
