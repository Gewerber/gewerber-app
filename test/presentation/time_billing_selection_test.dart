import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:gewerber_app/application/time_billing/time_billing_cubit.dart';
import 'package:gewerber_app/application/time_tracking/projects_cubit.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';
import 'package:gewerber_app/domain/repositories/time_tracking_repository.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/time_billing_screen.dart';

/// In-memory time-tracking repository recording the billing payload.
class _RecordingTimeTrackingRepository implements TimeTrackingRepository {
  _RecordingTimeTrackingRepository({
    required this.projects,
    required this.tasks,
    required this.entries,
    this.createError,
  });

  final List<Project> projects;
  final List<Task> tasks;
  final List<TimeEntry> entries;

  /// When set, [createInvoice] rejects the selection like the server does.
  final AppException? createError;

  List<int>? lastTimeEntryIds;

  @override
  Future<List<Project>> listProjects({ProjectStatus? status}) async =>
      projects.where((p) => status == null || p.status == status).toList();

  @override
  Future<List<Task>> listTasks(int projectId) async =>
      tasks.where((task) => task.projectId == projectId).toList();

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
    List<int>? timeEntryIds,
  }) async {
    if (createError != null) throw createError!;
    lastTimeEntryIds = List<int>.of(timeEntryIds ?? const []);
    return Invoice(
      id: 7,
      number: 'RE-7',
      issueDate: DateTime(2026, 8, 23),
      totalCents: 8500,
    );
  }

  // ── Unused members ──────────────────────────────────────────────────────

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

void main() {
  setUpAll(() async {
    // Date formatting uses the German default locale (see core/utils/format).
    await initializeDateFormatting('de_DE');
  });

  TimeEntry entry(int id, {int? taskId, required int minutes}) {
    return TimeEntry(
      id: id,
      projectId: 1,
      taskId: taskId,
      description: 'Work $id',
      startedAt: DateTime(2026, 8, 10 + id),
      stoppedAt: DateTime(2026, 8, 11 + id),
      durationMinutes: minutes,
      billable: true,
    );
  }

  /// Two priced entries: Work 1 → 6000 ¢ (task rate), Work 2 → 2500 ¢.
  _RecordingTimeTrackingRepository repository({AppException? createError}) =>
      _RecordingTimeTrackingRepository(
        projects: [Project(id: 1, name: 'Website', hourlyRateCents: 5000)],
        tasks: [
          Task(id: 11, projectId: 1, name: 'Design', hourlyRateCents: 6000),
          const Task(id: 12, projectId: 1, name: 'Meetings'),
        ],
        entries: [
          entry(1, taskId: 11, minutes: 60),
          entry(2, taskId: 12, minutes: 30),
        ],
        createError: createError,
      );

  Future<_RecordingTimeTrackingRepository> pumpBillingScreen(
    WidgetTester tester, {
    required _RecordingTimeTrackingRepository repo,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final projectsCubit = ProjectsCubit(repo);
    final billingCubit = TimeBillingCubit(repo);
    await projectsCubit.load(includeArchived: false);
    await billingCubit.setProject(1);
    // Mirror the screen: task rates are loaded for the selection.
    await projectsCubit.loadTasks(1);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Scaffold()),
        GoRoute(
          path: RouteNames.timeBilling,
          builder: (context, state) => const TimeBillingScreen(),
        ),
        GoRoute(
          path: RouteNames.invoiceDetail,
          builder: (context, state) => const Scaffold(body: Text('Invoice')),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ProjectsCubit>.value(value: projectsCubit),
          BlocProvider<TimeBillingCubit>.value(value: billingCubit),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    router.push(RouteNames.timeBilling);
    await tester.pumpAndSettle();
    return repo;
  }

  Finder createButton() => find.widgetWithText(FilledButton, 'Create invoice');

  testWidgets('every entry renders a checked checkbox by default', (
    tester,
  ) async {
    await pumpBillingScreen(tester, repo: repository());

    final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
    expect(checkboxes, hasLength(2));
    for (final checkbox in checkboxes) {
      expect(checkbox.value, isTrue);
    }
    // The totals cover both selected entries.
    expect(find.text(formatCents(8500)), findsOneWidget);
    expect(createButton(), findsOneWidget);
    expect(
      tester.widget<FilledButton>(createButton()).onPressed,
      isNotNull,
      reason: 'the button is enabled while at least one entry is selected',
    );
  });

  testWidgets('unchecking an entry recalculates minutes and total', (
    tester,
  ) async {
    await pumpBillingScreen(tester, repo: repository());

    // Uncheck "Work 1" via its row checkbox.
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    var checkboxes = tester
        .widgetList<Checkbox>(find.byType(Checkbox))
        .toList();
    expect(checkboxes.first.value, isFalse);
    expect(checkboxes.last.value, isTrue);

    // Only Work 2 remains: 30 min at the project rate → 2500 ¢.
    expect(find.text(formatCents(2500)), findsNWidgets(2));
    expect(find.text('30 minutes total'), findsOneWidget);

    // Re-checking restores the full total.
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
    expect(checkboxes.every((checkbox) => checkbox.value == true), isTrue);
    expect(find.text(formatCents(8500)), findsOneWidget);
  });

  testWidgets('deselecting every entry disables the create button', (
    tester,
  ) async {
    await pumpBillingScreen(tester, repo: repository());

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox).last);
    await tester.pumpAndSettle();

    expect(
      tester.widget<FilledButton>(createButton()).onPressed,
      isNull,
      reason: 'nothing selected → nothing to bill',
    );
  });

  testWidgets('submitting bills only the selected entries', (tester) async {
    final repo = repository();
    await pumpBillingScreen(tester, repo: repo);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    await tester.tap(createButton());
    await tester.pumpAndSettle();

    expect(repo.lastTimeEntryIds, [2]);
  });

  testWidgets('a server-rejected selection shows a message and refreshes', (
    tester,
  ) async {
    final repo = repository(
      createError: const ValidationException('entries already invoiced: 1'),
    );
    await pumpBillingScreen(tester, repo: repo);
    // Simulate a stale selection that the server no longer accepts.
    billingCubitOf(tester).toggleEntry(2);

    await tester.tap(createButton());
    await tester.pumpAndSettle();

    expect(find.textContaining('billed in the meantime'), findsOneWidget);
    // The preview was refreshed and is interactive again.
    expect(tester.widgetList<Checkbox>(find.byType(Checkbox)), hasLength(2));
  });
}

TimeBillingCubit billingCubitOf(WidgetTester tester) =>
    tester.element(find.byType(TimeBillingScreen)).read<TimeBillingCubit>();
