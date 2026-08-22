import 'package:equatable/equatable.dart';

/// A contextual tip served by the guidance system ("What is this?" popups).
class GuidanceTip extends Equatable {
  const GuidanceTip({
    required this.topic,
    required this.title,
    required this.body,
  });

  final String topic;
  final String title;
  final String body;

  @override
  List<Object?> get props => [topic, title, body];
}

/// A single item of a guidance checklist.
class GuidanceChecklistItem extends Equatable {
  const GuidanceChecklistItem({
    required this.key,
    required this.title,
    this.body,
  });

  final String key;
  final String title;
  final String? body;

  @override
  List<Object?> get props => [key, title, body];
}

/// A checklist definition served by the guidance system.
class GuidanceChecklist extends Equatable {
  const GuidanceChecklist({
    required this.key,
    required this.title,
    this.items = const [],
  });

  final String key;
  final String title;
  final List<GuidanceChecklistItem> items;

  @override
  List<Object?> get props => [key, title, items];
}
