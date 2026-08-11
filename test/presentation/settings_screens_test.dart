import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/language_screen.dart';
import 'package:gewerber_app/presentation/screens/home/settings_screen.dart';
import 'package:gewerber_app/presentation/screens/home/theme_screen.dart';

void main() {
  setUpAll(configureDependencies);

  Future<void> signIn(WidgetTester tester) async {
    appRouter.go(RouteNames.splash);
    await tester.pumpWidget(const GewerberApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Explore the demo'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
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
