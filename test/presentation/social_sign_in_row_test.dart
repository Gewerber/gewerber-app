import 'dart:async';

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
import 'package:gewerber_app/infrastructure/datasources/remote/social_auth_remote_data_source.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/auth/widgets/social_sign_in_row.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository();

  /// Providers [socialLogin] was called with, in order.
  /// Providers [socialLogin] was called with, in order.
  final List<SocialAuthProvider> socialLogins = [];

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
  Future<User> socialLogin(SocialAuthProvider provider) async {
    socialLogins.add(provider);
    return User(id: '1', email: 'demo@gewerber.de');
  }

  @override
  Future<void> logOut() async {}
}

/// Data source whose per-provider answer is scripted, so the row can be
/// exercised without `AppConfig`.
class _FakeSocialDataSource extends SocialAuthRemoteDataSource {
  _FakeSocialDataSource(this.configured);

  final Set<SocialAuthProvider> configured;

  /// Every configured provider, in the order it was asked about.
  final List<SocialAuthProvider> resolved = [];

  @override
  Future<bool> isConfigured(SocialAuthProvider provider) async {
    resolved.add(provider);
    return configured.contains(provider);
  }
}

/// A data source whose configuration answer never completes.
class _PendingSocialDataSource extends SocialAuthRemoteDataSource {
  const _PendingSocialDataSource();

  @override
  Future<bool> isConfigured(SocialAuthProvider provider) =>
      Completer<bool>().future;
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

  Future<({_ControllableAuthCubit cubit, _FakeAuthRepository repository})>
  pumpRow(
    WidgetTester tester, {
    AuthState? initialState,
    Set<SocialAuthProvider> configured = const {
      SocialAuthProvider.google,
      SocialAuthProvider.apple,
      SocialAuthProvider.facebook,
      SocialAuthProvider.microsoft,
    },
  }) async {
    final repository = _FakeAuthRepository();
    final cubit = _ControllableAuthCubit(repository);
    if (initialState != null) {
      cubit.emit(initialState);
    }
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: cubit,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: SocialSignInRow(
                dataSource: _FakeSocialDataSource(configured),
              ),
            ),
          ),
        ),
      ),
    );
    // `pumpAndSettle` drains the microtask the configuration lookup resolves
    // in, so the row has its answer before the assertions run.
    await tester.pumpAndSettle();
    return (cubit: cubit, repository: repository);
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
    await pumpRow(tester, configured: const {SocialAuthProvider.google});

    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);
    expect(find.text('Facebook'), findsNothing);
    expect(find.text('Microsoft'), findsNothing);
  });

  testWidgets('hides a provider the flow reports as not configured', (
    tester,
  ) async {
    // The flow is the single source of truth: a provider missing a
    // platform-specific credential (here: the Google iOS client id) is not
    // offered, even though its client id is present.
    await pumpRow(
      tester,
      configured: const {
        SocialAuthProvider.apple,
        SocialAuthProvider.facebook,
        SocialAuthProvider.microsoft,
      },
    );

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Google'), findsNothing);
    expect(find.text('Facebook'), findsOneWidget);
    expect(find.text('Microsoft'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNWidgets(3));
  });

  testWidgets('re-resolves when the data source changes', (tester) async {
    final first = _FakeSocialDataSource(const {SocialAuthProvider.google});
    final second = _FakeSocialDataSource(const {SocialAuthProvider.apple});
    final cubit = _ControllableAuthCubit(_FakeAuthRepository());
    addTearDown(cubit.close);

    Future<void> pumpWith(SocialAuthRemoteDataSource dataSource) async {
      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: cubit,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: SocialSignInRow(dataSource: dataSource),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpWith(first);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);

    await pumpWith(second);
    expect(first.resolved, hasLength(4));
    expect(second.resolved, hasLength(4));
    expect(find.text('Google'), findsNothing);
    expect(find.text('Apple'), findsOneWidget);
  });

  testWidgets('renders nothing until the configuration is resolved', (
    tester,
  ) async {
    // A data source whose answer never arrives: the row must stay empty
    // instead of guessing (and offering a provider that then always fails).
    final cubit = _ControllableAuthCubit(_FakeAuthRepository());
    addTearDown(cubit.close);
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: cubit,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: SocialSignInRow(dataSource: _PendingSocialDataSource()),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(OutlinedButton), findsNothing);
    expect(find.text('or continue with'), findsNothing);
  });

  testWidgets('offers no buttons and no divider when nothing is configured', (
    tester,
  ) async {
    await pumpRow(tester, configured: const {});

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
    final (cubit: cubit, :repository) = await pumpRow(tester);

    cubit.emitFailure(const SocialAuthNotConfiguredFailure());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('This sign-in option is unavailable.'), findsOneWidget);
  });

  testWidgets('shows a generic message and hides the provider detail', (
    tester,
  ) async {
    final (cubit: cubit, :repository) = await pumpRow(tester);

    cubit.emitFailure(
      const SocialAuthFailure('GoogleIdTokenVerificationException: bad token'),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      find.text("We couldn't complete that sign-in. Please try again."),
      findsOneWidget,
    );
    expect(
      find.textContaining('GoogleIdTokenVerificationException'),
      findsNothing,
    );
  });

  testWidgets('tapping a provider button signs in with that provider', (
    tester,
  ) async {
    final (:cubit, :repository) = await pumpRow(tester);
    addTearDown(cubit.close);

    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();

    expect(repository.socialLogins, [SocialAuthProvider.apple]);
  });

  testWidgets('stays silent when the user cancels the provider sheet', (
    tester,
  ) async {
    final (cubit: cubit, :repository) = await pumpRow(tester);

    cubit.emitFailure(const SocialAuthCancelledFailure());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(SnackBar), findsNothing);
  });
}
