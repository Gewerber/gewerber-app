import 'package:gewerber_app/domain/entities/user_preferences.dart';

/// Contract for reading and updating the signed-in user's preferences.
///
/// Implementations live in the infrastructure layer and must never leak
/// framework or transport details into the domain.
abstract interface class UserPreferencesRepository {
  /// Loads the current user's server-side preferences.
  ///
  /// Returns `null` when no profile exists yet.
  Future<UserPreferences?> getMyPreferences();

  /// Persists [preferences] on the user's profile.
  Future<void> update(UserPreferences preferences);
}
