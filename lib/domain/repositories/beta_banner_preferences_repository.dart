/// Device-local persistence for the public-beta banner dismissal.
abstract interface class BetaBannerPreferencesRepository {
  /// Whether the user already dismissed the beta banner.
  bool isDismissed();

  /// Persists that the user dismissed the beta banner.
  Future<void> markDismissed();

  /// Clears the stored dismissal (used by tests).
  Future<void> resetDismissed();
}
