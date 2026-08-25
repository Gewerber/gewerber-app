import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/domain/entities/document.dart';
import 'package:gewerber_app/domain/repositories/document_repository.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/documents_screen.dart';

import 'golden_test_helper.dart';

/// Golden tests for the documents list.
///
/// Determinism: the mock repository stamps uploads with `DateTime.now()` and
/// has no injection seam, so `installGoldenDocumentRepository` (see
/// `golden_test_helper.dart`) rewrites every rendered `createdAt` to a fixed
/// date. File names, kinds and sizes are fixed fixture data.
void main() {
  setUpAll(() async {
    configureDependencies();
    configureGoldenEnvironment();
    installGoldenDocumentRepository();
    await _seedFixtures();
  });

  testWidgets('documents list — phone layout', (tester) async {
    await pumpAuthenticatedApp(tester, size: goldenPhoneSize);

    appRouter.go(RouteNames.settingsDocuments);
    await tester.pumpAndSettle();

    expect(find.byType(DocumentsScreen), findsOneWidget);
    await expectLater(
      find.byType(GewerberApp),
      matchesGoldenFile('documents_phone_390x844.png'),
    );
  });

  testWidgets('documents list — wide layout', (tester) async {
    await pumpAuthenticatedApp(tester, size: goldenWideSize);

    appRouter.go(RouteNames.settingsDocuments);
    await tester.pumpAndSettle();

    expect(find.byType(DocumentsScreen), findsOneWidget);
    await expectLater(
      find.byType(GewerberApp),
      matchesGoldenFile('documents_wide_900x1280.png'),
    );
  });
}

Future<void> _seedFixtures() async {
  final documents = getIt<DocumentRepository>();

  // businessId is not validated by the mock repository; the list endpoint
  // returns all stored documents regardless.
  const businessId = 1;

  await documents.upload(
    businessId: businessId,
    file: PickedFileAttachment(
      fileName: 'receipt-kita-august.pdf',
      mimeType: 'application/pdf',
      bytes: List.filled(2048, 0xAB),
    ),
    kind: DocumentKind.receipt,
  );
  await documents.upload(
    businessId: businessId,
    file: PickedFileAttachment(
      fileName: 'logo-gewerber.svg',
      mimeType: 'image/svg+xml',
      bytes: List.filled(342, 0x3C),
    ),
    kind: DocumentKind.logo,
  );
  await documents.upload(
    businessId: businessId,
    file: PickedFileAttachment(
      fileName: 'handwerk-angebot.pdf',
      mimeType: 'application/pdf',
      bytes: List.filled(51200, 0x25),
    ),
    kind: DocumentKind.attachment,
  );
}
