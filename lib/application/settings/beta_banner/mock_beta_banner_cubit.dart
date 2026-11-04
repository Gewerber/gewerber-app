import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/settings/beta_banner/beta_banner_state.dart';

/// Mock implementation of [BetaBannerCubit] for testing purposes.
///
/// This implementation provides an in-memory beta banner dismissal state
/// without persisting to local storage, making it ideal for widget tests
/// and development scenarios.
class MockBetaBannerCubit extends Cubit<BetaBannerState> {
  /// Creates a [MockBetaBannerCubit] with optional initial state.
  MockBetaBannerCubit({bool initialIsDismissed = false})
    : super(BetaBannerState(isDismissed: initialIsDismissed)) {
    _isDismissed = initialIsDismissed;
  }

  bool _isDismissed = false;

  /// Marks the beta banner as dismissed without persisting.
  void dismiss() {
    _isDismissed = true;
    emit(state.copyWith(isDismissed: true));
  }

  /// Resets the beta banner dismissal state (primarily for testing).
  void resetDismissed() {
    _isDismissed = false;
    emit(state.copyWith(isDismissed: false));
  }

  /// Gets the current dismissal state without emitting.
  bool get currentDismissed => _isDismissed;
}
