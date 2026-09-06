import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/settings/app_settings_cubit.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_user_preferences_repository.dart';
import 'package:gewerber_app/domain/repositories/user_preferences_repository.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/dashboard_screen.dart';
import 'package:gewerber_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:gewerber_app/presentation/screens/onboarding/widgets/preferences_step.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';

void main() {
  setUpAll(configureDependencies);

  setUp(() {
    getIt<AuthCubit>().reset();
    getIt<AppSettingsCubit>().reset();
    final repo = getIt<UserPreferencesRepository>();
    if (repo is MockUserPreferencesRepository) {
      repo.reset();
    }
  });

  Future<void> signIn(WidgetTester tester) async {
    appRouter.go(RouteNames.splash);
    await tester.pumpWidget(const GewerberApp());
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(CustomTextField).at(0),
      'demo@gewerber.de',
    );
    await tester.enterText(find.byType(CustomTextField).at(1), 'demo-password');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
  }

  testWidgets('preferences step renders without overflow on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await signIn(tester);

    // A new mock user has no business, so sign-in lands on onboarding.
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(PreferencesStep), findsOneWidget);
    expect(
      tester.takeException(),
      isNull,
      reason: 'overflow on the preferences step at 320px',
    );
  });

  testWidgets(
    'preferences step applies theme and language, then leads to business setup',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await signIn(tester);
      expect(find.byType(PreferencesStep), findsOneWidget);

      // Both preference sections are present.
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);

      // Switching the theme updates the whole app immediately.
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      final brightness = Theme.of(
        tester.element(find.byType(OnboardingScreen)),
      ).brightness;
      expect(brightness, Brightness.dark);

      // Switching the language updates the whole app immediately.
      await tester.tap(find.text('Русский'));
      await tester.pumpAndSettle();
      expect(find.text('Язык'), findsOneWidget);

      // Continue to the business form (now in Russian).
      await tester.tap(find.text('Продолжить'));
      await tester.pumpAndSettle();
      expect(find.text('Создать бизнес'), findsOneWidget);

      // Back returns to the preferences step.
      final backButton = find.text('Назад');
      await tester.ensureVisible(backButton);
      await tester.pumpAndSettle();
      await tester.tap(backButton);
      await tester.pumpAndSettle();
      expect(find.byType(PreferencesStep), findsOneWidget);

      // Finish onboarding.
      await tester.tap(find.text('Продолжить'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Demo GmbH');
      final createButton = find.text('Создать бизнес');
      await tester.ensureVisible(createButton);
      await tester.pumpAndSettle();
      await tester.tap(createButton);
      await tester.pumpAndSettle();
      expect(find.byType(DashboardScreen), findsOneWidget);
    },
  );
}
