import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/domain/repositories/time_tracking_repository.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/dashboard_screen.dart';
import 'package:gewerber_app/presentation/screens/home/time_tracking_screen.dart';
import 'package:gewerber_app/presentation/screens/home/timer_screen.dart';
import 'package:gewerber_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';

/// Timer flow through the real app shell in mock mode: start the stopwatch
/// with a description, see it running, stop it and find the entry in the
/// recent list — mirroring the boot pattern of `invoicing_flow_test.dart`.
void main() {
  setUpAll(configureDependencies);

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

  testWidgets('start and stop the timer from the time tab', (tester) async {
    await pumpAtLogin(tester);
    await signIn(tester);

    // Time tab -> Timer sub-screen.
    await tester.tap(find.text('Time'));
    await tester.pumpAndSettle();
    expect(find.byType(TimeTrackingScreen), findsOneWidget);

    await tester.tap(find.text('Timer'));
    await tester.pumpAndSettle();
    expect(find.byType(TimerScreen), findsOneWidget);

    // Describe the work and start the stopwatch.
    await tester.enterText(find.byType(TextField), 'Kunde-Call');
    await tester.tap(find.text('Start timer'));

    // The running card rebuilds every second via a periodic stream, which
    // never settles — pump explicitly instead of pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Timer running'), findsOneWidget);
    expect(find.text('Kunde-Call'), findsOneWidget);
    expect(find.text('Stop timer'), findsOneWidget);

    // Stop it; with the running card gone the screen settles again.
    await tester.tap(find.text('Stop timer'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('Timer running'), findsNothing);
    expect(find.text('Recent entries'), findsOneWidget);
    // The stopped entry shows up in the recent list.
    expect(find.text('Kunde-Call'), findsOneWidget);
    expect(find.text('0m'), findsOneWidget);

    // Repository state: one stopped billable entry with the description.
    final entries = await getIt<TimeTrackingRepository>().listEntries();
    expect(entries, hasLength(1));
    expect(entries.single.description, 'Kunde-Call');
    expect(entries.single.billable, isTrue);
    expect(entries.single.durationMinutes, 0);
    expect(entries.single.isRunning, isFalse);
  });
}
