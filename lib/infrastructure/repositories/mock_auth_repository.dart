import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/user.dart';
import 'package:gewerber_app/domain/repositories/auth_repository.dart';

/// In-memory [AuthRepository] used until the Serverpod backend client is
/// wired in. Accepts any non-empty credentials and never persists sessions.
@LazySingleton(as: AuthRepository)
class MockAuthRepository implements AuthRepository {
  @override
  Future<User?> restoreSession() async => null;

  @override
  Future<User> login({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      throw const InvalidCredentialsException();
    }
    return User(
      id: 'demo-user',
      email: email,
      displayName: email.split('@').first,
    );
  }

  @override
  Future<void> logOut() async {}
}
