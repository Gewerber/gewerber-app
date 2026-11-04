import 'package:gewerber_app/infrastructure/datasources/local/beta_banner_preferences_store.dart';

/// Domain interface for beta banner preferences.
abstract interface class BetaBannerPreferences {
  /// Checks whether the beta banner has been dismissed by the user.
  bool isDismissed();

  /// Marks the beta banner as dismissed by the user.
  Future<void> markDismissed();

  /// Resets the beta banner dismissal state.
  Future<void> resetDismissed();
}

/// Type alias for the implementation of [BetaBannerPreferences].
typedef BetaBannerPreferencesImpl = SharedPreferencesBetaBannerRepository;

/// Implementation of [BetaBannerPreferences] using SharedPreferences.
class SharedPreferencesBetaBannerRepository implements BetaBannerPreferences {
  /// Creates a repository over an already-loaded [SharedPreferences]
  /// instance.
  const SharedPreferencesBetaBannerRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _betaBannerDismissedKey = 'appearance.betaBannerDismissed';

  @override
  bool isDismissed() => _prefs.getBool(_betaBannerDismissedKey) ?? false;

  @override
  Future<void> markDismissed() => _prefs.setBool(_betaBannerDismissedKey, true);

  @override
  Future<void> resetDismissed() => _prefs.remove(_betaBannerDismissedKey);
}
