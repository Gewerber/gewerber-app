import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/domain/entities/user_preferences.dart';

@LazySingleton(env: [AppEnvironment.authLive])
class BetaBannerPreferencesRepository {
  /// Creates a repository over an already-loaded [SharedPreferences]
  /// instance. The [SharedPreferences] instance should be warmed before
  /// DI setup (see [bootstrap.dart]) so this repository can read and write
  /// synchronously if needed.
  const BetaBannerPreferencesRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _betaBannerDismissedKey = 'appearance.betaBannerDismissed';

  /// Checks whether the beta banner has been dismissed by the user.
  /// Returns `true` when the banner has been dismissed, `false` otherwise.
  bool isDismissed() => _prefs.getBool(_betaBannerDismissedKey) ?? false;

  /// Marks the beta banner as dismissed by the user.
  /// This will store the dismissal state locally and persist it across
  /// app restarts. Future app sessions will not show the banner.
  Future<void> markDismissed() => _prefs.setBool(_betaBannerDismissedKey, true);

  /// Resets the beta banner dismissal state.
  /// This is primarily useful for testing or if you want to show the
  /// banner again after it has been dismissed.
  Future<void> resetDismissed() => _prefs.remove(_betaBannerDismissedKey);
}

/// Domain interface for beta banner preferences.
abstract interface class BetaBannerPreferences {
  /// Checks whether the beta banner has been dismissed by the user.
  bool isDismissed();

  /// Marks the beta banner as dismissed by the user.
  Future<void> markDismissed();

  /// Resets the beta banner dismissal state.
  Future<void> resetDismissed();
}
