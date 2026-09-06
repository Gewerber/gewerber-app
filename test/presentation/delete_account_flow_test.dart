import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/auth/auth_state.dart';
import 'package:gewerber_app/application/settings/app_settings_cubit.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/domain/repositories/user_preferences_repository.dart';
import 'package:gewerber_app/domain/repositories/user_profile_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_auth_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_user_preferences_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_user_profile_repository.dart';
import 'package:gewerber_app/presentation/app/gewerber_app.dart';
import 'package:gewerber_app/presentation/router/app_router.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/auth/login_screen.dart';
import 'package:gewerber_app/presentation/screens/home/dashboard_screen.dart';
import 'package:gewerber_app/presentation/screens/home/settings_master_detail.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/delete_account_dialog.dart';
import 'package:gewerber_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';

void main() {
  setUpAll(configureDependencies);

  MockUserProfileRepository mockUserProfile() =>
      getIt<UserProfileRepository>() as MockUserProfileRepository;

  Future<void> signIn(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // The auth/profile/preferences cubits and their mock backends are
    // singletons; start from the initial state so tests do not inherit data
    // from an earlier scenario.
    getIt<AppSettingsCubit>().reset();
    getIt<AuthCubit>().reset();
    mockUserProfile().reset();
    (getIt<UserPreferencesRepository>() as MockUserPreferencesRepository)
        .reset();

    appRouter.go(RouteNames.splash);
    await tester.pumpWidget(const GewerberApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(CustomTextField).at(0),
      MockAuthRepository.demoEmail,
    );
    await tester.enterText(
      find.byType(CustomTextField).at(1),
      MockAuthRepository.demoPassword,
    );
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    // New accounts without a business land on onboarding; create one to
    // reach the shell.
    if (find.byType(OnboardingScreen).evaluate().isNotEmpty) {
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Demo GmbH');
      final createButton = find.text('Create business');
      await tester.ensureVisible(createButton);
      await tester.pumpAndSettle();
      await tester.tap(createButton);
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsMasterDetail), findsOneWidget);
  }

  testWidgets('delete account entry opens an irreversible warning dialog', (
    tester,
  ) async {
    await signIn(tester);

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    expect(find.byType(DeleteAccountConfirmDialog), findsOneWidget);
    // Explicit irreversibility warning plus the concrete consequences.
    expect(find.text('Delete your account?'), findsOneWidget);
    expect(
      find.text(
        'This permanently deletes your account. '
        'This action cannot be undone.',
      ),
      findsOneWidget,
    );
    expect(find.text('Your personal data will be anonymized.'), findsOneWidget);
    expect(mockUserProfile().isDeleted, isFalse);
  });

  testWidgets('cancel closes the dialog and keeps the user signed in', (
    tester,
  ) async {
    await signIn(tester);

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(DeleteAccountConfirmDialog), findsNothing);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(SettingsMasterDetail), findsOneWidget);
    expect(mockUserProfile().isDeleted, isFalse);
  });

  testWidgets('confirming deletes the account and signs out', (tester) async {
    await signIn(tester);

    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete permanently'));
    await tester.pumpAndSettle();

    expect(mockUserProfile().isDeleted, isTrue);
    expect(getIt<AuthCubit>().state.status, AuthStatus.unauthenticated);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);
  });

  testWidgets('a deleted account triggers the notice and sign-out works', (
    tester,
  ) async {
    await signIn(tester);

    // Simulate the backend state after a deletion (e.g. from another device):
    // every profile request now reports the deleted account.
    await mockUserProfile().deleteAccount();

    // Opening the profile loads it and must surface the blocking notice.
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Account deleted'), findsOneWidget);
    expect(
      find.text(
        'This account has been deleted and its personal data '
        'has been anonymized.',
      ),
      findsOneWidget,
    );

    // The single action signs the user out and returns to the login screen.
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Sign out'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(getIt<AuthCubit>().state.status, AuthStatus.unauthenticated);
  });
}
