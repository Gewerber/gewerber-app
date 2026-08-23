import 'package:gewerber_app/domain/entities/recurring_schedule.dart';

/// Contract for recurring-invoice-schedule operations used by the
/// application layer.
///
/// The backend represents a schedule through its source invoice; attaching,
/// updating and cancelling all return the updated schedule.
abstract interface class RecurringScheduleRepository {
  /// Lists the schedules of the active business, upcoming next issue first.
  ///
  /// [limit] and [offset] page through the server-side list; `null` lets the
  /// backend apply its defaults.
  Future<List<RecurringSchedule>> list({int? limit, int? offset});

  /// Loads the schedule attached to [invoiceId].
  ///
  /// Throws [NotFoundException] when the invoice has no live schedule.
  Future<RecurringSchedule> get(int invoiceId);

  /// Attaches a new schedule to [invoiceId].
  ///
  /// When [nextRecurrenceDate] is omitted the server derives the next issue
  /// date from the source invoice's issue date. Throws [ConflictException]
  /// when the invoice already carries a schedule.
  Future<RecurringSchedule> attach({
    required int invoiceId,
    required RecurrenceInterval interval,
    DateTime? nextRecurrenceDate,
    DateTime? recurrenceEndDate,
    int? recurrenceMaxOccurrences,
  });

  /// Updates the settings of an existing [schedule].
  ///
  /// Mirrors the server contract: `null` arguments keep their current
  /// value; clearing an end date or occurrence limit is only possible by
  /// cancelling the whole schedule.
  Future<RecurringSchedule> update(
    RecurringSchedule schedule, {
    RecurrenceInterval? interval,
    DateTime? nextRecurrenceDate,
    DateTime? recurrenceEndDate,
    int? recurrenceMaxOccurrences,
  });

  /// Cancels the schedule attached to [invoiceId] and returns the cleared
  /// source invoice state. Already materialized invoices remain untouched.
  Future<void> cancel(int invoiceId);
}
