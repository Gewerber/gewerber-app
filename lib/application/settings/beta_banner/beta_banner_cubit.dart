import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/settings/beta_banner/beta_banner_state.dart';
import 'package:gewerber_app/domain/repositories/beta_banner_preferences_repository.dart';

/// Keeps the public-beta banner visible until the user dismisses it.
///
/// The dismissal is persisted through [BetaBannerPreferencesRepository], so
/// the banner stays hidden across restarts.
class BetaBannerCubit extends Cubit<BetaBannerState> {
  /// Creates a [BetaBannerCubit].
  ///
  /// [preferences] is optional so tests can run without local storage.
  BetaBannerCubit({BetaBannerPreferencesRepository? preferences})
    : _preferences = preferences,
      super(BetaBannerState(isDismissed: preferences?.isDismissed() ?? false));

  final BetaBannerPreferencesRepository? _preferences;

  /// Hides the banner and persists the dismissal.
  Future<void> dismiss() async {
    await _preferences?.markDismissed();
    emit(state.copyWith(isDismissed: true));
  }
}
