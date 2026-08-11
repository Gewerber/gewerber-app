import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/settings/app_settings_cubit.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/auth/login_screen.dart';

void main() {
  setUpAll(configureDependencies);

  Future<AppSettingsCubit> pumpApp(WidgetTester tester) async {
    appRouter.go(RouteNames.splash);
    await tester.pumpWidget(const GewerberApp());
    await tester.pumpAndSettle();

    final element = tester.element(find.byType(LoginScreen));
    return BlocProvider.of<AppSettingsCubit>(element);
  }

  testWidgets('changing the locale updates the app globally', (tester) async {
    final cubit = await pumpApp(tester);

    expect(find.text('Welcome back'), findsOneWidget);

    cubit.setLocale(const Locale('ru'));
    await tester.pumpAndSettle();

    expect(find.text('С возвращением'), findsOneWidget);
  });

  testWidgets('changing the theme mode updates the app globally', (
    tester,
  ) async {
    final cubit = await pumpApp(tester);

    Brightness brightness() {
      final element = tester.element(find.byType(LoginScreen));
      return Theme.of(element).brightness;
    }

    expect(brightness(), Brightness.light);

    cubit.setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();

    expect(brightness(), Brightness.dark);

    cubit.setThemeMode(ThemeMode.system);
    await tester.pumpAndSettle();

    expect(brightness(), Brightness.light);
  });
}
