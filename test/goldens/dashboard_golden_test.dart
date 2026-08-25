import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/presentation/screens/home/dashboard_screen.dart';

import 'golden_test_helper.dart';

/// Golden tests for the dashboard, covering both sides of the 900 px
/// two-column breakpoint.
///
/// Determinism:
/// - fonts are pinned via `configureGoldenEnvironment` (no runtime fetching);
/// - all wall-clock inputs flow through the pinned-anchor repository
///   installed by `installGoldenDashboardRepository` (fixed trend month
///   labels, fixed receivables fixture);
/// - the invoice/accounting/time repositories stay empty on purpose, so the
///   open-invoices/month-result/tracked-time sections render their stable
///   empty states.
void main() {
  setUpAll(() {
    configureDependencies();
    configureGoldenEnvironment();
    installGoldenDashboardRepository();
  });

  testWidgets('dashboard — phone layout (single column)', (tester) async {
    await pumpAuthenticatedApp(tester, size: goldenPhoneSize);

    expect(find.byType(DashboardScreen), findsOneWidget);
    await expectLater(
      find.byType(GewerberApp),
      matchesGoldenFile('dashboard_phone_390x844.png'),
    );
  });

  testWidgets('dashboard — wide layout (two columns at >= 900)', (
    tester,
  ) async {
    await pumpAuthenticatedApp(tester, size: goldenWideSize);

    expect(find.byType(DashboardScreen), findsOneWidget);
    await expectLater(
      find.byType(GewerberApp),
      matchesGoldenFile('dashboard_wide_900x1280.png'),
    );
  });
}
