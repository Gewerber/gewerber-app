import 'package:equatable/equatable.dart';

import 'package:gewerber_app/domain/entities/guidance.dart';

/// State of the guidance tips list.
class GuidanceState extends Equatable {
  const GuidanceState({
    this.tips = const [],
    this.isLoading = false,
    this.isLoaded = false,
    this.hasError = false,
  });

  /// Tips that have not been dismissed yet.
  final List<GuidanceTip> tips;

  /// Whether the tips are currently being loaded.
  final bool isLoading;

  /// Whether the tips have been loaded at least once.
  final bool isLoaded;

  /// Whether the last load failed.
  final bool hasError;

  GuidanceState copyWith({
    List<GuidanceTip>? tips,
    bool? isLoading,
    bool? isLoaded,
    bool? hasError,
  }) {
    return GuidanceState(
      tips: tips ?? this.tips,
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object?> get props => [tips, isLoading, isLoaded, hasError];
}
