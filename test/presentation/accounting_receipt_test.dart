import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:gewerber_app/application/accounting/accounting_cubit.dart';
import 'package:gewerber_app/application/business/business_cubit.dart';
import 'package:gewerber_app/application/documents/documents_cubit.dart';
import 'package:gewerber_app/domain/entities/document.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_accounting_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_business_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_document_repository.dart';
import 'package:gewerber_app/infrastructure/services/file_picker_service.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/accounting_entry_create_screen.dart';

class _FakeFilePickerService implements FilePickerService {
  _FakeFilePickerService(this.result);

  final PickedFileAttachment? result;

  @override
  Future<PickedFileAttachment?> pickSingle({
    List<String>? allowedExtensions,
  }) async => result;
}

void main() {
  setUpAll(() async {
    // Date formatting uses the German default locale (see core/utils/format).
    await initializeDateFormatting('de_DE');
  });

  Future<
    ({
      MockAccountingRepository accountingRepository,
      MockDocumentRepository documentRepository,
    })
  >
  pumpScreen(
    WidgetTester tester, {
    required FilePickerService pickerService,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final businessRepository = MockBusinessRepository();
    await businessRepository.create(name: 'Musterbetrieb');
    final businessCubit = BusinessCubit(businessRepository)..load();

    final accountingRepository = MockAccountingRepository();
    final documentRepository = MockDocumentRepository();

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Scaffold()),
        GoRoute(
          path: '/new',
          builder: (context, state) => const AccountingEntryCreateScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<BusinessCubit>.value(value: businessCubit),
          BlocProvider<AccountingCubit>.value(
            value: AccountingCubit(accountingRepository),
          ),
          BlocProvider<DocumentsCubit>.value(
            value: DocumentsCubit(documentRepository, pickerService),
          ),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    router.push('/new');
    await tester.pumpAndSettle();

    return (
      accountingRepository: accountingRepository,
      documentRepository: documentRepository,
    );
  }

  Future<void> enterAmount(WidgetTester tester) async {
    // The first TextField on the form is the amount field.
    await tester.enterText(find.byType(TextField).first, '49.90');
  }

  testWidgets('attaching a receipt uploads it and links it on save', (
    tester,
  ) async {
    final repos = await pumpScreen(
      tester,
      pickerService: _FakeFilePickerService(
        PickedFileAttachment(fileName: 'beleg.pdf', bytes: List.filled(10, 1)),
      ),
    );

    await tester.tap(find.text('Attach receipt'));
    await tester.pumpAndSettle();

    // The picked file is announced before saving.
    expect(find.text('beleg.pdf'), findsOneWidget);

    await enterAmount(tester);
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // The receipt was uploaded as such and linked to the new transaction.
    final documents = await repos.documentRepository.list();
    expect(documents.single.kind, DocumentKind.receipt);
    expect(documents.single.fileName, 'beleg.pdf');
    final transactions = await repos.accountingRepository.list();
    expect(transactions.single.receiptDocumentId, documents.single.id);
  });

  testWidgets('oversized receipts are rejected client-side', (tester) async {
    final repos = await pumpScreen(
      tester,
      pickerService: _FakeFilePickerService(
        PickedFileAttachment(
          fileName: 'huge.png',
          bytes: List.filled(documentMaxSizeBytes + 1, 0),
        ),
      ),
    );

    await tester.tap(find.text('Attach receipt'));
    await tester.pumpAndSettle();

    expect(find.textContaining('512 KB'), findsOneWidget);
    // Nothing was stored yet.
    final documents = await repos.documentRepository.list();
    expect(documents, isEmpty);
  });

  testWidgets('the attachment can be removed before saving', (tester) async {
    final repos = await pumpScreen(
      tester,
      pickerService: _FakeFilePickerService(
        PickedFileAttachment(fileName: 'beleg.pdf', bytes: [1]),
      ),
    );

    await tester.tap(find.text('Attach receipt'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Remove receipt'));
    await tester.pumpAndSettle();

    expect(find.text('beleg.pdf'), findsNothing);
    expect(find.text('Attach receipt'), findsOneWidget);

    await enterAmount(tester);
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // No upload happened; the transaction has no receipt.
    expect(await repos.documentRepository.list(), isEmpty);
    final transactions = await repos.accountingRepository.list();
    expect(transactions.single.receiptDocumentId, isNull);
  });
}
