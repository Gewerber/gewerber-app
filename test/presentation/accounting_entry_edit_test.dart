import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:gewerber_app/application/accounting/accounting_cubit.dart';
import 'package:gewerber_app/application/business/business_cubit.dart';
import 'package:gewerber_app/application/documents/documents_cubit.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/document.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/domain/repositories/accounting_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_accounting_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_business_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_document_repository.dart';
import 'package:gewerber_app/infrastructure/services/file_picker_service.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/accounting_entry_create_screen.dart';

class _FailingUpdateRepository implements AccountingRepository {
  @override
  Future<List<AccountingTransaction>> list({
    TransactionType? type,
    TransactionCategory? category,
    DateTime? from,
    DateTime? to,
    int? limit,
    int? offset,
  }) async => [];

  @override
  Future<AccountingTransaction> update(
    AccountingTransaction transaction,
  ) async => throw const NetworkException('offline');

  // ── Unused members ──────────────────────────────────────────────────────

  @override
  Future<AccountingTransaction> create({
    required TransactionType type,
    required TransactionCategory category,
    required DateTime occurredAt,
    required int amountCents,
    String? description,
    int? receiptDocumentId,
  }) => throw UnimplementedError();

  @override
  Future<void> delete(int transactionId) => throw UnimplementedError();

  @override
  Future<ProfitLossReport> profitLoss(DateTime from, DateTime to) =>
      throw UnimplementedError();

  @override
  Future<String> exportCsv({
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  }) => throw UnimplementedError();

  @override
  Future<AccountingTransaction> getAccountingTransaction(int transactionId) =>
      throw UnimplementedError();
}

void main() {
  setUpAll(() async {
    // Date formatting uses the German default locale (see core/utils/format).
    await initializeDateFormatting('de_DE');
  });

  Future<AccountingTransaction> pumpEditScreen(
    WidgetTester tester, {
    required MockAccountingRepository accountingRepository,
    MockDocumentRepository? documentRepository,
    AccountingRepository? overrideRepository,
    int? seedReceiptDocumentId,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final businessRepository = MockBusinessRepository();
    await businessRepository.create(name: 'Musterbetrieb');
    final businessCubit = BusinessCubit(businessRepository)..load();

    final documents = documentRepository ?? MockDocumentRepository();

    // Seed through create() so the mock assigns a valid stored entry.
    final seeded = await accountingRepository.create(
      type: TransactionType.expense,
      category: TransactionCategory.office,
      occurredAt: DateTime(2026, 8, 10),
      amountCents: 4990,
      description: 'Office chair',
      receiptDocumentId: seedReceiptDocumentId,
    );

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Scaffold()),
        GoRoute(
          path: '/edit',
          builder: (context, state) => AccountingEntryCreateScreen(
            transaction: state.extra is AccountingTransaction
                ? state.extra as AccountingTransaction
                : null,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<BusinessCubit>.value(value: businessCubit),
          BlocProvider<AccountingCubit>.value(
            value: AccountingCubit(overrideRepository ?? accountingRepository),
          ),
          BlocProvider<DocumentsCubit>.value(
            value: DocumentsCubit(documents, _NullFilePickerService()),
          ),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    router.push('/edit', extra: seeded);
    await tester.pumpAndSettle();
    return seeded;
  }

  testWidgets('opening the editor prefills the stored fields', (tester) async {
    await pumpEditScreen(
      tester,
      accountingRepository: MockAccountingRepository(),
    );

    expect(find.text('Edit entry'), findsOneWidget);
    // Amount is prefilled as plain dot-decimal text.
    expect(find.widgetWithText(TextField, '49.90'), findsOneWidget);
    expect(find.text('Office chair'), findsOneWidget);
    expect(find.text('Office'), findsOneWidget);
    expect(find.text(formatDate(DateTime(2026, 8, 10))), findsOneWidget);
  });

  testWidgets('the current receipt file name is resolved and shown', (
    tester,
  ) async {
    final documentRepository = MockDocumentRepository();
    final receipt = await documentRepository.upload(
      businessId: 1,
      file: PickedFileAttachment(fileName: 'beleg.pdf', bytes: [1, 2, 3]),
      kind: DocumentKind.receipt,
    );

    await pumpEditScreen(
      tester,
      accountingRepository: MockAccountingRepository(),
      documentRepository: documentRepository,
      seedReceiptDocumentId: receipt.id,
    );

    expect(find.text('beleg.pdf'), findsOneWidget);
    expect(receipt.kind, DocumentKind.receipt);
  });

  testWidgets('saving persists the edits via accounting.update', (
    tester,
  ) async {
    final repository = MockAccountingRepository();

    final original = await pumpEditScreen(
      tester,
      accountingRepository: repository,
      seedReceiptDocumentId: 55,
    );

    await tester.enterText(find.byType(TextField).first, '99.90');
    await tester.enterText(find.byType(TextField).last, 'Ergonomic chair');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final transactions = await repository.list();
    expect(transactions.single.id, original.id);
    expect(transactions.single.amountCents, 9990);
    expect(transactions.single.description, 'Ergonomic chair');
    // Unedited fields pass through unchanged.
    expect(transactions.single.receiptDocumentId, 55);
    expect(transactions.single.type, TransactionType.expense);
    // The editor closed after saving.
    expect(find.text('Edit entry'), findsNothing);
  });

  testWidgets('detaching the current receipt clears the link on save', (
    tester,
  ) async {
    final documentRepository = MockDocumentRepository();
    final receipt = await documentRepository.upload(
      businessId: 1,
      file: PickedFileAttachment(fileName: 'beleg.pdf', bytes: [1]),
      kind: DocumentKind.receipt,
    );
    final repository = MockAccountingRepository();

    await pumpEditScreen(
      tester,
      accountingRepository: repository,
      documentRepository: documentRepository,
      seedReceiptDocumentId: receipt.id,
    );

    await tester.tap(find.byTooltip('Remove receipt'));
    await tester.pumpAndSettle();
    // Back to the attach action; no upload happened by removing.
    expect(find.text('beleg.pdf'), findsNothing);
    expect(find.text('Attach receipt'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '10.00');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final transactions = await repository.list();
    expect(transactions.single.receiptDocumentId, isNull);
  });

  testWidgets('a failed update keeps the form open with an error snackbar', (
    tester,
  ) async {
    await pumpEditScreen(
      tester,
      accountingRepository: MockAccountingRepository(),
      overrideRepository: _FailingUpdateRepository(),
    );

    await tester.enterText(find.byType(TextField).first, '10.00');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text("We couldn't save the transaction. Please try again."),
      findsOneWidget,
    );
    // The editor stayed open for another attempt.
    expect(find.text('Edit entry'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}

class _NullFilePickerService implements FilePickerService {
  @override
  Future<PickedFileAttachment?> pickSingle({
    List<String>? allowedExtensions,
  }) async => null;
}
