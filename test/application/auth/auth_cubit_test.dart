import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/auth/auth_state.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/user.dart';
import 'package:gewerber_app/domain/repositories/auth_repository.dart';
import 'package:gewerber_app/domain/value_objects/email.dart';
import 'package:gewerber_app/domain/value_objects/password.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';
import 'package:gewerber_app/domain/value_objects/verification_code.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.restoredUser,
    this.failLogin = false,
    this.failSocial = false,
    this.failLogOut = false,
  });

  final User? restoredUser;
  final bool failLogin;
  final bool failSocial;
  final bool failLogOut;

  @override
  Future<User?> restoreSession() async => restoredUser;

  @override
  Future<User> login({required Email email, required Password password}) async {
    if (failLogin) throw const InvalidCredentialsException();
    return User(id: '1', email: email.value);
  }

  @override
  Future<String> startRegistration({required Email email}) async =>
      'account-request';

  @override
  Future<String> verifyRegistrationCode({
    required String accountRequestId,
    required VerificationCode code,
  }) async => 'registration-token';

  @override
  Future<User> finishRegistration({
    required String registrationToken,
    required Password password,
  }) async => User(id: '1', email: 'test@gewerber.de');

  @override
  Future<String> startPasswordReset({required Email email}) async =>
      'reset-request';

  @override
  Future<String> verifyPasswordResetCode({
    required String passwordResetRequestId,
    required VerificationCode code,
  }) async => 'reset-token';

  @override
  Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required Password newPassword,
  }) async {}

  @override
  Future<User> socialLogin(SocialAuthProvider provider) async {
    if (failSocial) throw const SocialAuthNotConfiguredException();
    return User(id: '1', email: 'test@gewerber.de');
  }

  @override
  Future<void> logOut() async {
    if (failLogOut) throw const NetworkException();
  }
}

void main() {
  test('starts in the unknown state', () {
    final cubit = AuthCubit(_FakeAuthRepository());

    expect(cubit.state.status, AuthStatus.unknown);
  });

  test(
    'restoreSession without a saved session emits unauthenticated',
    () async {
      final cubit = AuthCubit(_FakeAuthRepository());

      await cubit.restoreSession();

      expect(cubit.state.status, AuthStatus.unauthenticated);
      expect(cubit.state.user, isNull);
    },
  );

  test('restoreSession with a saved session emits authenticated', () async {
    const user = User(id: '1', email: 'test@gewerber.de');
    final cubit = AuthCubit(_FakeAuthRepository(restoredUser: user));

    await cubit.restoreSession();

    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.user, user);
  });

  test('login succeeds and holds the returned user', () async {
    final cubit = AuthCubit(_FakeAuthRepository());

    await cubit.login(email: 'test@gewerber.de', password: 'password123');

    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.isSubmitting, isFalse);
    expect(cubit.state.user?.email, 'test@gewerber.de');
  });

  test('login with an invalid email emits a validation failure', () async {
    final cubit = AuthCubit(_FakeAuthRepository());

    await cubit.login(email: 'not-an-email', password: 'password123');

    expect(cubit.state.isAuthenticated, isFalse);
    expect(cubit.state.failure, isA<ValidationFailure>());
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('login with a short password emits a validation failure', () async {
    final cubit = AuthCubit(_FakeAuthRepository());

    await cubit.login(email: 'test@gewerber.de', password: 'short');

    expect(cubit.state.failure, isA<ValidationFailure>());
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('login with invalid credentials exposes a failure', () async {
    final cubit = AuthCubit(_FakeAuthRepository(failLogin: true));

    await cubit.login(email: 'test@gewerber.de', password: 'wrong-pass-1');

    expect(cubit.state.isAuthenticated, isFalse);
    expect(cubit.state.failure, isA<InvalidCredentialsFailure>());
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('login starts in a submitting state', () async {
    final cubit = AuthCubit(_FakeAuthRepository(failLogin: true));

    final submit = cubit.login(
      email: 'test@gewerber.de',
      password: 'xpass1234',
    );
    expect(cubit.state.isSubmitting, isTrue);
    await submit;
  });

  test('socialLogin succeeds and holds the returned user', () async {
    final cubit = AuthCubit(_FakeAuthRepository());

    await cubit.socialLogin(SocialAuthProvider.google);

    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('socialLogin failure is mapped to a failure', () async {
    final cubit = AuthCubit(_FakeAuthRepository(failSocial: true));

    await cubit.socialLogin(SocialAuthProvider.apple);

    expect(cubit.state.isAuthenticated, isFalse);
    expect(cubit.state.failure, isA<SocialAuthNotConfiguredFailure>());
  });

  test(
    'setAuthenticated marks the session without a repository call',
    () async {
      final cubit = AuthCubit(_FakeAuthRepository());

      cubit.setAuthenticated(const User(id: '1', email: 'test@gewerber.de'));

      expect(cubit.state.status, AuthStatus.authenticated);
      expect(cubit.state.user?.email, 'test@gewerber.de');
    },
  );

  test('logOut clears the session', () async {
    final cubit = AuthCubit(_FakeAuthRepository());

    await cubit.login(email: 'test@gewerber.de', password: 'password123');
    await cubit.logOut();

    expect(cubit.state.status, AuthStatus.unauthenticated);
    expect(cubit.state.user, isNull);
  });

  test('logOut still signs out when the backend is unreachable', () async {
    final cubit = AuthCubit(_FakeAuthRepository(failLogOut: true));

    await cubit.login(email: 'test@gewerber.de', password: 'password123');
    await cubit.logOut();

    expect(cubit.state.status, AuthStatus.unauthenticated);
    expect(cubit.state.user, isNull);
  });
}
