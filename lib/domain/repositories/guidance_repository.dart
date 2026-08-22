import 'package:gewerber_app/domain/entities/guidance.dart';

/// Contract for the server-driven guidance system (tips, checklists,
/// per-user progress).
abstract interface class GuidanceRepository {
  /// Whether progress can be reverted (un-completed).
  ///
  /// The backend only records completions, so server-synced progress is
  /// one-way; local (demo) progress can be toggled freely.
  bool get supportsUnmark;

  /// All contextual tips.
  Future<List<GuidanceTip>> tips();

  /// All checklists with their items.
  Future<List<GuidanceChecklist>> checklists();

  /// The keys of the checklist items the user has completed.
  Future<Set<String>> completedItemKeys();

  /// Marks a checklist item as completed.
  Future<void> markCompleted(String itemKey);

  /// Reverts a completion. Only supported when [supportsUnmark] is `true`.
  Future<void> unmarkCompleted(String itemKey);

  /// Dismisses a tip so it is not shown again.
  Future<void> dismissTip(String topic);
}
