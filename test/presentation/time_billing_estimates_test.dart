import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:gewerber_app/application/time_billing/time_billing_cubit.dart';
import 'package:gewerber_app/application/time_tracking/projects_cubit.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';
import 'package:gewerber_app/domain/repositories/time_tracking_repository.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/time_billing_screen.dart';

/// In-memory time-tracking repository driving the billing screen tests.
class _FakeTimeTrackingRepository implements TimeTrackingRepository {
  _FakeTimeTrackingRepository({
    required this.projects,
    required this.tasks,
    required this.entries,
  });

  final List<Project> projects;
  final List<Task> tasks;
  final List<TimeEntry> entries;

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

  // ── Unused members ──────────────────────────────────────────────────────

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
      startedAt: DateTime(2026, 8, 10 + id),
      stoppedAt: DateTime(2026, 8, 11 + id),
      durationMinutes: minutes,
      billable: true,
    );
  }

  Future<void> pumpBillingScreen(
    WidgetTester tester, {
    required _FakeTimeTrackingRepository repository,
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final projectsCubit = ProjectsCubit(repository);
    final billingCubit = TimeBillingCubit(repository);
    await projectsCubit.load(includeArchived: false);
    await billingCubit.setProject(1);
    // Mirror the screen: task rates are loaded for the selection.
    await projectsCubit.loadTasks(1);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const Scaffold()),
        GoRoute(
          path: '/billing',
          builder: (context, state) => const TimeBillingScreen(),
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
    router.push('/billing');
    await tester.pumpAndSettle();
  }

  testWidgets(
    'per-entry estimates use task rate, project fallback and sum up',
    (tester) async {
      await pumpBillingScreen(
        tester,
        repository: _FakeTimeTrackingRepository(
          projects: [Project(id: 1, name: 'Website', hourlyRateCents: 5000)],
          tasks: [
            Task(id: 11, projectId: 1, name: 'Design', hourlyRateCents: 6000),
            const Task(id: 12, projectId: 1, name: 'Meetings'),
          ],
          entries: [
            entry(1, taskId: 11, minutes: 60), // task rate → 6000 ¢
            entry(2, taskId: 12, minutes: 30), // project fallback → 2500 ¢
            entry(3, taskId: null, minutes: 15), // project fallback → 1250 ¢
          ],
        ),
      );

      expect(find.text(formatCents(6000)), findsOneWidget);
      expect(find.text(formatCents(2500)), findsOneWidget);
      expect(find.text(formatCents(1250)), findsOneWidget);
      // Estimated total of all shown entries.
      expect(find.text(formatCents(9750)), findsOneWidget);
      expect(find.text('Estimated total'), findsOneWidget);
      expect(
        find.textContaining('the final amount is calculated'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'entries without any rate show no estimate but still sum priced ones',
    (tester) async {
      await pumpBillingScreen(
        tester,
        repository: _FakeTimeTrackingRepository(
          projects: [const Project(id: 1, name: 'Internal')],
          tasks: [
            Task(id: 21, projectId: 1, name: 'Side job', hourlyRateCents: 6000),
          ],
          entries: [
            entry(1, taskId: 21, minutes: 60), // 6000 ¢
            entry(2, taskId: null, minutes: 45), // no rate anywhere → "—"
          ],
        ),
      );

      expect(find.text('—'), findsOneWidget);
      // The priced entry's estimate and the estimated total coincide.
      expect(find.text(formatCents(6000)), findsNWidgets(2));
      expect(find.text('Estimated total'), findsOneWidget);
    },
  );
}
