import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/guidance/checklist_state.dart';
import 'package:gewerber_app/domain/repositories/guidance_repository.dart';

/// Owns the getting-started checklist.
///
/// Checklist content and progress come from the guidance system: in live mode
/// both are served by the backend (server-synced, one-way progress); in demo
/// mode the local mock catalog and device storage keep the experience fully
/// functional offline.
@LazySingleton()
class ChecklistCubit extends Cubit<ChecklistState> {
  ChecklistCubit(this._repository) : super(const ChecklistState());

  final GuidanceRepository _repository;

  /// Loads the checklist definition and the stored progress once.
  Future<void> load() async {
    if (state.isLoaded) return;
    emit(state.copyWith(isLoading: true));
    try {
      final checklists = await _repository.checklists();
      final completed = await _repository.completedItemKeys();
      if (!isClosed) {
        emit(
          ChecklistState(
            items: checklists.isEmpty ? const [] : checklists.first.items,
            completedIds: completed,
            isLoaded: true,
            supportsUnmark: _repository.supportsUnmark,
          ),
        );
      }
    } on Exception {
      if (!isClosed) {
        // Non-fatal: show the checklist with nothing completed.
        emit(const ChecklistState(isLoaded: true));
      }
    }
  }

  /// Marks [id] as completed, or un-completes it when already completed
  /// (demo mode only — server progress is one-way).
  Future<void> toggle(String id) async {
    if (!state.isLoaded) await load();
    if (isClosed) return;
    final ids = {...state.completedIds};
    if (ids.contains(id)) {
      if (!state.supportsUnmark) return;
      ids.remove(id);
      emit(state.copyWith(completedIds: ids));
      await _repository.unmarkCompleted(id);
    } else {
      ids.add(id);
      emit(state.copyWith(completedIds: ids));
      await _repository.markCompleted(id);
    }
  }

  /// Resets to the initial state.
  ///
  /// Used by tests to isolate scenarios from the shared singleton.
  void reset() {
    emit(const ChecklistState());
  }
}
