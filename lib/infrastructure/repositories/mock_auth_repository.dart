import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/user.dart';
import 'package:gewerber_app/domain/repositories/auth_repository.dart';
import 'package:gewerber_app/domain/value_objects/email.dart';
import 'package:gewerber_app/domain/value_objects/password.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';
import 'package:gewerber_app/domain/value_objects/verification_code.dart';

/// In-memory [AuthRepository] backing the demo experience and the widget
/// tests. Only the demo account can sign in; sessions are never persisted.
@LazySingleton(as: AuthRepository, env: [AppEnvironment.authMock])
class MockAuthRepository implements AuthRepository {
  /// The only account that exists in the demo backend.
  static const String demoEmail = 'demo@gewerber.de';
  static const String demoPassword = 'demo-password';

  @override
  Future<User?> restoreSession() async => null;

  @override
  Future<User> login({required Email email, required Password password}) async {
    if (email.value != demoEmail || password.value != demoPassword) {
      throw const InvalidCredentialsException();
    }
    return _demoUser(demoEmail);
  }

  @override
  Future<String> startRegistration({required Email email}) async =>
      'mock-account-request';

  @override
  Future<String> verifyRegistrationCode({
    required String accountRequestId,
    required VerificationCode code,
  }) async {
    if (code.value.isEmpty) {
      throw const InvalidVerificationCodeException();
    }
    return 'mock-registration-token';
  }

  @override
  Future<User> finishRegistration({
    required String registrationToken,
    required Password password,
  }) async => _demoUser('demo@gewerber.de');

  @override
  Future<String> startPasswordReset({required Email email}) async =>
      'mock-reset-request';

  @override
  Future<String> verifyPasswordResetCode({
    required String passwordResetRequestId,
    required VerificationCode code,
  }) async => 'mock-reset-token';

  @override
  Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required Password newPassword,
  }) async {}

  @override
  Future<User> socialLogin(SocialAuthProvider provider) async =>
      _demoUser('demo@gewerber.de');

  @override
  Future<void> logOut() async {}

  User _demoUser(String email) {
    return User(
      id: 'demo-user',
      email: email,
      displayName: email.split('@').first,
    );
  }
}
