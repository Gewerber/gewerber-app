import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/settings/beta_banner/beta_banner_state.dart';
import 'package:gewerber_app/infrastructure/datasources/local/beta_banner_preferences_store.dart' as _i788;

/// Cubit that manages the beta banner dismissal state.
///
/// This cubit tracks whether the user has dismissed the beta banner and
/// persists that state locally so the banner doesn't appear again in future
/// app sessions.
class BetaBannerCubit extends Cubit<BetaBannerState> {
  /// Creates a [BetaBannerCubit].
  ///
  /// [betaBannerPreferences] is used to persist the dismissal state across
  /// app restarts. It's optional so tests can run without it.
  BetaBannerCubit({
    BetaBannerPreferencesRepository? betaBannerPreferencesRepository,
  }) : super(
         BetaBannerState(
           isDismissed: betaBannerPreferencesRepository?.isDismissed() ?? false,
         ), // Initial state: true if dismissed, false otherwise
       ) {
    _betaBannerPreferencesRepository = betaBannerPreferencesRepository;
  }

  BetaBannerPreferencesRepository? _betaBannerPreferencesRepository;

  /// Marks the beta banner as dismissed and updates the local state.
  ///
  /// This method persists the dismissal state so the banner won't appear
  /// in future app sessions.
  Future<void> dismiss() async {
    if (_betaBannerPreferencesRepository != null) {
      await _betaBannerPreferencesRepository!.markDismissed();
    }
    emit(state.copyWith(isDismissed: true));
  }

  /// Resets the beta banner dismissal state (primarily for testing).
  Future<void> resetDismissed() async {
    if (_betaBannerPreferencesRepository != null) {
      await _betaBannerPreferencesRepository!.resetDismissed();
    }
    emit(state.copyWith(isDismissed: false));
  }
}
