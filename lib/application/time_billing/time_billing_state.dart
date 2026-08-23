import 'package:equatable/equatable.dart';

import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';

/// View status of the time-entries-to-invoice flow.
enum TimeBillingViewStatus { initial, loading, loaded, failure }

/// State of the "create an invoice from tracked time" flow.
class TimeBillingState extends Equatable {
  const TimeBillingState({
    this.status = TimeBillingViewStatus.initial,
    this.failure,
    this.projectId,
    this.from,
    this.to,
    this.unbilledEntries = const [],
    this.deselectedEntryIds = const {},
    this.isLoadingEntries = false,
    this.isCreating = false,
    this.createdInvoice,
  });

  final TimeBillingViewStatus status;
  final Failure? failure;

  /// Currently selected project the invoice will be created for.
  final int? projectId;

  /// Optional period restricting which entries are billed.
  final DateTime? from;
  final DateTime? to;

  /// Stopped billable entries of the selection that were not invoiced yet.
  final List<TimeEntry> unbilledEntries;

  /// Preview entries the user unchecked; every entry is selected by
  /// default, so only the deselected ids are tracked.
  final Set<int> deselectedEntryIds;

  /// Whether the unbilled-entry preview is being refreshed.
  final bool isLoadingEntries;

  /// Whether the invoice is currently being created.
  final bool isCreating;

  /// The invoice returned by the last successful conversion.
  final Invoice? createdInvoice;

  bool get hasSelection => projectId != null;

  /// Ids of the preview entries that will be billed (all entries except
  /// the deselected ones).
  Set<int> get selectedEntryIds => {
    for (final entry in unbilledEntries)
      if (!deselectedEntryIds.contains(entry.id)) entry.id,
  };

  /// Whether at least one preview entry is still selected.
  bool get hasSelectedEntries => selectedEntryIds.isNotEmpty;

  TimeBillingState copyWith({
    TimeBillingViewStatus? status,
    Failure? failure,
    int? projectId,
    DateTime? from,
    DateTime? to,
    List<TimeEntry>? unbilledEntries,
    Set<int>? deselectedEntryIds,
    bool? isLoadingEntries,
    bool? isCreating,
    Invoice? createdInvoice,
    bool clearFailure = false,
    bool clearCreatedInvoice = false,
  }) {
    return TimeBillingState(
      status: status ?? this.status,
      failure: clearFailure ? null : (failure ?? this.failure),
      projectId: projectId ?? this.projectId,
      from: from ?? this.from,
      to: to ?? this.to,
      unbilledEntries: unbilledEntries ?? this.unbilledEntries,
      deselectedEntryIds: deselectedEntryIds ?? this.deselectedEntryIds,
      isLoadingEntries: isLoadingEntries ?? this.isLoadingEntries,
      isCreating: isCreating ?? this.isCreating,
      createdInvoice: clearCreatedInvoice
          ? null
          : (createdInvoice ?? this.createdInvoice),
    );
  }

  @override
  List<Object?> get props => [
    status,
    failure,
    projectId,
    from,
    to,
    unbilledEntries,
    deselectedEntryIds,
    isLoadingEntries,
    isCreating,
    createdInvoice,
  ];
}
