import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/recurring_schedule.dart';
import 'package:gewerber_app/infrastructure/core/serverpod_client_factory.dart';

/// Transport-level recurring-schedule calls against the Serverpod backend.
///
/// The schedule is represented by its source invoice on the wire; this data
/// source maps it to the [RecurringSchedule] entity and translates the
/// serverpod exceptions into [AppException]s so higher layers stay free of
/// transport details.
@LazySingleton(env: [AppEnvironment.authLive])
class RecurringScheduleRemoteDataSource {
  RecurringScheduleRemoteDataSource(this._clientFactory);

  final ServerpodClientFactory _clientFactory;

  sdk.Client get _client => _clientFactory.client;

  Future<List<RecurringSchedule>> list({int? limit, int? offset}) async {
    try {
      final models = await _client.recurringSchedule.list(
        limit: limit,
        offset: offset,
      );
      return models.map(_fromModel).toList();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<RecurringSchedule> get(int invoiceId) async {
    try {
      final model = await _client.recurringSchedule.get(invoiceId);
      return _fromModel(model);
    } on sdk.NotFoundException {
      throw const NotFoundException();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<RecurringSchedule> attach({
    required int invoiceId,
    required RecurrenceInterval interval,
    DateTime? nextRecurrenceDate,
    DateTime? recurrenceEndDate,
    int? recurrenceMaxOccurrences,
  }) async {
    try {
      final model = await _client.recurringSchedule.create(
        sdk.CreateRecurringScheduleRequest(
          invoiceId: invoiceId,
          interval: _toProtocolInterval(interval),
          nextRecurrenceDate: nextRecurrenceDate,
          recurrenceEndDate: recurrenceEndDate,
          recurrenceMaxOccurrences: recurrenceMaxOccurrences,
        ),
      );
      return _fromModel(model);
    } on sdk.ConflictException {
      throw const ConflictException();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<RecurringSchedule> update(
    RecurringSchedule schedule, {
    RecurrenceInterval? interval,
    DateTime? nextRecurrenceDate,
    DateTime? recurrenceEndDate,
    int? recurrenceMaxOccurrences,
    bool clearRecurrenceEndDate = false,
    bool clearMaxOccurrences = false,
  }) async {
    try {
      // The server keeps every field that is sent as `null`; the clear
      // flags remove an end date / occurrence limit regardless of the
      // field value sent alongside them.
      final model = await _client.recurringSchedule.update(
        sdk.UpdateRecurringScheduleRequest(
          invoiceId: schedule.invoiceId,
          interval: interval == null ? null : _toProtocolInterval(interval),
          nextRecurrenceDate: nextRecurrenceDate,
          recurrenceEndDate: recurrenceEndDate,
          recurrenceMaxOccurrences: recurrenceMaxOccurrences,
          clearRecurrenceEndDate: clearRecurrenceEndDate,
          clearMaxOccurrences: clearMaxOccurrences,
        ),
      );
      return _fromModel(model);
    } on sdk.NotFoundException {
      throw const NotFoundException();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<void> cancel(int invoiceId) async {
    try {
      await _client.recurringSchedule.cancel(invoiceId);
    } on sdk.NotFoundException {
      throw const NotFoundException();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  /// Wraps a schedule read into the `get` fallback used when an update or
  /// cancel response is not needed.
  RecurringSchedule _fromModel(sdk.Invoice model) {
    final interval = model.recurrenceInterval;
    if (interval == null) {
      // Defensive: the server only returns invoices with a live schedule.
      throw const NotFoundException('Invoice has no schedule');
    }
    return RecurringSchedule(
      invoiceId: model.id ?? -1,
      invoiceNumber: model.number,
      interval: RecurrenceInterval.fromName(interval.name),
      issueDate: model.issueDate,
      customerId: model.customerId,
      nextRecurrenceDate: model.nextRecurrenceDate,
      recurrenceEndDate: model.recurrenceEndDate,
      recurrenceMaxOccurrences: model.recurrenceMaxOccurrences,
      recurrenceOccurrencesCreated: model.recurrenceOccurrencesCreated,
    );
  }

  sdk.RecurrenceInterval _toProtocolInterval(RecurrenceInterval interval) =>
      sdk.RecurrenceInterval.values.byName(interval.name);
}
