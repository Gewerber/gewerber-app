import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/guidance.dart';
import 'package:gewerber_app/domain/repositories/guidance_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/guidance_remote_data_source.dart';

/// Serverpod-backed [GuidanceRepository].
///
/// Serves the centrally curated guidance content and stores progress in the
/// user's server profile. Completions are one-way: the backend has no
/// "un-complete" operation, so [supportsUnmark] is `false`.
@LazySingleton(as: GuidanceRepository, env: [AppEnvironment.authLive])
class ServerpodGuidanceRepository implements GuidanceRepository {
  ServerpodGuidanceRepository(this._dataSource);

  final GuidanceRemoteDataSource _dataSource;

  @override
  bool get supportsUnmark => false;

  @override
  Future<List<GuidanceTip>> tips() {
    return _guard(() => _dataSource.tips());
  }

  @override
  Future<List<GuidanceChecklist>> checklists() {
    return _guard(() => _dataSource.checklists());
  }

  @override
  Future<Set<String>> completedItemKeys() {
    return _guard(() => _dataSource.completedItemKeys());
  }

  @override
  Future<void> markCompleted(String itemKey) {
    return _guard(() => _dataSource.markCompleted(itemKey));
  }

  @override
  Future<void> unmarkCompleted(String itemKey) {
    throw UnsupportedError('Server guidance progress cannot be reverted');
  }

  @override
  Future<void> dismissTip(String topic) {
    return _guard(() => _dataSource.dismissTip(topic));
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
