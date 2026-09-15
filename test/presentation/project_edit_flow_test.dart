import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/time_tracking/projects_cubit.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_customer_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_time_tracking_repository.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/projects_screen.dart';

/// Mock repository that records the project passed to [updateProject].
class _RecordingTimeTrackingRepository extends MockTimeTrackingRepository {
  Project? lastUpdatedProject;

  @override
  Future<Project> updateProject(Project project) async {
    lastUpdatedProject = project;
    return super.updateProject(project);
  }
}

Future<void> _pumpProjectsScreen(
  WidgetTester tester, {
  required _RecordingTimeTrackingRepository repository,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ProjectsCubit>.value(value: ProjectsCubit(repository)),
          BlocProvider<CustomerCubit>(
            create: (_) => CustomerCubit(MockCustomerRepository())..load(),
          ),
        ],
        child: const ProjectsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Expands the tile of [projectName] and taps its edit action.
Future<void> _openEditDialog(WidgetTester tester, String projectName) async {
  await tester.tap(find.text(projectName));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Edit project'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('edit action opens a dialog pre-filled with current values', (
    tester,
  ) async {
    final repository = _RecordingTimeTrackingRepository();
    await repository.createProject(name: 'Website', hourlyRateCents: 8500);
    await _pumpProjectsScreen(tester, repository: repository);

    await _openEditDialog(tester, 'Website');

    expect(find.text('Edit project'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'Website'),
      findsOneWidget,
      reason: 'name field must start with the current project name',
    );
    expect(
      find.widgetWithText(TextField, '85.00'),
      findsOneWidget,
      reason: 'rate field must show the current rate in euro input format',
    );
  });

  testWidgets('saving the edit dialog updates name and hourly rate', (
    tester,
  ) async {
    final repository = _RecordingTimeTrackingRepository();
    await repository.createProject(name: 'Website', hourlyRateCents: 8500);
    await _pumpProjectsScreen(tester, repository: repository);

    await _openEditDialog(tester, 'Website');

    await tester.enterText(find.widgetWithText(TextField, 'Website'), 'Shop');
    await tester.enterText(find.widgetWithText(TextField, '85.00'), '90.50');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repository.lastUpdatedProject, isNotNull);
    expect(repository.lastUpdatedProject!.name, 'Shop');
    expect(repository.lastUpdatedProject!.hourlyRateCents, 9050);
    // The list reflects the change and the dialog is gone.
    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('Edit project'), findsNothing);
  });

  testWidgets('clearing the rate field saves a null hourly rate', (
    tester,
  ) async {
    final repository = _RecordingTimeTrackingRepository();
    await repository.createProject(name: 'Website', hourlyRateCents: 8500);
    await _pumpProjectsScreen(tester, repository: repository);

    await _openEditDialog(tester, 'Website');

    await tester.enterText(find.widgetWithText(TextField, '85.00'), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repository.lastUpdatedProject, isNotNull);
    expect(repository.lastUpdatedProject!.name, 'Website');
    expect(repository.lastUpdatedProject!.hourlyRateCents, isNull);
  });

  testWidgets('dismiss via Back does not call updateProject', (tester) async {
    final repository = _RecordingTimeTrackingRepository();
    await repository.createProject(name: 'Website', hourlyRateCents: 8500);
    await _pumpProjectsScreen(tester, repository: repository);

    await _openEditDialog(tester, 'Website');

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Edit project'), findsNothing);
    expect(repository.lastUpdatedProject, isNull);
  });

  testWidgets('create flow still works through the shared form', (
    tester,
  ) async {
    final repository = _RecordingTimeTrackingRepository();
    await _pumpProjectsScreen(tester, repository: repository);

    await tester.tap(find.text('New project'));
    await tester.pumpAndSettle();

    // The create dialog opens empty with the "New project" title.
    expect(find.widgetWithText(AlertDialog, 'New project'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Project name'),
      'Marketing',
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Marketing'), findsOneWidget);
    final projects = await repository.listProjects();
    expect(projects.single.name, 'Marketing');
    expect(projects.single.hourlyRateCents, isNull);
  });
}
