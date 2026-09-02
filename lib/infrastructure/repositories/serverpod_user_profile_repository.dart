import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/my_identity.dart';
import 'package:gewerber_app/domain/entities/user_profile.dart';
import 'package:gewerber_app/domain/repositories/user_profile_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/user_profile_remote_data_source.dart';

/// Serverpod-backed [UserProfileRepository].
@LazySingleton(as: UserProfileRepository, env: [AppEnvironment.authLive])
class ServerpodUserProfileRepository implements UserProfileRepository {
  ServerpodUserProfileRepository(this._dataSource);

  final UserProfileRemoteDataSource _dataSource;

  @override
  Future<UserProfile> get() => _guard(_dataSource.get);

  @override
  Future<MyIdentity> me() => _guard(_dataSource.me);

  @override
  Future<UserProfile> updateDisplayName(String? displayName) =>
      _guard(() => _dataSource.updateDisplayName(displayName));

  @override
  Future<List<int>> exportMyData() => _guard(_dataSource.exportMyData);

  @override
  Future<void> deleteAccount() => _guard(_dataSource.deleteAccount);

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
}
