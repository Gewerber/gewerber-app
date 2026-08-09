import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/auth/auth_state.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/user.dart';
import 'package:gewerber_app/domain/repositories/auth_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.restoredUser, this.failLogin = false});

  final User? restoredUser;
  final bool failLogin;

  @override
  Future<User?> restoreSession() async => restoredUser;

  @override
  Future<User> login({required String email, required String password}) async {
    if (failLogin) throw const InvalidCredentialsException();
    return User(id: '1', email: email);
  }

  @override
  Future<void> logOut() async {}
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

    await cubit.login(email: 'test@gewerber.de', password: 'secret');

    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.isSubmitting, isFalse);
    expect(cubit.state.user?.email, 'test@gewerber.de');
  });

  test('login with invalid credentials exposes a failure', () async {
    final cubit = AuthCubit(_FakeAuthRepository(failLogin: true));

    await cubit.login(email: 'test@gewerber.de', password: 'wrong');

    expect(cubit.state.isAuthenticated, isFalse);
    expect(cubit.state.failure, isA<InvalidCredentialsFailure>());
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('login starts in a submitting state', () async {
    final cubit = AuthCubit(_FakeAuthRepository(failLogin: true));

    final submit = cubit.login(email: 'test@gewerber.de', password: 'x');
    expect(cubit.state.isSubmitting, isTrue);
    await submit;
  });

  test('logOut clears the session', () async {
    final cubit = AuthCubit(_FakeAuthRepository());

    await cubit.login(email: 'test@gewerber.de', password: 'secret');
    await cubit.logOut();

    expect(cubit.state.status, AuthStatus.unauthenticated);
    expect(cubit.state.user, isNull);
  });
}
