import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/business_settings_screen.dart';
import 'package:gewerber_app/presentation/screens/home/dashboard_screen.dart';
import 'package:gewerber_app/presentation/screens/home/settings_screen.dart';
import 'package:gewerber_app/presentation/screens/onboarding/onboarding_screen.dart';

void main() {
  setUpAll(configureDependencies);

  testWidgets('business settings load and save', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    appRouter.go(RouteNames.splash);
    await tester.pumpWidget(const GewerberApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Explore the demo'));
    await tester.pumpAndSettle();

    if (find.byType(OnboardingScreen).evaluate().isNotEmpty) {
      await tester.enterText(find.byType(TextFormField), 'Demo GmbH');
      await tester.tap(find.text('Create business'));
      await tester.pumpAndSettle();
    }
    expect(find.byType(DashboardScreen), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    await tester.tap(find.text('Business settings'));
    await tester.pumpAndSettle();
    expect(find.byType(BusinessSettingsScreen), findsOneWidget);

    // Defaults from the mock: 14 days due, prefix "RE-", year included.
    expect(find.text('14'), findsOneWidget);

    // Change the payment terms and save.
    await tester.enterText(find.byType(TextFormField).first, '30');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.byType(BusinessSettingsScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
