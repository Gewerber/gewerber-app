import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/guidance/guidance_state.dart';
import 'package:gewerber_app/domain/repositories/guidance_repository.dart';

/// Owns the contextual guidance tips ("What is this?" content).
///
/// Tips are curated centrally and served by the guidance system; dismissing a
/// tip hides it for good.
@LazySingleton()
class GuidanceCubit extends Cubit<GuidanceState> {
  GuidanceCubit(this._repository) : super(const GuidanceState());

  final GuidanceRepository _repository;

  /// Loads the tips once.
  Future<void> load() async {
    if (state.isLoaded) return;
    emit(state.copyWith(isLoading: true, hasError: false));
    try {
      final tips = await _repository.tips();
      if (!isClosed) {
        emit(GuidanceState(tips: tips, isLoaded: true));
      }
    } on Exception {
      if (!isClosed) {
        emit(const GuidanceState(isLoaded: true, hasError: true));
      }
    }
  }

  /// Dismisses the tip with [topic] so it is not shown again.
  Future<void> dismiss(String topic) async {
    emit(
      state.copyWith(
        tips: state.tips.where((tip) => tip.topic != topic).toList(),
      ),
    );
    try {
      await _repository.dismissTip(topic);
    } on Exception {
      // Best effort: the tip is already hidden locally.
    }
  }

  /// Resets to the initial state.
  ///
  /// Used by tests to isolate scenarios from the shared singleton.
  void reset() {
    emit(const GuidanceState());
  }
}
