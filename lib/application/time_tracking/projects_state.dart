import 'package:equatable/equatable.dart';

import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';

/// Loading state of the projects view.
enum ProjectsViewStatus { initial, loading, loaded, failure }

/// Immutable projects state.
class ProjectsState extends Equatable {
  const ProjectsState({
    this.status = ProjectsViewStatus.initial,
    this.projects = const [],
    this.tasks = const {},
    this.failure,
  });

  final ProjectsViewStatus status;
  final List<Project> projects;

  /// Tasks per project id (loaded on demand).
  final Map<int, List<Task>> tasks;
  final Failure? failure;

  bool get isLoading => status == ProjectsViewStatus.loading;

  List<Task> tasksOf(int projectId) => tasks[projectId] ?? const [];

  ProjectsState copyWith({
    ProjectsViewStatus? status,
    List<Project>? projects,
    Map<int, List<Task>>? tasks,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ProjectsState(
      status: status ?? this.status,
      projects: projects ?? this.projects,
      tasks: tasks ?? this.tasks,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, projects, tasks, failure];
}
