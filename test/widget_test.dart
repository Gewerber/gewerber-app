import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/screens/auth/login_screen.dart';
import 'package:gewerber_app/presentation/screens/splash/splash_screen.dart';

void main() {
  setUpAll(configureDependencies);

  testWidgets('Signed-out user is redirected from splash to login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GewerberApp());
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
