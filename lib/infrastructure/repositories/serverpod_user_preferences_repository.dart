import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/user_preferences.dart';
import 'package:gewerber_app/domain/repositories/user_preferences_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/user_preferences_remote_data_source.dart';

/// Serverpod-backed [UserPreferencesRepository].
@LazySingleton(as: UserPreferencesRepository, env: [AppEnvironment.authLive])
class ServerpodUserPreferencesRepository implements UserPreferencesRepository {
  ServerpodUserPreferencesRepository(this._dataSource);

  final UserPreferencesRemoteDataSource _dataSource;

  @override
  Future<UserPreferences?> getMyPreferences() {
    return _guard(() => _dataSource.getMyPreferences());
  }

  @override
  Future<void> update(UserPreferences preferences) {
    return _guard(() => _dataSource.update(preferences));
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
}
