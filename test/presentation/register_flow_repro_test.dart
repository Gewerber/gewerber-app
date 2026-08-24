import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/auth/register_screen.dart';
import 'package:gewerber_app/presentation/widgets/auth/password_strength_meter.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';

void main() {
  setUpAll(configureDependencies);

  Future<void> pumpRegister(WidgetTester tester) async {
    appRouter.go(RouteNames.register);
    await tester.pumpWidget(const GewerberApp());
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);
  }

  Future<void> driveToPasswordStep(WidgetTester tester) async {
    // Step 1: email.
    await tester.enterText(
      find.byType(CustomTextField).first,
      'newuser@gewerber.de',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 2: code — one digit per box (each box has maxLength 1).
    for (var i = 0; i < 8; i++) {
      await tester.enterText(find.byType(TextField).at(i), '${i + 1}');
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('code step has no overflow on narrow screens', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpRegister(tester);

    await tester.enterText(
      find.byType(CustomTextField).first,
      'newuser@gewerber.de',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(
      tester.takeException(),
      isNull,
      reason: 'overflow on the verification code step at 320px',
    );
  });

  for (final size in const [
    Size(320, 568),
    Size(375, 667),
    Size(800, 500),
    Size(1200, 800),
  ]) {
    testWidgets('password step has no overflow at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpRegister(tester);
      await driveToPasswordStep(tester);

      expect(find.byType(RegisterScreen), findsOneWidget);

      // Type a strong password to reveal the strength meter.
      await tester.enterText(
        find.byType(CustomTextField).first,
        'StrongPass1!',
      );
      await tester.pumpAndSettle();
      expect(find.byType(PasswordStrengthMeter), findsOneWidget);
      expect(
        tester.takeException(),
        isNull,
        reason: 'overflow when meter is shown at $size',
      );
    });
  }

  testWidgets('completing registration lands inside the app shell', (
    tester,
  ) async {
    await pumpRegister(tester);
    await driveToPasswordStep(tester);

    // Fill both password fields and submit.
    final fields = find.byType(CustomTextField);
    await tester.enterText(fields.at(0), 'StrongPass1!');
    await tester.enterText(fields.at(1), 'StrongPass1!');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    final exception = tester.takeException();
    expect(
      exception,
      isNull,
      reason: 'GoException after completing registration',
    );
    // A brand-new user has no business yet, so the redirect lands on the
    // onboarding flow instead of the 404/error page.
    expect(
      appRouter.routerDelegate.currentConfiguration.uri.path,
      RouteNames.onboarding,
    );
  });
}
