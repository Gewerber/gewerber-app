import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/domain/entities/business.dart';
import 'package:gewerber_app/domain/entities/customer.dart';
import 'package:gewerber_app/domain/entities/customer_list_page.dart';
import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/entities/invoice_list_page.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/domain/repositories/accounting_repository.dart';
import 'package:gewerber_app/domain/repositories/customer_repository.dart';
import 'package:gewerber_app/domain/repositories/dashboard_repository.dart';
import 'package:gewerber_app/domain/repositories/invoice_repository.dart';
import 'package:gewerber_app/domain/repositories/time_tracking_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/composite_dashboard_repository.dart';

// Hand-written fakes (no codegen) mirroring the existing module contracts,
// just rich enough for dashboard composition.

class _FakeAccountingRepository implements AccountingRepository {
  _FakeAccountingRepository({this.transactions = const []});

  final List<AccountingTransaction> transactions;
  final List<(DateTime, DateTime)> profitLossCalls = [];

  @override
  Future<List<AccountingTransaction>> list({
    TransactionType? type,
    TransactionCategory? category,
    DateTime? from,
    DateTime? to,
    int? limit,
    int? offset,
  }) async {
    var result = transactions.where(
      (transaction) =>
          (type == null || transaction.type == type) &&
          (from == null || !transaction.occurredAt.isBefore(from)) &&
          (to == null || !transaction.occurredAt.isAfter(to)),
    );
    final start = offset ?? 0;
    result = result.skip(start);
    return (limit == null ? result : result.take(limit)).toList();
  }

  @override
  Future<ProfitLossReport> profitLoss(DateTime from, DateTime to) async {
    profitLossCalls.add((from, to));
    final inPeriod = transactions.where(
      (transaction) =>
          !transaction.occurredAt.isBefore(from) &&
          !transaction.occurredAt.isAfter(to),
    );
    final income = inPeriod
        .where((transaction) => transaction.type == TransactionType.income)
        .fold<int>(0, (sum, transaction) => sum + transaction.amountCents);
    final expense = inPeriod
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold<int>(0, (sum, transaction) => sum + transaction.amountCents);
    return ProfitLossReport(
      from: from,
      to: to,
      incomeCents: income,
      expenseCents: expense,
      profitCents: income - expense,
    );
  }

  // ── Unused members ──────────────────────────────────────────────────────

  @override
  Future<AccountingTransaction> create({
    required TransactionType type,
    required TransactionCategory category,
    required DateTime occurredAt,
    required int amountCents,
    String? description,
    int? receiptDocumentId,
  }) => throw UnimplementedError();

  @override
  Future<void> delete(int transactionId) => throw UnimplementedError();

  @override
  Future<String> exportCsv({
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  }) => throw UnimplementedError();

  @override
  Future<AccountingTransaction> update(AccountingTransaction transaction) =>
      throw UnimplementedError();

  @override
  Future<AccountingTransaction> getAccountingTransaction(int transactionId) =>
      throw UnimplementedError();
}

class _FakeInvoiceRepository implements InvoiceRepository {
  _FakeInvoiceRepository({this.invoices = const []});

  /// Insertion order on purpose: the composite must not rely on the source
  /// ordering.
  final List<Invoice> invoices;

  @override
  Future<List<Invoice>> list({
    InvoiceStatus? status,
    int? limit,
    int? offset,
  }) async {
    var result = invoices.where(
      (invoice) => status == null || invoice.status == status,
    );
    final start = offset ?? 0;
    result = result.skip(start);
    return (limit == null ? result : result.take(limit)).toList();
  }

  // ── Unused members ──────────────────────────────────────────────────────

  @override
  Future<Invoice> cancel(int invoiceId) => throw UnimplementedError();

  @override
  Future<Invoice> create({
    required List<InvoiceItem> items,
    int? customerId,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? serviceDateFrom,
    DateTime? serviceDateTo,
    String? notes,
    int? templateId,
  }) => throw UnimplementedError();

  @override
  Future<void> delete(int invoiceId) => throw UnimplementedError();

  @override
  Future<String> exportCsv({InvoiceStatus? status}) =>
      throw UnimplementedError();

