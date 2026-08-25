import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/config/app_flavor.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/accounting_screen.dart';
import 'package:gewerber_app/presentation/screens/home/dashboard_screen.dart';
import 'package:gewerber_app/presentation/screens/home/invoicing_screen.dart';
import 'package:gewerber_app/presentation/screens/home/settings_master_detail.dart';
import 'package:gewerber_app/presentation/screens/home/time_tracking_screen.dart';
import 'package:gewerber_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:gewerber_app/presentation/screens/splash/splash_screen.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';

/// End-to-end smoke test: boots the real app shell in **mock mode** (zero
/// network) and taps through the five bottom-nav tabs, asserting one key
/// element per tab.
///
/// Composition mirrors `lib/main_dev.dart` (the mock-auth flavor): the
/// [FlavorConfig] is initialized with `authMode: mock` before the shared
/// [bootstrap]-equivalent wiring runs. In a debug build
/// `AppEnvironment.authEnvironment` resolves to the mock environment anyway;
/// the explicit flavor keeps the intent visible and independent of the build
/// mode.
///
/// Run:
/// ```
/// flutter test integration_test -d linux
/// flutter test integration_test -d chrome
/// flutter test integration_test -d <android device id>
/// ```
Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  FlavorConfig(
    name: AppFlavor.dev.bannerName,
    color: AppFlavor.dev.bannerColor,
    variables: const {
      'serverHost': 'http://localhost:8080', // never contacted in mock mode
      'authMode': 'mock',
    },
  );
  configureDependencies(environment: AppEnvironment.authMock);

  testWidgets('smoke: sign in, land on dashboard, visit every tab', (
    tester,
  ) async {
    appRouter.go(RouteNames.splash);
    await tester.pumpWidget(const GewerberApp());

    // Splash resolves the (non-existent) session and redirects to login.
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.text('Welcome back'), findsOneWidget);

    // Sign in with the demo account.
    await tester.enterText(
      find.byType(CustomTextField).at(0),
      'demo@gewerber.de',
    );
    await tester.enterText(find.byType(CustomTextField).at(1), 'demo-password');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // New accounts without a business land on onboarding.
    if (find.byType(OnboardingScreen).evaluate().isNotEmpty) {
      await _tapVisible(tester, find.text('Continue'));
      await tester.enterText(find.byType(TextFormField), 'Demo GmbH');
      // Drop focus: the focused field's deferred bring-into-view otherwise
      // re-scrolls the form during the next settle and pushes the action
      // button back below the fold on smaller windows.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await _tapVisible(tester, find.text('Create business'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    debugPrint(
      'SMOKE: location=${appRouter.routerDelegate.currentConfiguration.uri}',
    );

    // Tab 1: Dashboard.
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Quick actions'), findsOneWidget);

    // Tab 2: Invoicing.
    await _gotoTab(tester, 'Invoicing');
    expect(find.byType(InvoicingScreen), findsOneWidget);

    // Tab 3: Time tracking.
    await _gotoTab(tester, 'Time');
    expect(find.byType(TimeTrackingScreen), findsOneWidget);

    // Tab 4: Accounting.
    await _gotoTab(tester, 'Accounting');
    expect(find.byType(AccountingScreen), findsOneWidget);

    // Tab 5: Settings.
    await _gotoTab(tester, 'Settings');
    expect(find.byType(SettingsMasterDetail), findsOneWidget);
  });
}

/// Taps a navigation destination by label. The label is rendered by both
/// navigation surfaces (bottom [NavigationBar] on narrow windows,
/// [NavigationRail] on wide ones), so the flow is window-size independent.
Future<void> _gotoTab(WidgetTester tester, String label) async {
  await _tapVisible(tester, find.text(label));
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

/// Brings [finder] into view if needed, then taps it.
Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
}
