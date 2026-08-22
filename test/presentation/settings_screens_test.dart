import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/settings/app_settings_cubit.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/domain/repositories/user_preferences_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_user_preferences_repository.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/language_screen.dart';
import 'package:gewerber_app/presentation/screens/home/settings_master_detail.dart';
import 'package:gewerber_app/presentation/screens/home/theme_screen.dart';
import 'package:gewerber_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';

void main() {
  setUpAll(configureDependencies);

  Future<void> signIn(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // The settings cubit and its mock backend are singletons; start from the
    // initial state so tests do not inherit locale/theme from an earlier test.
    getIt<AppSettingsCubit>().reset();
    (getIt<UserPreferencesRepository>() as MockUserPreferencesRepository)
        .reset();

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

    // New accounts without a business land on onboarding; create one to
    // reach the shell. No-op when a business already exists (singletons
    // persist between tests in this file).
    if (find.byType(OnboardingScreen).evaluate().isNotEmpty) {
      // The preferences step (theme/language) comes before the business form.
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Demo GmbH');
      await tester.tap(find.text('Create business'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsMasterDetail), findsOneWidget);
  }

  testWidgets('language screen switches the app language', (tester) async {
    await signIn(tester);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageScreen), findsOneWidget);

    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();

    // Settings language is applied globally: l10n strings switch to German.
    expect(find.text('Systemstandard'), findsOneWidget);

    // The language screen itself re-renders under the new locale.
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Sprache')),
      findsOneWidget,
    );
  });

  testWidgets('theme screen switches the app theme', (tester) async {
    await signIn(tester);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    expect(find.byType(ThemeScreen), findsOneWidget);

    Brightness brightness() {
      final element = tester.element(find.byType(ThemeScreen));
      return Theme.of(element).brightness;
    }

    expect(brightness(), Brightness.light);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(brightness(), Brightness.dark);
  });
}