  @override
  Future<String> exportJson({InvoiceStatus? status}) =>
      throw UnimplementedError();

  @override
  Future<({Invoice invoice, List<InvoiceItem> items})> get(int invoiceId) =>
      throw UnimplementedError();

  @override
  Future<InvoicePdf> generatePdf(int invoiceId) => throw UnimplementedError();

  @override
  Future<Invoice> markSent(int invoiceId) => throw UnimplementedError();

  @override
  Future<PaymentRecord> recordPayment({
    required int invoiceId,
    required int amountCents,
    DateTime? paidAt,
    String? reference,
  }) => throw UnimplementedError();

  @override
  Future<List<InvoiceReminder>> listReminders(int invoiceId) =>
      throw UnimplementedError();

  @override
  Future<InvoicePaymentStatus> paymentStatus(int invoiceId) =>
      throw UnimplementedError();

  @override
  Future<InvoiceReminder> sendReminder(int invoiceId) =>
      throw UnimplementedError();

  @override
  Future<Invoice> update(Invoice invoice, {required List<InvoiceItem> items}) =>
      throw UnimplementedError();

  @override
  Future<InvoiceCursorPage> listCursorPage({
    InvoiceStatus? status,
    int? limit,
    String? cursor,
  }) => throw UnimplementedError();

  @override
  Future<InvoiceListPage> listPage({
    InvoiceStatus? status,
    int? limit,
    int? offset,
  }) => throw UnimplementedError();
}

class _FakeTimeTrackingRepository implements TimeTrackingRepository {
  _FakeTimeTrackingRepository({
    this.projects = const [],
    this.entries = const [],
  });

  final List<Project> projects;
  final List<TimeEntry> entries;

  @override
  Future<List<Project>> listProjects({ProjectStatus? status}) async => projects
      .where((project) => status == null || project.status == status)
      .toList();

  @override
  Future<List<TimeEntry>> listEntries({
    int? projectId,
    int? taskId,
    DateTime? from,
    DateTime? to,
    bool? billable,
    int? limit,
  }) async {
    var result = entries.where(
      (entry) =>
          (projectId == null || entry.projectId == projectId) &&
          (from == null || !entry.startedAt.isBefore(from)) &&
          (to == null || !entry.startedAt.isAfter(to)),
    );
    return limit == null ? result.toList() : result.take(limit).toList();
  }

  // ── Unused members ──────────────────────────────────────────────────────

  @override
  Future<Task> createTask({
    required int projectId,
    required String name,
    int? hourlyRateCents,
  }) => throw UnimplementedError();

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
  Future<Invoice> createInvoice({
    required int projectId,
    DateTime? from,
    DateTime? to,
    int? customerId,
    DateTime? issueDate,
    List<int>? timeEntryIds,
  }) => throw UnimplementedError();

