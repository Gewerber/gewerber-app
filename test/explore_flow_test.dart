import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/auth/login_screen.dart';
import 'package:gewerber_app/presentation/screens/home/accounting_screen.dart';
import 'package:gewerber_app/presentation/screens/home/dashboard_screen.dart';
import 'package:gewerber_app/presentation/screens/home/invoicing_screen.dart';
import 'package:gewerber_app/presentation/screens/home/settings_master_detail.dart';
import 'package:gewerber_app/presentation/screens/home/time_tracking_screen.dart';
import 'package:gewerber_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';

void main() {
  setUpAll(configureDependencies);

  Future<void> pumpAtLogin(WidgetTester tester) async {
    // Tall surface so the whole onboarding form fits without scrolling.
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // The app router is a shared singleton; reset it to a clean location so
    // each test starts on the splash -> login flow.
    appRouter.go(RouteNames.splash);
    await tester.pumpWidget(const GewerberApp());
    await tester.pumpAndSettle();
  }

  // Signed-in users without a business land on onboarding; create one to
  // reach the shell. No-op when a business already exists (singletons persist
  // between tests in this file).
  Future<void> completeOnboarding(WidgetTester tester) async {
    await tester.pumpAndSettle();
    if (find.byType(OnboardingScreen).evaluate().isEmpty) return;
    // The preferences step (theme/language) comes before the business form.
    if (find.text('Continue').evaluate().isNotEmpty) {
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }
    await tester.enterText(find.byType(TextFormField), 'Demo GmbH');
    await tester.tap(find.text('Create business'));
    await tester.pumpAndSettle();
  }

  testWidgets('Mock login reaches the app shell', (tester) async {
    await pumpAtLogin(tester);

    await tester.enterText(
      find.byType(CustomTextField).at(0),
      'demo@gewerber.de',
    );
    await tester.enterText(find.byType(CustomTextField).at(1), 'demo-password');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    await completeOnboarding(tester);

    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('Mock login and shell tabs navigate', (tester) async {
    await pumpAtLogin(tester);

    await tester.enterText(
      find.byType(CustomTextField).at(0),
      'demo@gewerber.de',
    );
    await tester.enterText(find.byType(CustomTextField).at(1), 'demo-password');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    await completeOnboarding(tester);

    expect(find.byType(DashboardScreen), findsOneWidget);

    await tester.tap(find.text('Invoicing'));
    await tester.pumpAndSettle();
    expect(find.byType(InvoicingScreen), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('New invoice'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(InvoicingScreen), findsOneWidget);

    await tester.tap(find.text('Time'));
    await tester.pumpAndSettle();
    expect(find.byType(TimeTrackingScreen), findsOneWidget);

    await tester.tap(find.text('Accounting'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountingScreen), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsMasterDetail), findsOneWidget);

    await tester.tap(find.text('Business profile'));
    await tester.pumpAndSettle();
    expect(find.text('Business profile'), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(SettingsMasterDetail), findsOneWidget);

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
