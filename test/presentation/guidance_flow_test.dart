import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/domain/repositories/guidance_repository.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/dashboard_screen.dart';
import 'package:gewerber_app/presentation/screens/home/guidance_screen.dart';
import 'package:gewerber_app/presentation/screens/home/guidance_tips_screen.dart';
import 'package:gewerber_app/presentation/screens/home/settings_master_detail.dart';
import 'package:gewerber_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';

/// Guidance flow through the real app shell in mock mode: open the guides
/// from settings, tick a getting-started checklist item and dismiss a tip —
/// mirroring the boot pattern of `invoicing_flow_test.dart`.
///
/// The viewport stays below the 600 px settings breakpoint so every section
/// is pushed as its own screen with the usual AppBar back button.
void main() {
  setUpAll(() async {
    // The mock guidance repository persists progress in SharedPreferences.
    SharedPreferences.setMockInitialValues({});
    configureDependencies();
  });

  Future<void> pumpAtLogin(WidgetTester tester) async {
    tester.view.physicalSize = const Size(500, 1400);
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
      final continueButton = find.text('Continue');
      await tester.ensureVisible(continueButton);
      await tester.pumpAndSettle();
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Demo GmbH');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      final createButton = find.text('Create business');
      await tester.ensureVisible(createButton);
      await tester.pumpAndSettle();
      await tester.tap(createButton);
      await tester.pumpAndSettle();
    }
    expect(find.byType(DashboardScreen), findsOneWidget);
  }

  testWidgets('tick a checklist item and dismiss a tip', (tester) async {
    await pumpAtLogin(tester);
    await signIn(tester);

    // Settings -> Guides.
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsMasterDetail), findsOneWidget);

    await tester.tap(find.text('Guides'));
    await tester.pumpAndSettle();
    expect(find.byType(GuidanceScreen), findsOneWidget);

    // Checklist: starts empty, ticking an item advances the progress.
    await tester.tap(find.text('Checklist'));
    await tester.pumpAndSettle();

    expect(find.text('Done 0 of 6'), findsOneWidget);
    expect(find.text('Add your first customer'), findsOneWidget);

    await tester.tap(find.text('Add your first customer'));
    await tester.pumpAndSettle();

    expect(find.text('Done 1 of 6'), findsOneWidget);
    final completed = await getIt<GuidanceRepository>().completedItemKeys();
    expect(completed, contains('first_customer'));

    // Back to the guides index, then into the tips.
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    expect(find.byType(GuidanceScreen), findsOneWidget);

    await tester.tap(find.text('Tips'));
    await tester.pumpAndSettle();
    expect(find.byType(GuidanceTipsScreen), findsOneWidget);
    expect(find.text('Small business regulation (§ 19 UStG)'), findsOneWidget);
    expect(find.text('GoBD-compliant invoice numbers'), findsOneWidget);
    expect(find.text('Profit & loss (EÜR)'), findsOneWidget);

    // Dismiss the first tip; it disappears for good.
    await tester.tap(find.byTooltip("Don't show again").first);
    await tester.pumpAndSettle();

    expect(find.text('Small business regulation (§ 19 UStG)'), findsNothing);
    expect(find.text('GoBD-compliant invoice numbers'), findsOneWidget);
    expect(find.text('Profit & loss (EÜR)'), findsOneWidget);

    final tips = await getIt<GuidanceRepository>().tips();
    expect(tips, hasLength(2));
  });
}
