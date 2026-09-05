import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/domain/entities/document.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/repositories/business_repository.dart';
import 'package:gewerber_app/domain/repositories/dashboard_repository.dart';
import 'package:gewerber_app/domain/repositories/document_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_business_repository.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/auth/login_screen.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';

export 'package:gewerber_app/presentation/app/gewerber_app.dart';

/// Phone-size viewport (logical pixels, dpr 1.0): the narrow side of every
/// layout breakpoint in the app.
const Size goldenPhoneSize = Size(390, 844);

/// Wide viewport sitting exactly on the app's 900 px breakpoints
/// (`maxWidth >= 900` switches the shell to the navigation rail and the
/// dashboard to its two-column layout).
const Size goldenWideSize = Size(900, 1280);

/// Fixed "today" for every wall-clock-derived fixture. All mock data that
/// renders dates is pinned to this instant so goldens stay byte-identical
/// regardless of when they are re-generated.
final DateTime goldenAnchor = DateTime(2026, 8, 25, 12);

/// Test-environment tweaks for deterministic golden output.
///
/// - Fonts: the production theme resolves Inter/Roboto Mono through
///   `google_fonts` at runtime. Runtime fetching is disabled here so no
///   network I/O happens; text falls back to the deterministic Flutter
///   engine test font instead (no bundled font assets exist in this repo).
void configureGoldenEnvironment() {
  GoogleFonts.config.allowRuntimeFetching = false;
}

