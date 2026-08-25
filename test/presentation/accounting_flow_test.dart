import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/domain/entities/document.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/domain/repositories/accounting_repository.dart';
import 'package:gewerber_app/domain/repositories/document_repository.dart';
import 'package:gewerber_app/infrastructure/services/file_picker_service.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/accounting_entry_create_screen.dart';
import 'package:gewerber_app/presentation/screens/home/accounting_screen.dart';
import 'package:gewerber_app/presentation/screens/home/dashboard_screen.dart';
import 'package:gewerber_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';

/// End-to-end accounting flow through the real app shell in mock mode:
/// record an expense with an attached receipt, then edit it — mirroring the
/// boot pattern of `invoicing_flow_test.dart`.
///
/// The platform file picker is replaced by a fake via DI before the first
/// frame, so "Attach receipt" runs without a platform channel; everything
/// else (documents upload, transaction link) uses the registered mock
/// repositories.
class _FakeFilePickerService implements FilePickerService {
  _FakeFilePickerService(this.result);

  final PickedFileAttachment? result;

  @override
  Future<PickedFileAttachment?> pickSingle({
    List<String>? allowedExtensions,
  }) async => result;
}

void main() {
  setUpAll(() {
    configureDependencies();
    // Must run before any cubit resolves [FilePickerService] (the lazily
    // constructed DocumentsCubit is built with the first pumped frame).
    getIt.unregister<FilePickerService>();
    getIt.registerSingleton<FilePickerService>(
      _FakeFilePickerService(
        PickedFileAttachment(fileName: 'beleg.pdf', bytes: [1, 2, 3]),
      ),
    );
  });

  Future<void> pumpAtLogin(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    appRouter.go(RouteNames.splash);
    await tester.pumpWidget(const GewerberApp());
    await tester.pumpAndSettle();
  }

  Future<void> signIn(WidgetTester tester) async {
    await tester.enterText(
      find.byType(CustomTextField).at(0),
      'demo@gewerber.de',
    );
    await tester.enterText(find.byType(CustomTextField).at(1), 'demo-password');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    if (find.byType(OnboardingScreen).evaluate().isNotEmpty) {
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Demo GmbH');
      await tester.tap(find.text('Create business'));
      await tester.pumpAndSettle();
    }
    expect(find.byType(DashboardScreen), findsOneWidget);
  }

  /// Snackbar timers keep pumping frames for a few seconds after saving;
  /// let them run out so the following assertions see a settled list.
  Future<void> settleAfterSave(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  testWidgets('record an expense with a receipt and edit it afterwards', (
    tester,
  ) async {
    await pumpAtLogin(tester);
    await signIn(tester);

    // Accounting tab starts empty.
    await tester.tap(find.text('Accounting'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountingScreen), findsOneWidget);
    expect(
      find.text('No transactions yet. Record your first income or expense.'),
      findsOneWidget,
    );

    // Open the entry form.
    await tester.tap(find.text('Add entry'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountingEntryCreateScreen), findsOneWidget);

    // Fill the form: amount (first field) and description (second field).
    await tester.enterText(find.byType(TextField).at(0), '49.90');
    await tester.enterText(find.byType(TextField).at(1), 'Software-Lizenz');

    // Attach a receipt (fake picker answers immediately).
    await tester.ensureVisible(find.text('Attach receipt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Attach receipt'));
    await tester.pumpAndSettle();
    expect(find.text('beleg.pdf'), findsOneWidget);

    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await settleAfterSave(tester);

    // Back on the list with the new expense. After login the app format
    // locale is en_US (test dispatcher default): `€49.90`.
    expect(find.byType(AccountingScreen), findsOneWidget);
    expect(find.text('Software-Lizenz'), findsOneWidget);
    expect(find.text('-€49.90'), findsOneWidget);

    // The receipt was uploaded as such and linked to the transaction.
    final documents = await getIt<DocumentRepository>().list();
    expect(documents.single.kind, DocumentKind.receipt);
    expect(documents.single.fileName, 'beleg.pdf');
    final transactions = await getIt<AccountingRepository>().list();
    final created = transactions.single;
    expect(created.type, TransactionType.expense);
    expect(created.category, TransactionCategory.office);
    expect(created.amountCents, 4990);
    expect(created.receiptDocumentId, documents.single.id);

    // Tap the tile to edit: fields are prefilled, receipt is resolved.
    await tester.tap(find.text('Software-Lizenz'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountingEntryCreateScreen), findsOneWidget);
    expect(find.text('Attached receipt'), findsOneWidget);
    expect(find.text('beleg.pdf'), findsOneWidget);

    // Change amount and description, then save.
    await tester.enterText(find.byType(TextField).at(0), '59.90');
    await tester.enterText(find.byType(TextField).at(1), 'Software-Lizenz 26');
    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await settleAfterSave(tester);

    // Back on the list with the updated values.
    expect(find.byType(AccountingScreen), findsOneWidget);
    expect(find.text('Software-Lizenz 26'), findsOneWidget);
    expect(find.text('-€59.90'), findsOneWidget);

    // Same single transaction, updated amounts, receipt link intact.
    final updated = await getIt<AccountingRepository>().list();
    expect(updated.single.id, created.id);
    expect(updated.single.amountCents, 5990);
    expect(updated.single.description, 'Software-Lizenz 26');
    expect(updated.single.receiptDocumentId, documents.single.id);
    expect((await getIt<DocumentRepository>().list()).length, 1);
  });

  testWidgets('record an income without a receipt', (tester) async {
    await pumpAtLogin(tester);
    await signIn(tester);

    await tester.tap(find.text('Accounting'));
    await tester.pumpAndSettle();

    // The previous test's transactions are still registered (mock
    // singletons persist within this file), so this scenario identifies
    // its own entry by a unique description.
    await tester.tap(find.text('Add entry'));
    await tester.pumpAndSettle();

    // Switch to income; the category resets to the first income category.
    // Open the dropdown and pick a different one (`.last` targets the menu
    // item, not the field label showing the current value).
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sales revenue').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Service revenue').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '1200');
    await tester.enterText(find.byType(TextField).at(1), 'Workshop-Einkommen');
    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await settleAfterSave(tester);

    expect(find.text('Workshop-Einkommen'), findsOneWidget);

    final transactions = await getIt<AccountingRepository>().list();
    final created = transactions.firstWhere(
      (transaction) => transaction.description == 'Workshop-Einkommen',
    );
    expect(created.type, TransactionType.income);
    expect(created.category, TransactionCategory.serviceRevenue);
    expect(created.amountCents, 120000);
    expect(created.receiptDocumentId, isNull);

    // Income renders with a positive sign.
    expect(find.text('+€1,200.00'), findsOneWidget);
  });
}
