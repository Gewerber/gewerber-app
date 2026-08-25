import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';

/// End-to-end persistence seam: `configureDependencies` receives a warmed
/// `SharedPreferences` instance (as `bootstrap` does), the settings cubit
/// seeds from it synchronously and the persisted appearance applies to the
/// very first frame on the pre-auth screens.
void main() {
  late final SharedPreferences prefs;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'appearance.theme': 'dark',
      'appearance.locale': 'ru',
    });
    prefs = await SharedPreferences.getInstance();
    configureDependencies(sharedPreferences: prefs);
  });

  Future<void> pumpApp(WidgetTester tester) async {
    appRouter.go(RouteNames.splash);
    await tester.pumpWidget(const GewerberApp());
    await tester.pumpAndSettle();
  }

  testWidgets('persisted appearance applies from the first frame', (
    tester,
  ) async {
    await pumpApp(tester);

    // Seeded locale is applied before the first frame renders.
    expect(find.text('С возвращением'), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets('changing appearance on the auth screen persists', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Тема'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Светлая'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Язык'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Türkçe'));
    await tester.pumpAndSettle();

    // Writes are fire-and-forget; advance the test clock once so the
    // pending persistence futures complete (`Future.delayed` alone never
    // resolves inside the FakeAsync zone).
    await tester.pump();

    expect(prefs.getString('appearance.theme'), 'light');
    expect(prefs.getString('appearance.locale'), 'tr');
  });
}
