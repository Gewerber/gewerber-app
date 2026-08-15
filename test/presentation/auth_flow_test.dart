import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/auth/login_screen.dart';
import 'package:gewerber_app/presentation/screens/auth/register_screen.dart';
import 'package:gewerber_app/presentation/screens/home/dashboard_screen.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';

void main() {
  setUpAll(configureDependencies);

  Future<void> pumpAtLogin(WidgetTester tester) async {
    appRouter.go(RouteNames.splash);
    await tester.pumpWidget(const GewerberApp());
    await tester.pumpAndSettle();
  }

  testWidgets('register screen renders without layout overflow', (
    tester,
  ) async {
    await pumpAtLogin(tester);

    appRouter.go(RouteNames.register);
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login with an unregistered account stays on the login screen', (
    tester,
  ) async {
    await pumpAtLogin(tester);

    await tester.enterText(
      find.byType(CustomTextField).at(0),
      'someone@gewerber.de',
    );
    await tester.enterText(find.byType(CustomTextField).at(1), 'password123');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);
    expect(
      find.text(
        'The email address or password is incorrect. Please try again.',
      ),
      findsOneWidget,
    );
  });
}
