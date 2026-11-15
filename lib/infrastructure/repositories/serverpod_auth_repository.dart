import 'package:injectable/injectable.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/user.dart';
import 'package:gewerber_app/domain/repositories/auth_repository.dart';
import 'package:gewerber_app/domain/value_objects/email.dart';
import 'package:gewerber_app/domain/value_objects/password.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';
import 'package:gewerber_app/domain/value_objects/verification_code.dart';
import 'package:gewerber_app/infrastructure/datasources/local/session_store.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/auth_remote_data_source.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social_auth_remote_data_source.dart';
import 'package:gewerber_app/infrastructure/mappers/user_mapper.dart';

/// Serverpod-backed [AuthRepository].
///
/// Combines the transport [AuthRemoteDataSource] with the local
/// [SessionStore] and translates [AppException]s into domain failures via
/// `core/errors/error_handler.dart`.
@LazySingleton(as: AuthRepository, env: [AppEnvironment.authLive])
class ServerpodAuthRepository implements AuthRepository {
  ServerpodAuthRepository(
    this._dataSource,
    this._socialDataSource,
    this._sessionStore,
    this._userMapper,
  );

  final AuthRemoteDataSource _dataSource;
  final SocialAuthRemoteDataSource _socialDataSource;
  final SessionStore _sessionStore;
  final UserMapper _userMapper;

  @override
  Future<User> login({required Email email, required Password password}) {
    return _guard(() async {
      final success = await _dataSource.login(
        email: email.value,
        password: password.value,
      );
      final user = _userMapper.fromAuthSuccess(success, email.value);
      await _sessionStore.writeUser(user);
      return user;
    });
  }

  @override
  Future<String> startRegistration({required Email email}) {
    return _guard(() async {
      final id = await _dataSource.startRegistration(email: email.value);
      return id.toString();
    });
  }

  @override
  Future<String> verifyRegistrationCode({
    required String accountRequestId,
    required VerificationCode code,
  }) {
    return _guard(
      () => _dataSource.verifyRegistrationCode(
        accountRequestId: _uuid(accountRequestId),
        code: code.value,
      ),
    );
  }

  @override
  Future<User> finishRegistration({
    required String registrationToken,
    required Password password,
  }) {
    return _guard(() async {
      final success = await _dataSource.finishRegistration(
        registrationToken: registrationToken,
        password: password.value,
      );
      // The user just registered with an email address; the backend is the
      // authority on the stored address, so ask for it instead of echoing the
      // local input (which may differ in case or trimming).
      final email = await _dataSource.resolvePrimaryEmail();
      final user = _userMapper.fromAuthSuccess(success, email ?? '');
      await _sessionStore.writeUser(user);
      return user;
    });
  }

  @override
  Future<String> startPasswordReset({required Email email}) {
    return _guard(() async {
      final id = await _dataSource.startPasswordReset(email: email.value);
      return id.toString();
    });
  }

  @override
  Future<String> verifyPasswordResetCode({
    required String passwordResetRequestId,
    required VerificationCode code,
  }) {
    return _guard(
      () => _dataSource.verifyPasswordResetCode(
        passwordResetRequestId: _uuid(passwordResetRequestId),
        code: code.value,
      ),
    );
  }

  @override
  Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required Password newPassword,
  }) {
    return _guard(
      () => _dataSource.finishPasswordReset(
        finishPasswordResetToken: finishPasswordResetToken,
        newPassword: newPassword.value,
      ),
    );
  }

  @override
  Future<User> socialLogin(SocialAuthProvider provider) {
    return _guard(() async {
      final credential = await _socialDataSource.signIn(provider);
      final result = await _dataSource.socialLogin(credential);
      final user = _userMapper.fromSocialAuth(
        authSuccess: result.success,
        primaryEmail: result.primaryEmail,
      );
      await _sessionStore.writeUser(user);
      return user;
    });
  }

  @override
  Future<User?> restoreSession() async {
    try {
      // A session restore must not fail because the profile read does: the
      // session manager already holds a valid session at this point.
      final email = await _dataSource.resolvePrimaryEmail();
      final success = await _dataSource.restoreSession();
      if (success == null) {
        await _sessionStore.clear();
        return null;
      }
      final stored = await _sessionStore.readUser();
      if (stored != null) {
        if (stored.email.isNotEmpty || email == null || email.isEmpty) {
          // A stored address wins; an unknown address never replaces one.
          return stored;
        }
        // The stored snapshot has no address: a previous sign-in resolved the
        // session while `userProfile.me()` was failing, so the empty address
        // was persisted. Repair it with the address we just read.
        final repaired = User(
          id: stored.id,
          email: email,
          displayName: stored.displayName,
        );
        await _sessionStore.writeUser(repaired);
        return repaired;
      }
      // No local snapshot (fresh install or cleared storage): the address has
      // to come from the backend, it is not part of the session token.
      final user = _userMapper.fromAuthSuccess(success, email ?? '');
      await _sessionStore.writeUser(user);
      return user;
    } on AppException {
      return null;
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await _dataSource.signOut();
    } catch (_) {
      // Best-effort: revoking the device session on the server is nice-to-have.
      // The local session is always cleared below so the user can sign out
      // even when the backend is unreachable.
    }
    await _sessionStore.clear();
  }

  /// Runs [action] and rethrows [AppException]s, wrapping any other error as
  /// a [NetworkException].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  UuidValue _uuid(String value) => UuidValue.fromString(value);
}
