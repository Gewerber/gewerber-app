import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/about_screen.dart';
import 'package:gewerber_app/presentation/screens/home/settings_master_detail.dart';

import 'golden_test_helper.dart';

/// Golden tests for the settings hub and the about screen — both are static
/// screens without wall-clock or platform-plugin input, so they are trivially
/// pumpable through the standard mock-DI boot path.
void main() {
  setUpAll(() {
    configureDependencies();
    configureGoldenEnvironment();
  });

  testWidgets('settings master-detail — phone layout (list)', (tester) async {
    await pumpAuthenticatedApp(tester, size: goldenPhoneSize);

    appRouter.go(RouteNames.settings);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsMasterDetail), findsOneWidget);
    await expectLater(
      find.byType(GewerberApp),
      matchesGoldenFile('settings_phone_390x844.png'),
    );
  });

  testWidgets('settings master-detail — wide layout (two panes, >= 600)', (
    tester,
  ) async {
    await pumpAuthenticatedApp(tester, size: goldenWideSize);

    appRouter.go(RouteNames.settings);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsMasterDetail), findsOneWidget);
    await expectLater(
      find.byType(GewerberApp),
      matchesGoldenFile('settings_wide_900x1280.png'),
    );
  });

  testWidgets('about screen — phone layout', (tester) async {
    await pumpAuthenticatedApp(tester, size: goldenPhoneSize);

    appRouter.go(RouteNames.settingsAbout);
    await tester.pumpAndSettle();

    expect(find.byType(AboutScreen), findsOneWidget);
    await expectLater(
      find.byType(GewerberApp),
      matchesGoldenFile('about_phone_390x844.png'),
    );
  });
}