  @override
  Future<Project> createProject({
    required String name,
    int? customerId,
    int? hourlyRateCents,
    String? notes,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteEntry(int timeEntryId) => throw UnimplementedError();

  @override
  Future<void> deleteProject(int projectId) => throw UnimplementedError();

  @override
  Future<TimeEntry?> runningEntry() => throw UnimplementedError();

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

  @override
  Future<Task> updateTask(Task task) => throw UnimplementedError();

  @override
  Future<TimeEntry> updateEntry(TimeEntry entry) => throw UnimplementedError();

  @override
  Future<Project> updateProject(Project project) => throw UnimplementedError();

  @override
  Future<List<Task>> listTasks(int projectId) => throw UnimplementedError();

  @override
  Future<Project> getProject(int projectId) => throw UnimplementedError();

  @override
  Future<TimeEntry> getTimeEntry(int timeEntryId) => throw UnimplementedError();

  @override
  Future<List<Task>> listAllTasks({
    int? projectId,
    TaskStatus? status,
    int? limit,
    int? offset,
  }) => throw UnimplementedError();
}

class _FakeCustomerRepository implements CustomerRepository {
  _FakeCustomerRepository({this.customers = const []});

  final List<Customer> customers;

  @override
  Future<List<Customer>> list({
    CustomerStatus? status,
    int? limit,
    int? offset,
  }) async => customers;

  // ── Unused members ──────────────────────────────────────────────────────

  @override
  Future<CustomerListPage> listPage({
    CustomerStatus? status,
    int? limit,
    int? offset,
  }) => throw UnimplementedError();

  @override
  Future<CustomerCursorPage> listCursorPage({
    CustomerStatus? status,
    int? limit,
    String? cursor,
  }) => throw UnimplementedError();

  @override
  Future<void> archive(int customerId) => throw UnimplementedError();

  @override
  Future<Customer> create({
    required String name,
    String? companyName,
    String? vatId,
    String? email,
    String? phone,
    Address? address,
    String? notes,
  }) => throw UnimplementedError();

  @override
  Future<Customer> update(Customer customer) => throw UnimplementedError();
}

AccountingTransaction tx(int id, TransactionType type, DateTime occurredAt) {
  return AccountingTransaction(
    id: id,
    type: type,
    category: type == TransactionType.income
        ? TransactionCategory.salesRevenue
        : TransactionCategory.office,
    occurredAt: occurredAt,
    amountCents: 1000,
  );
}

Invoice invoice(
  int id,
  String number,
  InvoiceStatus status, {
  int? customerId,
  required DateTime issueDate,
  DateTime? dueDate,
  int totalCents = 1000,
}) {
  return Invoice(
    id: id,
    number: number,
    status: status,
    customerId: customerId,
    issueDate: issueDate,
    dueDate: dueDate,
    totalCents: totalCents,
  );
}

void main() {
  group('monthlyFinancials', () {
    test('caps the trend window', () async {
      final repo = CompositeDashboardRepository(
        _FakeAccountingRepository(),
        _FakeInvoiceRepository(),
        _FakeTimeTrackingRepository(),
        _FakeCustomerRepository(),
      );

      final months = await repo.monthlyFinancials(
        months: 99,
        anchor: DateTime(2026, 8, 24),
      );

      // The window is capped at the domain limit.
      expect(months, hasLength(DashboardRepository.maxTrendMonths));
      expect(months.first.monthStart, DateTime(2025, 9, 1));
      expect(months.last.monthStart, DateTime(2026, 8, 1));
    });

    test('queries one closed P&L period per month', () async {
      final accounting = _FakeAccountingRepository();
      final repo = CompositeDashboardRepository(
        accounting,
        _FakeInvoiceRepository(),
        _FakeTimeTrackingRepository(),
        _FakeCustomerRepository(),
      );

      await repo.monthlyFinancials(months: 3, anchor: DateTime(2026, 8, 24));

      expect(accounting.profitLossCalls, hasLength(3));
      final (firstFrom, firstTo) = accounting.profitLossCalls.first;
      expect(firstFrom, DateTime(2026, 6, 1));
      expect(firstTo, DateTime(2026, 6, 30, 23, 59, 59, 999));
    });

    test('aggregates income and expenses per month', () async {
      final repo = CompositeDashboardRepository(
        _FakeAccountingRepository(
          transactions: [
            tx(1, TransactionType.income, DateTime(2026, 7, 5, 12)),
            tx(2, TransactionType.income, DateTime(2026, 7, 20, 12)),
            tx(3, TransactionType.expense, DateTime(2026, 7, 21, 12)),
            // Outside the trend window.
            tx(4, TransactionType.income, DateTime(2026, 2, 1, 12)),
          ],
        ),
        _FakeInvoiceRepository(),
        _FakeTimeTrackingRepository(),
        _FakeCustomerRepository(),
      );

      final months = await repo.monthlyFinancials(
        months: 3,
        anchor: DateTime(2026, 8, 24),
      );

      final july = months.lastWhere((month) => month.monthStart.month == 7);
      expect(july.incomeCents, 2000);
      expect(july.expenseCents, 1000);
      final june = months.firstWhere((month) => month.monthStart.month == 6);
      expect(june.incomeCents, 0);
      expect(june.expenseCents, 0);
    });
  });

  group('recentActivity', () {
    test('merges sources, sorts newest first and takes the limit', () async {
      final repo = CompositeDashboardRepository(
        _FakeAccountingRepository(
          transactions: [tx(1, TransactionType.income, DateTime(2026, 8, 3))],
        ),
        _FakeInvoiceRepository(
          invoices: [
            invoice(
              10,
              'RE-2',
              InvoiceStatus.sent,
              issueDate: DateTime(2026, 8, 1),
            ),
            invoice(
              11,
              'RE-5',
              InvoiceStatus.draft,
              issueDate: DateTime(2026, 8, 5),
            ),
          ],
        ),
        _FakeTimeTrackingRepository(
          projects: const [Project(id: 7, name: 'Website')],
          entries: [
            TimeEntry(
              id: 20,
              projectId: 7,
              startedAt: DateTime(2026, 8, 2, 9),
              stoppedAt: DateTime(2026, 8, 2, 10, 30),
              durationMinutes: 90,
            ),
            // A running timer has no duration yet and is skipped.
            TimeEntry(
              id: 21,
              projectId: 7,
              startedAt: DateTime(2026, 8, 23, 9),
            ),
          ],
        ),
        _FakeCustomerRepository(),
      );

      final activity = await repo.recentActivity(limit: 3);

      expect(activity, hasLength(3));
      // Newest first across sources: draft invoice (Aug 5), transaction
      // (Aug 3), tracked time (Aug 2); the older invoice drops out.
      expect(activity[0], isA<InvoiceActivity>());
      expect(activity[1], isA<TransactionActivity>());
      final time = activity[2] as TimeActivity;
      expect(time.minutes, 90);
      expect(time.project, 'Website');
    });
  });

  group('receivables', () {
    test('groups open invoices per customer, largest debtor first', () async {
      final repo = CompositeDashboardRepository(
        _FakeAccountingRepository(),
        _FakeInvoiceRepository(
          invoices: [
            invoice(
              1,
              'RE-1',
              InvoiceStatus.sent,
              customerId: 1,
              issueDate: DateTime(2026, 7, 1),
              totalCents: 10000,
            ),
            invoice(
              2,
              'RE-2',
              InvoiceStatus.sent,
              customerId: 1,
              issueDate: DateTime(2026, 7, 5),
              totalCents: 5000,
            ),
            // Drafts and paid invoices are not receivables.
            invoice(
              3,
              'RE-3',
              InvoiceStatus.draft,
              customerId: 1,
              issueDate: DateTime(2026, 7, 6),
              totalCents: 99999,
            ),
            invoice(
              4,
              'RE-4',
              InvoiceStatus.paid,
              customerId: 1,
              issueDate: DateTime(2026, 7, 7),
              totalCents: 88888,
            ),
          ],
        ),
        _FakeTimeTrackingRepository(),
        _FakeCustomerRepository(
          customers: [
            const Customer(id: 1, name: 'Anna Muster'),
            const Customer(
              id: 2,
              name: 'Bob Schmidt',
              companyName: 'Beta GmbH',
            ),
          ],
        ),
      );

      final summary = await repo.receivables();

      expect(summary.debtors.single.customerId, 1);
      expect(summary.debtors.single.displayName, 'Anna Muster');
      expect(summary.debtors.single.outstandingCents, 15000);
      expect(summary.debtors.single.invoiceCount, 2);
      expect(summary.outstandingTotalCents, 15000);
    });

    test('breaks ties between equal amounts deterministically', () async {
      final repo = CompositeDashboardRepository(
        _FakeAccountingRepository(),
        _FakeInvoiceRepository(
          invoices: [
            // Insertion order deliberately differs from the expected order.
            invoice(
              1,
              'RE-1',
              InvoiceStatus.sent,
              issueDate: DateTime(2026, 7, 1),
              totalCents: 5000,
            ),
            invoice(
              2,
              'RE-2',
              InvoiceStatus.sent,
              customerId: 3,
              issueDate: DateTime(2026, 7, 2),
              totalCents: 5000,
            ),
            invoice(
              3,
              'RE-3',
              InvoiceStatus.overdue,
              customerId: 2,
              issueDate: DateTime(2026, 7, 3),
              dueDate: DateTime(2026, 7, 20),
              totalCents: 5000,
            ),
            invoice(
              4,
              'RE-4',
              InvoiceStatus.sent,
              customerId: 1,
              issueDate: DateTime(2026, 7, 4),
              totalCents: 9000,
            ),
          ],
        ),
        _FakeTimeTrackingRepository(),
        _FakeCustomerRepository(
          customers: const [
            Customer(id: 1, name: 'A'),
            Customer(id: 2, name: 'B'),
            Customer(id: 3, name: 'C'),
          ],
        ),
      );

      final summary = await repo.receivables();

      // Amount first (9000 > 5000); the three tied buckets follow by
      // customer id ascending with the "no customer" bucket last — a stable
      // order across refreshes despite List.sort being unstable.
      expect(summary.debtors.map((debtor) => debtor.customerId), [
        1,
        2,
        3,
        null,
      ]);
    });

    test('sorts debtors by outstanding amount descending', () async {
      final repo = CompositeDashboardRepository(
        _FakeAccountingRepository(),
        _FakeInvoiceRepository(
          invoices: [
            invoice(
              1,
              'RE-1',
              InvoiceStatus.sent,
              customerId: 1,
              issueDate: DateTime(2026, 7, 1),
              totalCents: 3000,
            ),
            invoice(
              2,
              'RE-2',
              InvoiceStatus.overdue,
              customerId: 2,
              issueDate: DateTime(2026, 7, 2),
              dueDate: DateTime(2026, 7, 20),
              totalCents: 12000,
            ),
          ],
        ),
        _FakeTimeTrackingRepository(),
        _FakeCustomerRepository(
          customers: [
            const Customer(id: 1, name: 'Small'),
            const Customer(id: 2, name: 'Big', companyName: 'Big GmbH'),
          ],
        ),
      );

      final summary = await repo.receivables();

      expect(summary.debtors.map((debtor) => debtor.displayName), [
        'Big GmbH',
        'Small',
      ]);
      // Overdue invoices are ordered by urgency (earliest due date first).
      expect(summary.overdueInvoices.single.number, 'RE-2');
    });

    test('invoices without a customer form their own group', () async {
      final repo = CompositeDashboardRepository(
        _FakeAccountingRepository(),
        _FakeInvoiceRepository(
          invoices: [
            invoice(
              1,
              'RE-1',
              InvoiceStatus.sent,
              issueDate: DateTime(2026, 7, 1),
              totalCents: 2000,
            ),
          ],
        ),
        _FakeTimeTrackingRepository(),
        _FakeCustomerRepository(customers: const [Customer(id: 1, name: 'X')]),
      );

      final summary = await repo.receivables();

      final anonymous = summary.debtors.single;
      expect(anonymous.customerId, isNull);
      expect(anonymous.displayName, isNull);
      expect(anonymous.outstandingCents, 2000);
      expect(anonymous.invoiceCount, 1);
    });
  });

  group('summary', () {
    test('is deterministic relative to the anchor', () async {
      Future<CompositeDashboardRepository> newRepo() async {
        return CompositeDashboardRepository(
          _FakeAccountingRepository(
            transactions: [tx(1, TransactionType.income, DateTime(2026, 7, 5))],
          ),
          _FakeInvoiceRepository(
            invoices: [
              invoice(
                1,
                'RE-1',
                InvoiceStatus.sent,
                customerId: 1,
                issueDate: DateTime(2026, 8, 4),
              ),
            ],
          ),
          _FakeTimeTrackingRepository(
            projects: const [Project(id: 7, name: 'Website')],
          ),
          _FakeCustomerRepository(
            customers: const [Customer(id: 1, name: 'Anna Muster')],
          ),
        );
      }

      final anchor = DateTime(2026, 8, 24, 10);
      final first = await (await newRepo()).summary(months: 6, anchor: anchor);
      final second = await (await newRepo()).summary(months: 6, anchor: anchor);

      expect(first.months, second.months);
      expect(first.activity, second.activity);
      expect(first.receivables, second.receivables);
      expect(first.generatedAt.isAfter(DateTime(2020)), isTrue);
    });
  });
}
