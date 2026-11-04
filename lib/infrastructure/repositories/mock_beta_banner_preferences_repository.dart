import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/domain/repositories/beta_banner_preferences_repository.dart';

/// Mock implementation of [BetaBannerPreferencesRepository] for testing.
///
/// This implementation uses in-memory state and is designed for widget tests
/// and development environments where local persistence is not required.
@LazySingleton(as: BetaBannerPreferences, env: [AppEnvironment.authMock])
class MockBetaBannerPreferencesRepository implements BetaBannerPreferences {
  /// In-memory storage for beta banner dismissal state.
  bool _isDismissed = false;

  @override
  bool isDismissed() => _isDismissed;

  @override
  Future<void> markDismissed() async {
    _isDismissed = true;
  }

  /// Resets the dismissal state to false (primarily for testing).
  Future<void> resetDismissed() async {
    _isDismissed = false;
  }
}

/// Serverpod implementation of [BetaBannerPreferences] for production.
///
/// This implementation uses the backend to sync beta banner dismissal state
/// across all user sessions and devices.
@injectable
class ServerpodBetaBannerPreferencesRepository
    implements BetaBannerPreferences {
  /// Creates a new serverpod repository.
  ///
  /// [repository] provides the remote data source for beta banner preferences.
  ServerpodBetaBannerPreferencesRepository(this._repository);

  final BetaBannerPreferencesImpl _repository;

  @override
  bool isDismissed() => _repository.isDismissed();

  @override
  Future<void> markDismissed() => _repository.markDismissed();

  @override
  Future<void> resetDismissed() => _repository.resetDismissed();
}
