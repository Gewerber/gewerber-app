import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/domain/entities/user_preferences.dart';
import 'package:gewerber_app/domain/repositories/user_preferences_repository.dart';

/// In-memory [UserPreferencesRepository] backing the demo experience and the
/// widget tests. Settings live for the app session only.
@LazySingleton(as: UserPreferencesRepository, env: [AppEnvironment.authMock])
class MockUserPreferencesRepository implements UserPreferencesRepository {
  UserPreferences? _preferences;

  @override
  Future<UserPreferences?> getMyPreferences() async => _preferences;

  @override
  Future<void> update(UserPreferences preferences) async {
    _preferences = preferences;
  }

  /// Forgets the stored preferences. Used by tests to isolate scenarios.
  void reset() {
    _preferences = null;
  }
}
