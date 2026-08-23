import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/time_billing/time_billing_cubit.dart';
import 'package:gewerber_app/application/time_billing/time_billing_state.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';
import 'package:gewerber_app/domain/repositories/time_tracking_repository.dart';

class _FakeTimeTrackingRepository implements TimeTrackingRepository {
  _FakeTimeTrackingRepository({this.entries = const [], this.fail = false});

  final List<TimeEntry> entries;
  final bool fail;

  CreateInvoiceCall? lastCreateInvoiceCall;

  @override
  Future<List<TimeEntry>> listEntries({
    int? projectId,
    int? taskId,
    DateTime? from,
    DateTime? to,
    bool? billable,
    int? limit,
  }) async {
    return entries
        .where(
          (entry) =>
              (projectId == null || entry.projectId == projectId) &&
              (from == null || !entry.startedAt.isBefore(from)) &&
              (to == null || !entry.startedAt.isAfter(to)) &&
              (billable == null || entry.billable == billable),
        )
        .toList();
  }

  @override
  Future<Invoice> createInvoice({
    required int projectId,
    DateTime? from,
    DateTime? to,
    int? customerId,
    DateTime? issueDate,
  }) async {
    if (fail) throw const NetworkException('boom');
    lastCreateInvoiceCall = (projectId: projectId, from: from, to: to);
    return Invoice(
      id: 42,
      number: 'RE-42',
      issueDate: issueDate ?? DateTime(2026, 8, 20),
      totalCents: 12000,
    );
  }

  // ── Unused members ──────────────────────────────────────────────────────

  @override
  Future<List<Project>> listProjects({ProjectStatus? status}) async => [];

  @override
  Future<Project> createProject({
    required String name,
    int? customerId,
    int? hourlyRateCents,
    String? notes,
  }) => throw UnimplementedError();

  @override
  Future<Project> updateProject(Project project) => throw UnimplementedError();

  @override
  Future<void> deleteProject(int projectId) => throw UnimplementedError();

  @override
  Future<List<Task>> listTasks(int projectId) async => [];

  @override
  Future<Task> createTask({
    required int projectId,
    required String name,
    int? hourlyRateCents,
  }) => throw UnimplementedError();

  @override
  Future<Task> updateTask(Task task) => throw UnimplementedError();

  @override
  Future<TimeEntry> createEntry({
    required DateTime startedAt,
    required int durationMinutes,
    int? projectId,
    int? taskId,
    String? description,
    bool billable = false,
  }) => throw UnimplementedError();

  @override
  Future<TimeEntry> updateEntry(TimeEntry entry) => throw UnimplementedError();

  @override
  Future<void> deleteEntry(int timeEntryId) => throw UnimplementedError();

  @override
  Future<TimeEntry?> runningEntry() async => null;

  @override
  Future<TimeEntry> startTimer({
    int? projectId,
    int? taskId,
    String? description,
    bool billable = false,
  }) => throw UnimplementedError();

  @override
  Future<TimeEntry> stopTimer() => throw UnimplementedError();

  @override
  Future<TimeReport> report(DateTime from, DateTime to, {int? projectId}) =>
      throw UnimplementedError();
}

typedef CreateInvoiceCall = ({int projectId, DateTime? from, DateTime? to});

void main() {
  TimeEntry entry(
    int id, {
    bool billable = true,
    bool running = false,
    bool invoiced = false,
    int minutes = 60,
  }) {
    return TimeEntry(
      id: id,
      projectId: 1,
      description: 'Work $id',
      startedAt: DateTime(2026, 8, 10 + id),
      stoppedAt: running ? null : DateTime(2026, 8, 11 + id),
      durationMinutes: running ? null : minutes,
      billable: billable,
      invoicedAt: invoiced ? DateTime(2026, 8, 12) : null,
    );
  }

  test('starts empty and without a selection', () {
    final cubit = TimeBillingCubit(_FakeTimeTrackingRepository());

    expect(cubit.state.status, TimeBillingViewStatus.initial);
    expect(cubit.state.hasSelection, isFalse);
  });

  test('preview keeps only stopped, billable, unbilled entries', () async {
    final repository = _FakeTimeTrackingRepository(
      entries: [
        entry(1),
        entry(2, billable: false),
        entry(3, running: true),
        entry(4, invoiced: true),
        entry(5),
      ],
    );
    final cubit = TimeBillingCubit(repository);

    await cubit.setProject(1);

    expect(cubit.state.status, TimeBillingViewStatus.loaded);
    expect(cubit.state.unbilledEntries.map((entry) => entry.id).toList(), [
      1,
      5,
    ]);
  });

  test('createInvoice returns the invoice and empties the preview', () async {
    final repository = _FakeTimeTrackingRepository(entries: [entry(1)]);
    final cubit = TimeBillingCubit(repository);
    await cubit.setProject(1);

    final invoice = await cubit.createInvoice();

    expect(invoice, isNotNull);
    expect(invoice!.number, 'RE-42');
    expect(cubit.state.createdInvoice?.id, 42);
    expect(cubit.state.isCreating, isFalse);
    expect(cubit.state.unbilledEntries, isEmpty);
    expect(repository.lastCreateInvoiceCall?.projectId, 1);
  });

  test('createInvoice forwards the selected period', () async {
    final repository = _FakeTimeTrackingRepository(entries: [entry(1)]);
    final cubit = TimeBillingCubit(repository);

    await cubit.setPeriod(from: DateTime(2026, 8, 1), to: DateTime(2026, 9, 1));
    await cubit.setProject(1);
    await cubit.createInvoice();

    expect(repository.lastCreateInvoiceCall?.from, DateTime(2026, 8, 1));
    expect(repository.lastCreateInvoiceCall?.to, DateTime(2026, 9, 1));
  });

  test('createInvoice without a selection is a no-op', () async {
    final cubit = TimeBillingCubit(_FakeTimeTrackingRepository());

    final invoice = await cubit.createInvoice();

    expect(invoice, isNull);
  });

  test('createInvoice failure exposes a failure state', () async {
    final repository = _FakeTimeTrackingRepository(
      entries: [entry(1)],
      fail: true,
    );
    final cubit = TimeBillingCubit(repository);
    await cubit.setProject(1);

    final invoice = await cubit.createInvoice();

    expect(invoice, isNull);
    expect(cubit.state.failure, isA<NetworkFailure>());
    expect(cubit.state.isCreating, isFalse);
  });
}
