import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/time_billing/time_billing_state.dart';
import 'package:gewerber_app/core/errors/error_handler.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/repositories/time_tracking_repository.dart';

/// Drives the "create an invoice from tracked time" flow: previews the
/// unbilled billable entries of a project (optionally restricted to a
/// period), lets the user deselect individual entries and converts the
/// selection into a draft invoice via `timeEntry.createInvoice`.
@LazySingleton()
class TimeBillingCubit extends Cubit<TimeBillingState> {
  TimeBillingCubit(this._repository) : super(const TimeBillingState());

  final TimeTrackingRepository _repository;

  /// Selects the project to bill and refreshes the entry preview.
  Future<void> setProject(int? projectId) async {
    emit(
      state.copyWith(
        projectId: projectId,
        clearFailure: true,
        clearCreatedInvoice: true,
        unbilledEntries: const [],
      ),
    );
    await _loadEntries();
  }

  /// Restricts the preview and conversion to entries started within the
  /// given period (`null` bounds mean "no limit").
  Future<void> setPeriod({DateTime? from, DateTime? to}) async {
    emit(
      state.copyWith(
        from: from,
        to: to,
        clearFailure: true,
        clearCreatedInvoice: true,
      ),
    );
    await _loadEntries();
  }

  /// Toggles whether [entryId] is part of the billed selection.
  void toggleEntry(int entryId) {
    final deselected = Set<int>.of(state.deselectedEntryIds);
    if (!deselected.remove(entryId)) {
      deselected.add(entryId);
    }
    emit(state.copyWith(deselectedEntryIds: deselected));
  }

  /// Refreshes the unbilled-entry preview for the current selection.
  ///
  /// Public so callers can re-sync after server-side validation errors
  /// (e.g. entries that were billed elsewhere in the meantime).
  Future<void> refreshEntries() => _loadEntries();

  Future<void> _loadEntries() async {
    final projectId = state.projectId;
    if (projectId == null) return;
    emit(state.copyWith(isLoadingEntries: true));
    try {
      final entries = await _repository.listEntries(
        projectId: projectId,
        from: state.from,
        to: state.to,
        billable: true,
      );
      if (isClosed) return;
      // The list endpoint cannot filter by invoiced state, so unbilled
      // entries are narrowed here. Running timers have no duration yet.
      // A fresh preview starts fully selected.
      final unbilled = entries
          .where((entry) => !entry.isRunning && entry.invoicedAt == null)
          .toList();
      emit(
        state.copyWith(
          status: TimeBillingViewStatus.loaded,
          unbilledEntries: unbilled,
          deselectedEntryIds: const {},
          isLoadingEntries: false,
        ),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: TimeBillingViewStatus.failure,
          failure: mapAppException(e),
          isLoadingEntries: false,
        ),
      );
    } on Exception {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: TimeBillingViewStatus.failure,
          failure: const NetworkFailure(),
          isLoadingEntries: false,
        ),
      );
    }
  }

  /// Converts the selected entries into a draft invoice.
  ///
  /// Returns the created invoice, or `null` on failure (the mapped
  /// [Failure] is exposed via the state).
  Future<Invoice?> createInvoice() async {
    final projectId = state.projectId;
    if (projectId == null || state.isCreating) return null;
    // Nothing selected → nothing to bill; the button is disabled in that
    // case, this mirrors the server-side validation client-side.
    final timeEntryIds = state.selectedEntryIds.toList();
    if (timeEntryIds.isEmpty) return null;
    emit(state.copyWith(isCreating: true, clearFailure: true));
    try {
      final invoice = await _repository.createInvoice(
        projectId: projectId,
        from: state.from,
        to: state.to,
        timeEntryIds: timeEntryIds,
      );
      if (!isClosed) {
        // The billed entries left the unbilled pool; drop them from the
        // preview right away.
        emit(
          state.copyWith(
            isCreating: false,
            createdInvoice: invoice,
            unbilledEntries: const [],
          ),
        );
      }
      return invoice;
    } on Exception catch (e) {
      if (!isClosed) {
        final failure = e is AppException ? mapAppException(e) : null;
        emit(state.copyWith(isCreating: false, failure: failure));
        // A rejected selection usually means some entries were billed in
        // parallel; reload so the preview reflects the real server state.
        if (failure is ValidationFailure) {
          await _loadEntries();
        }
      }
      return null;
    }
  }
}
