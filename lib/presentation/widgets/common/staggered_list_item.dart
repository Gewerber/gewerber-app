import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Wraps a child widget with a staggered fade-in + slide-up animation.
///
/// Use inside ListView.builder / ListView.separated to animate items as they
/// appear. The [index] determines the stagger delay — lower indices animate
/// first.
///
/// Respects [MediaQuery.disableAnimationsOf] and skips animation when true.
class StaggeredListItem extends StatelessWidget {
  const StaggeredListItem({
    super.key,
    required this.index,
    required this.child,
    this.delay = 50,
  });

  /// Position in the list (0-based). Determines the stagger delay.
  final int index;

  /// The list tile / card to animate.
  final Widget child;

  /// Base delay in milliseconds between consecutive items.
  final int delay;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final stagger = Duration(milliseconds: index * delay);

    return child
        .animate(delay: stagger)
        .fadeIn(duration: 250.ms, curve: Curves.easeOut)
        .slideY(
          begin: 0.05,
          end: 0,
          duration: 250.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
