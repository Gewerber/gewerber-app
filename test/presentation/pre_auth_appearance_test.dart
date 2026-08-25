import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/settings/app_settings_cubit.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/auth/login_screen.dart';
import 'package:gewerber_app/presentation/screens/auth/register_screen.dart';

/// Pre-auth appearance controls on the shared auth layout.
///
/// The language and color-scheme switchers live in `AuthPanelLayout`, so
/// they are asserted through the full app shell exactly like a fresh visitor
/// would see them (mock auth, unauthenticated).
void main() {
  setUpAll(configureDependencies);

  Future<void> pumpApp(WidgetTester tester) async {
    appRouter.go(RouteNames.splash);
    await tester.pumpWidget(const GewerberApp());
    await tester.pumpAndSettle();
  }

  Finder materialAppThemeMode() => find.byType(MaterialApp);

  testWidgets('login screen offers language and color-scheme controls when '
      'unauthenticated', (tester) async {
    await pumpApp(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byTooltip('Language'), findsOneWidget);
    expect(find.byTooltip('Theme'), findsOneWidget);

    // Language menu: system default plus the four supported languages.
    await tester.tap(find.byTooltip('Language'));
    await tester.pumpAndSettle();
    expect(find.text('System default'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Deutsch'), findsOneWidget);
    expect(find.text('Русский'), findsOneWidget);
    expect(find.text('Türkçe'), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    // Color-scheme menu: system, light, dark.
    await tester.tap(find.byTooltip('Theme'));
    await tester.pumpAndSettle();
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    // Restore the defaults so later suites are not affected.
    getIt<AppSettingsCubit>().reset();
  });

  testWidgets('register screen offers language and color-scheme controls when '
      'unauthenticated', (tester) async {
    await pumpApp(tester);

    appRouter.go(RouteNames.register);
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);

    expect(find.byTooltip('Language'), findsOneWidget);
    expect(find.byTooltip('Theme'), findsOneWidget);

    // Restore the defaults so later suites are not affected.
    getIt<AppSettingsCubit>().reset();
  });

  testWidgets('choosing a language re-renders the screen localized', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.tap(find.byTooltip('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();

    expect(find.text('Willkommen zurück'), findsOneWidget);

    // Back to English via the same control.
    await tester.tap(find.byTooltip('Sprache'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('the system-default language entry returns to the system '
      'locale', (tester) async {
    await pumpApp(tester);
    expect(find.text('Welcome back'), findsOneWidget);

    // Force a concrete language first…
    await tester.tap(find.byTooltip('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(find.text('С возвращением'), findsOneWidget);

    // …then hand control back to the system (test default: English).
    // The entry label itself is localized — it is «Как в системе» now.
    await tester.tap(find.byTooltip('Язык'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Как в системе'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('choosing a color scheme flips the MaterialApp theme mode', (
    tester,
  ) async {
    await pumpApp(tester);

    ThemeMode? currentMode() =>
        tester.widget<MaterialApp>(materialAppThemeMode()).themeMode;
    Brightness screenBrightness() =>
        Theme.of(tester.element(find.byType(LoginScreen))).brightness;

    expect(currentMode(), ThemeMode.system);
    expect(screenBrightness(), Brightness.light);

    await tester.tap(find.byTooltip('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(currentMode(), ThemeMode.dark);
    expect(screenBrightness(), Brightness.dark);

    await tester.tap(find.byTooltip('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    expect(currentMode(), ThemeMode.light);
    expect(screenBrightness(), Brightness.light);

    await tester.tap(find.byTooltip('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();

    expect(currentMode(), ThemeMode.system);
    expect(screenBrightness(), Brightness.light);
  });

  testWidgets(
    'the auth header falls back to the bare logo below the narrow-pane '
    'breakpoint and never overflows at 320px',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpApp(tester);

      expect(find.byType(LoginScreen), findsOneWidget);
      // Wordmark replaced by the bare logo…
      expect(find.text('Gewerber'), findsNothing);
      // …while both appearance switchers keep their place in the header.
      expect(find.byTooltip('Language'), findsOneWidget);
      expect(find.byTooltip('Theme'), findsOneWidget);
      expect(
        tester.takeException(),
        isNull,
        reason: 'auth header overflow at 320px',
      );
    },
  );

  testWidgets(
    'the auth header shows the wordmark above the narrow-pane breakpoint',
    (tester) async {
      // Default 800×600 test surface: stacked layout, pane ≥ breakpoint.
      await pumpApp(tester);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Gewerber'), findsOneWidget);
    },
  );
}
