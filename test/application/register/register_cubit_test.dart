import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/auth/auth_state.dart';
import 'package:gewerber_app/application/register/register_cubit.dart';
import 'package:gewerber_app/application/register/register_state.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/user.dart';
import 'package:gewerber_app/domain/repositories/auth_repository.dart';
import 'package:gewerber_app/domain/value_objects/email.dart';
import 'package:gewerber_app/domain/value_objects/password.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';
import 'package:gewerber_app/domain/value_objects/verification_code.dart';

class _FakeAuthRepository implements AuthRepository {
  bool emailTaken = false;

  @override
  Future<User?> restoreSession() async => null;

  @override
  Future<User> login({
    required Email email,
    required Password password,
  }) async => User(id: '1', email: email.value);

  @override
  Future<String> startRegistration({required Email email}) async {
    if (emailTaken) throw const EmailAlreadyRegisteredException();
    return 'account-request-1';
  }

  @override
  Future<String> verifyRegistrationCode({
    required String accountRequestId,
    required VerificationCode code,
  }) async => 'registration-token-1';

  @override
  Future<User> finishRegistration({
    required String registrationToken,
    required Password password,
  }) async => const User(id: '1', email: 'test@gewerber.de');

  @override
  Future<String> startPasswordReset({required Email email}) async =>
      'reset-request-1';

  @override
  Future<String> verifyPasswordResetCode({
    required String passwordResetRequestId,
    required VerificationCode code,
  }) async => 'reset-token-1';

  @override
  Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required Password newPassword,
  }) async {}

  @override
  Future<User> socialLogin(SocialAuthProvider provider) async =>
      const User(id: '1', email: 'test@gewerber.de');

  @override
  Future<void> logOut() async {}
}

void main() {
  late _FakeAuthRepository repository;
  late AuthCubit authCubit;
  late RegisterCubit cubit;

  setUp(() {
    repository = _FakeAuthRepository();
    authCubit = AuthCubit(repository);
    cubit = RegisterCubit(repository, authCubit);
  });

  test('starts on the email step', () {
    expect(cubit.state.step, RegisterStep.email);
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('submitEmail advances to the code step and stores the email', () async {
    await cubit.submitEmail('test@gewerber.de');

    expect(cubit.state.step, RegisterStep.code);
    expect(cubit.state.email, 'test@gewerber.de');
    expect(cubit.state.isSubmitting, isFalse);
  });

  test(
    'submitEmail with an invalid address emits a validation failure',
    () async {
      await cubit.submitEmail('not-an-email');

      expect(cubit.state.step, RegisterStep.email);
      expect(cubit.state.failure, isA<ValidationFailure>());
    },
  );

  test('submitEmail with a taken address emits a failure', () async {
    repository.emailTaken = true;

    await cubit.submitEmail('test@gewerber.de');

    expect(cubit.state.step, RegisterStep.email);
    expect(cubit.state.failure, isA<EmailAlreadyRegisteredFailure>());
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('submitCode advances to the password step', () async {
    await cubit.submitEmail('test@gewerber.de');
    await cubit.submitCode('123456');

    expect(cubit.state.step, RegisterStep.password);
    expect(cubit.state.isSubmitting, isFalse);
  });

  test('submitCode with a malformed code emits a validation failure', () async {
    await cubit.submitEmail('test@gewerber.de');
    await cubit.submitCode('12');

    expect(cubit.state.step, RegisterStep.code);
    expect(cubit.state.failure, isA<ValidationFailure>());
  });

  test('submitPassword completes and authenticates the session', () async {
    await cubit.submitEmail('test@gewerber.de');
    await cubit.submitCode('123456');
    await cubit.submitPassword('password123');

    expect(cubit.state.step, RegisterStep.completed);
    expect(cubit.state.isSubmitting, isFalse);
    expect(authCubit.state.status, AuthStatus.authenticated);
    expect(authCubit.state.user?.email, 'test@gewerber.de');
  });

  test(
    'submitPassword with a short password emits a validation failure',
    () async {
      await cubit.submitEmail('test@gewerber.de');
      await cubit.submitCode('123456');
      await cubit.submitPassword('short');

      expect(cubit.state.step, RegisterStep.password);
      expect(cubit.state.failure, isA<ValidationFailure>());
      expect(authCubit.state.status, isNot(AuthStatus.authenticated));
    },
  );

  test('goBack steps backwards and is a no-op on the first step', () async {
    cubit.goBack();
    expect(cubit.state.step, RegisterStep.email);

    await cubit.submitEmail('test@gewerber.de');
    expect(cubit.state.step, RegisterStep.code);

    cubit.goBack();
    expect(cubit.state.step, RegisterStep.email);
  });

  test('reset restores the initial state', () async {
    await cubit.submitEmail('test@gewerber.de');

    cubit.reset();

    expect(cubit.state, RegisterState.initial);
  });
}
