import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/auth/auth_state.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/user.dart';
import 'package:gewerber_app/domain/repositories/auth_repository.dart';
import 'package:gewerber_app/domain/value_objects/email.dart';
import 'package:gewerber_app/domain/value_objects/password.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';
import 'package:gewerber_app/domain/value_objects/verification_code.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/auth/widgets/social_sign_in_row.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<User?> restoreSession() async => null;

  @override
  Future<User> login({
    required Email email,
    required Password password,
  }) async => User(id: '1', email: email.value);

  @override
  Future<String> startRegistration({required Email email}) async => 'request';

  @override
  Future<String> verifyRegistrationCode({
    required String accountRequestId,
    required VerificationCode code,
  }) async => 'token';

  @override
  Future<User> finishRegistration({
    required String registrationToken,
    required Password password,
  }) async => User(id: '1', email: 'demo@gewerber.de');

  @override
  Future<String> startPasswordReset({required Email email}) async => 'request';

  @override
  Future<String> verifyPasswordResetCode({
    required String passwordResetRequestId,
    required VerificationCode code,
  }) async => 'token';

  @override
  Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required Password newPassword,
  }) async {}

  @override
  Future<User> socialLogin(SocialAuthProvider provider) async =>
      User(id: '1', email: 'demo@gewerber.de');

  @override
  Future<void> logOut() async {}
}

/// A cubit whose failure can be injected so the listener behaviour can be
/// asserted.
class _ControllableAuthCubit extends AuthCubit {
  _ControllableAuthCubit(super.repository);

  void emitFailure(Failure? failure) {
    emit(state.copyWith(failure: failure, clearSubmittingProvider: true));
  }
}

void main() {
  const configured = {
    'googleClientId': 'google',
    'appleClientId': 'apple',
    'facebookAppId': 'facebook',
    'microsoftClientId': 'microsoft',
    'appleRedirectUri': 'https://app.gewerber.de/auth/callback',
  };

  setUp(() {
    FlavorConfig(name: null, variables: configured);
  });

  tearDown(() {
    FlavorConfig(name: null, variables: const {});
  });

  Future<_ControllableAuthCubit> pumpRow(
    WidgetTester tester, {
    AuthState? initialState,
  }) async {
    final cubit = _ControllableAuthCubit(_FakeAuthRepository());
    if (initialState != null) {
      cubit.emit(initialState);
    }
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: cubit,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(child: SocialSignInRow()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('renders a button for every configured provider', (tester) async {
    // iOS is the only platform all four flows support.
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    await pumpRow(tester);

    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Facebook'), findsOneWidget);
    expect(find.text('Microsoft'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNWidgets(4));
  });

  testWidgets('hides a provider without credentials', (tester) async {
    FlavorConfig(
      name: null,
      variables: const {
        'googleClientId': 'google',
        // Apple, Facebook and Microsoft are left unconfigured.
      },
    );

    await pumpRow(tester);

    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);
    expect(find.text('Facebook'), findsNothing);
    expect(find.text('Microsoft'), findsNothing);
  });

  testWidgets('hides a provider unsupported on this platform', (tester) async {
    // The default test host is Android: Apple has no native flow there, the
    // others do.
    await pumpRow(tester);

    expect(find.text('Apple'), findsNothing);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Facebook'), findsOneWidget);
    expect(find.text('Microsoft'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNWidgets(3));
  });

  testWidgets('offers no buttons and no divider when nothing is configured', (
    tester,
  ) async {
    FlavorConfig(name: null, variables: const {});

    await pumpRow(tester);

    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.text('or continue with'), findsNothing);
  });

  testWidgets('never shows a "coming soon" notice', (tester) async {
    await pumpRow(tester);

    expect(find.textContaining('coming soon'), findsNothing);
    expect(find.textContaining('bald verfügbar'), findsNothing);
  });

  testWidgets('shows the unavailable message for a disabled provider', (
    tester,
  ) async {
    final cubit = await pumpRow(tester);

    cubit.emitFailure(const SocialAuthNotConfiguredFailure());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('This sign-in option is unavailable.'), findsOneWidget);
  });

  testWidgets('stays silent when the user cancels the provider sheet', (
    tester,
  ) async {
    final cubit = await pumpRow(tester);

    cubit.emitFailure(const SocialAuthCancelledFailure());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(SnackBar), findsNothing);
  });
}