/// Boots the real app (mock DI) at [size] and ends up signed in with a
/// created business ("Demo GmbH"), i.e. inside the authenticated home shell.
///
/// Mirrors the boot path of the existing widget tests (`test/widget_test.dart`,
/// `test/presentation/*`): splash → login → onboarding → dashboard. Safe to
/// call repeatedly within one test file: singleton state persists between
/// tests, so later calls skip login/onboarding when already done.
Future<void> pumpAuthenticatedApp(
  WidgetTester tester, {
  required Size size,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  appRouter.go(RouteNames.splash);
  // Pre-create the business through the mock repository instead of driving
  // the onboarding UI: the onboarding screen pops right after the form is
  // submitted, and its field-hint OverlayPortal semantics subtree can leave
  // a stale node behind in that frame (framework semantics race), tripping
  // the invisible-semantics assertion in golden tests. The guard keeps
  // repeated calls within one test file from accumulating duplicates.
  final businessRepository = getIt<BusinessRepository>();
  if (businessRepository is MockBusinessRepository) {
    final existing = await businessRepository.listMine();
    if (existing.isEmpty) {
      await businessRepository.create(name: 'Demo GmbH');
    }
  }
  await tester.pumpWidget(
    const TooltipVisibility(visible: false, child: GewerberApp()),
  );
  await tester.pumpAndSettle();

  if (find.byType(LoginScreen).evaluate().isNotEmpty) {
    await tester.enterText(
      find.byType(CustomTextField).at(0),
      'demo@gewerber.de',
    );
    await tester.enterText(find.byType(CustomTextField).at(1), 'demo-password');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
  }
}

/// Replaces the DI-bound [DashboardRepository] with a wrapper that pins all
/// wall-clock inputs:
///
/// - trends/activity are delegated to the mock repository with
///   [goldenAnchor] as anchor (the mock derives everything deterministically
///   from it);
/// - receivables return a fully fixed fixture, because the overdue rows on
///   the dashboard render absolute due dates and the mock's `receivables()`
///   has no anchor seam.
///
/// Must run after [configureDependencies] and before the first
/// `pumpWidget`, so the lazily constructed `DashboardCubit` picks up the
/// wrapper.
void installGoldenDashboardRepository() {
  final inner = getIt<DashboardRepository>();
  getIt.unregister<DashboardRepository>();
  getIt.registerSingleton<DashboardRepository>(
    _PinnedAnchorDashboardRepository(inner),
  );
}

class _PinnedAnchorDashboardRepository implements DashboardRepository {
  _PinnedAnchorDashboardRepository(this._inner);

  final DashboardRepository _inner;

  /// Fixed receivables fixture (stable invoice numbers, amounts and dates;
  /// nothing derived from the real clock).
  static final ReceivablesSummary _receivables = ReceivablesSummary(
    outstandingTotalCents: 560800,
    debtors: [
      const DebtorLine(
        customerId: 501,
        displayName: 'Müller GmbH',
        outstandingCents: 337300,
        invoiceCount: 2,
      ),
      const DebtorLine(
        customerId: 502,
        displayName: 'Schmidt & Co. KG',
        outstandingCents: 149500,
        invoiceCount: 1,
      ),
      const DebtorLine(
        customerId: null,
        displayName: null,
        outstandingCents: 74000,
        invoiceCount: 1,
      ),
    ],
    overdueInvoices: [
      Invoice(
        id: 9013,
        number: 'RE-2026-13',
        status: InvoiceStatus.overdue,
        customerId: 502,
        issueDate: DateTime(2026, 7, 30),
        dueDate: DateTime(2026, 8, 10),
        totalCents: 149500,
      ),
      Invoice(
        id: 9011,
        number: 'RE-2026-11',
        status: InvoiceStatus.overdue,
        customerId: null,
        issueDate: DateTime(2026, 7, 14),
        dueDate: DateTime(2026, 8, 4),
        totalCents: 74000,
      ),
    ],
  );

  @override
  Future<List<MonthlyFinancials>> monthlyFinancials({
    required int months,
    DateTime? anchor,
  }) {
    return _inner.monthlyFinancials(months: months, anchor: goldenAnchor);
  }

  @override
  Future<List<RecentActivityItem>> recentActivity({
    int limit = DashboardRepository.defaultActivityLimit,
    DateTime? anchor,
  }) {
    return _inner.recentActivity(limit: limit, anchor: goldenAnchor);
  }

  @override
  Future<ReceivablesSummary> receivables() async => _receivables;

  @override
  Future<DashboardSummary> summary({required int months, DateTime? anchor}) {
    return _inner.summary(months: months, anchor: goldenAnchor);
  }
}

/// Replaces the DI-bound [DocumentRepository] with a wrapper that rewrites
/// every document's `createdAt` to a fixed date derived from its id
/// (2026-08-26 minus id days). The mock repository stamps uploads with
/// `DateTime.now()` internally and has no injection seam, so the rendered
/// upload dates would otherwise change every calendar day.
///
/// Must run after [configureDependencies] and before the first
/// `pumpWidget`, so the lazily constructed `DocumentsCubit` picks up the
/// wrapper.
void installGoldenDocumentRepository() {
  final inner = getIt<DocumentRepository>();
  getIt.unregister<DocumentRepository>();
  getIt.registerSingleton<DocumentRepository>(
    _FixedCreatedAtDocumentRepository(inner),
  );
}

BusinessDocument _withPinnedCreatedAt(BusinessDocument document) {
  return BusinessDocument(
    id: document.id,
    businessId: document.businessId,
    fileName: document.fileName,
    kind: document.kind,
    mimeType: document.mimeType,
    sizeBytes: document.sizeBytes,
    storagePath: document.storagePath,
    relatedEntityType: document.relatedEntityType,
    relatedEntityId: document.relatedEntityId,
    createdAt: DateTime(2026, 8, 26 - document.id),
  );
}

class _FixedCreatedAtDocumentRepository implements DocumentRepository {
  _FixedCreatedAtDocumentRepository(this._inner);

  final DocumentRepository _inner;

  @override
  Future<List<BusinessDocument>> list({
    DocumentKind? kind,
    String? relatedEntityType,
    String? relatedEntityId,
    int? limit,
    int? offset,
  }) async {
    final documents = await _inner.list(
      kind: kind,
      relatedEntityType: relatedEntityType,
      relatedEntityId: relatedEntityId,
      limit: limit,
      offset: offset,
    );
    // The inner repository already sorted by its internal timestamps;
    // patching preserves that order while pinning the rendered dates.
    return [for (final document in documents) _withPinnedCreatedAt(document)];
  }

  @override
  Future<BusinessDocument?> get(int documentId) async {
    final document = await _inner.get(documentId);
    return document == null ? null : _withPinnedCreatedAt(document);
  }

  @override
  Future<BusinessDocument> upload({
    required int businessId,
    required PickedFileAttachment file,
    DocumentKind kind = DocumentKind.attachment,
    String? relatedEntityType,
    String? relatedEntityId,
  }) async {
    final document = await _inner.upload(
      businessId: businessId,
      file: file,
      kind: kind,
      relatedEntityType: relatedEntityType,
      relatedEntityId: relatedEntityId,
    );
    return _withPinnedCreatedAt(document);
  }

  @override
  Future<DownloadedDocument> download(BusinessDocument document) {
    return _inner.download(document);
  }

  @override
  Future<void> delete(int documentId) => throw UnimplementedError();
}
