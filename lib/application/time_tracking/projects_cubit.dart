import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/time_tracking/projects_state.dart';
import 'package:gewerber_app/core/errors/error_handler.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/time_tracking.dart';
import 'package:gewerber_app/domain/repositories/time_tracking_repository.dart';

/// Owns the projects and tasks of the active business.
@LazySingleton()
class ProjectsCubit extends Cubit<ProjectsState> {
  ProjectsCubit(this._repository) : super(const ProjectsState());

  final TimeTrackingRepository _repository;

  /// Loads the projects.
  Future<void> load({bool includeArchived = true}) async {
    if (state.isLoading) return;
    emit(
      state.copyWith(status: ProjectsViewStatus.loading, clearFailure: true),
    );
    try {
      final projects = await _repository.listProjects();
      if (isClosed) return;
      final visible = includeArchived
          ? projects
          : projects.where((project) => !project.isArchived).toList();
      emit(ProjectsState(status: ProjectsViewStatus.loaded, projects: visible));
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ProjectsViewStatus.failure,
          failure: mapAppException(e),
        ),
      );
    } on Exception {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ProjectsViewStatus.failure,
          failure: const NetworkFailure(),
        ),
      );
    }
  }

  /// Creates a project. Returns `true` on success.
  Future<bool> createProject({
    required String name,
    int? customerId,
    int? hourlyRateCents,
    String? notes,
  }) async {
    try {
      final project = await _repository.createProject(
        name: name,
        customerId: customerId,
        hourlyRateCents: hourlyRateCents,
        notes: notes,
      );
      if (!isClosed) {
        emit(state.copyWith(projects: [...state.projects, project]));
      }
      return true;
    } on Exception {
      return false;
    }
  }

  /// Updates a project. Returns `true` on success.
  Future<bool> updateProject(Project project) async {
    try {
      final updated = await _repository.updateProject(project);
      if (!isClosed) {
        emit(
          state.copyWith(
            projects: [
              for (final current in state.projects)
                if (current.id == updated.id) updated else current,
            ],
          ),
        );
      }
      return true;
    } on Exception {
      return false;
    }
  }

  /// Deletes a project. Returns `true` on success.
  Future<bool> deleteProject(int projectId) async {
    try {
      await _repository.deleteProject(projectId);
      if (!isClosed) {
        final tasks = {...state.tasks}..remove(projectId);
        emit(
          state.copyWith(
            projects: state.projects
                .where((project) => project.id != projectId)
                .toList(),
            tasks: tasks,
          ),
        );
      }
      return true;
    } on Exception {
      return false;
    }
  }

  /// Loads the tasks of a project.
  Future<void> loadTasks(int projectId) async {
    try {
      final tasks = await _repository.listTasks(projectId);
      if (isClosed) return;
      emit(state.copyWith(tasks: {...state.tasks, projectId: tasks}));
    } on Exception {
      // Non-fatal: the project stays collapsed without tasks.
    }
  }

  /// Creates a task within a project. Returns `true` on success.
  Future<bool> createTask({
    required int projectId,
    required String name,
    int? hourlyRateCents,
  }) async {
    try {
      final task = await _repository.createTask(
        projectId: projectId,
        name: name,
        hourlyRateCents: hourlyRateCents,
      );
      if (!isClosed) {
        final current = state.tasksOf(projectId);
        emit(
          state.copyWith(
            tasks: {
              ...state.tasks,
              projectId: [...current, task],
            },
          ),
        );
      }
      return true;
    } on Exception {
      return false;
    }
  }

  /// Toggles the done state of a task. Returns `true` on success.
  Future<bool> toggleTask(Task task) async {
    final updated = task.copyWith(
      status: task.isDone ? TaskStatus.open : TaskStatus.done,
    );
    try {
      final saved = await _repository.updateTask(updated);
      if (!isClosed) {
        final current = state.tasksOf(task.projectId);
        emit(
          state.copyWith(
            tasks: {
              ...state.tasks,
              task.projectId: [
                for (final currentTask in current)
                  if (currentTask.id == saved.id) saved else currentTask,
              ],
            },
          ),
        );
      }
      return true;
    } on Exception {
      return false;
    }
  }
}
