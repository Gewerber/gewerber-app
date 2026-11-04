import 'package:shared_preferences/shared_preferences.dart';

import 'package:gewerber_app/domain/repositories/beta_banner_preferences_repository.dart';

/// [SharedPreferences]-backed beta banner dismissal store.
///
/// `bootstrap` warms the plugin cache before DI setup, so the cubit can read
/// the persisted dismissal synchronously.
class SharedPreferencesBetaBannerPreferencesRepository
    implements BetaBannerPreferencesRepository {
  /// Creates a repository over an already-loaded [SharedPreferences] instance.
  const SharedPreferencesBetaBannerPreferencesRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _dismissedKey = 'appearance.betaBannerDismissed';

  @override
  bool isDismissed() => _prefs.getBool(_dismissedKey) ?? false;

  @override
  Future<void> markDismissed() => _prefs.setBool(_dismissedKey, true);

  @override
  Future<void> resetDismissed() => _prefs.remove(_dismissedKey);
}
