import 'package:equatable/equatable.dart';

import 'package:gewerber_app/domain/entities/guidance.dart';

/// State of the getting-started checklist.
class ChecklistState extends Equatable {
  const ChecklistState({
    this.items = const [],
    this.completedIds = const {},
    this.isLoading = false,
    this.isLoaded = false,
    this.supportsUnmark = true,
  });

  /// The checklist items served by the guidance system.
  final List<GuidanceChecklistItem> items;

  /// Keys of the checklist items the user has completed.
  final Set<String> completedIds;

  /// Whether the checklist is currently being loaded.
  final bool isLoading;

  /// Whether the checklist has been loaded at least once.
  final bool isLoaded;

  /// Whether completed items can be reverted (demo mode only; server
  /// guidance progress is one-way).
  final bool supportsUnmark;

  bool isCompleted(String id) => completedIds.contains(id);

  int get completedCount =>
      completedIds.where((id) => items.any((item) => item.key == id)).length;

  bool get allDone =>
      isLoaded && items.isNotEmpty && completedCount == items.length;

  ChecklistState copyWith({
    List<GuidanceChecklistItem>? items,
    Set<String>? completedIds,
    bool? isLoading,
    bool? isLoaded,
    bool? supportsUnmark,
  }) {
    return ChecklistState(
      items: items ?? this.items,
      completedIds: completedIds ?? this.completedIds,
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      supportsUnmark: supportsUnmark ?? this.supportsUnmark,
    );
  }

  @override
  List<Object?> get props => [
    items,
    completedIds,
    isLoading,
    isLoaded,
    supportsUnmark,
  ];
}
