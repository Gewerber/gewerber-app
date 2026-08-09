import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/user.dart';

/// Contract for authentication operations used by the application layer.
///
/// Implementations live in the infrastructure layer and must never leak
/// framework or transport details into the domain.
abstract interface class AuthRepository {
  /// Signs the user in with email and password.
  Future<User> login({required String email, required String password});

  /// Restores a previously persisted session, or `null` when no session
  /// exists (first launch, signed out or expired).
  Future<User?> restoreSession();

  /// Logs the current user out.
  Future<void> logOut();
}

/// Represents the outcome of an authentication attempt.
sealed class AuthResult {
  const AuthResult();
}

class AuthSuccess extends AuthResult {
  const AuthSuccess(this.user);

  final User user;
}

class AuthFailed extends AuthResult {
  const AuthFailed(this.failure);

  final Failure failure;
}
