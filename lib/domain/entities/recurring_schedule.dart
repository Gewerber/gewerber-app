import 'package:equatable/equatable.dart';

/// Recurrence cadence of a recurring invoice schedule, mirroring the
/// server's `RecurrenceInterval` enum.
enum RecurrenceInterval {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly;

  static RecurrenceInterval fromName(String name) {
    return RecurrenceInterval.values.firstWhere(
      (value) => value.name == name,
      orElse: () => RecurrenceInterval.monthly,
    );
  }
}

/// A recurring invoice schedule.
///
/// The backend represents a schedule through its source invoice: a schedule
/// is "live" exactly when the invoice carries a `recurrenceInterval`. Due
/// schedules are materialized into new draft invoices by a background job;
/// cancelling keeps already created invoices.
class RecurringSchedule extends Equatable {
  const RecurringSchedule({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.interval,
    required this.issueDate,
    this.customerId,
    this.nextRecurrenceDate,
    this.recurrenceEndDate,
    this.recurrenceMaxOccurrences,
    this.recurrenceOccurrencesCreated = 0,
  });

  /// Id of the source invoice the schedule is attached to.
  final int invoiceId;

  /// Human-readable number of the source invoice (e.g. `RE-12`).
  final String invoiceNumber;

  /// How often a new invoice is generated.
  final RecurrenceInterval interval;

  /// Issue date of the source invoice. When no explicit
  /// [nextRecurrenceDate] is set, the server derives the first occurrence
  /// from it.
  final DateTime issueDate;

  /// Customer of the source invoice, if any.
  final int? customerId;

  /// Explicit date of the next generated invoice, if configured.
  final DateTime? nextRecurrenceDate;

  /// Optional end of the recurrence — no invoices after this date.
  final DateTime? recurrenceEndDate;

  /// Optional limit — no more than this many invoices in total.
  final int? recurrenceMaxOccurrences;

  /// How many invoices have been materialized so far.
  final int recurrenceOccurrencesCreated;

  /// Date the next invoice will be issued — the explicit next recurrence
  /// date or, when absent, the source invoice's issue date.
  DateTime get effectiveNextDate => nextRecurrenceDate ?? issueDate;

  RecurringSchedule copyWith({
    RecurrenceInterval? interval,
    DateTime? nextRecurrenceDate,
    DateTime? recurrenceEndDate,
    int? recurrenceMaxOccurrences,
  }) {
    return RecurringSchedule(
      invoiceId: invoiceId,
      invoiceNumber: invoiceNumber,
      interval: interval ?? this.interval,
      issueDate: issueDate,
      customerId: customerId,
      nextRecurrenceDate: nextRecurrenceDate ?? this.nextRecurrenceDate,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      recurrenceMaxOccurrences:
          recurrenceMaxOccurrences ?? this.recurrenceMaxOccurrences,
      recurrenceOccurrencesCreated: recurrenceOccurrencesCreated,
    );
  }

  @override
  List<Object?> get props => [
    invoiceId,
    invoiceNumber,
    interval,
    issueDate,
    customerId,
    nextRecurrenceDate,
    recurrenceEndDate,
    recurrenceMaxOccurrences,
    recurrenceOccurrencesCreated,
  ];
}
