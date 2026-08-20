import 'package:flutter/material.dart';

/// Horizontal step indicator for multi-step auth flows.
///
/// Completed steps show a check mark, the current step is filled, upcoming
/// steps are outlined. Announced to assistive technology as a single
/// "step x of y" label.
class AuthStepIndicator extends StatelessWidget {
  const AuthStepIndicator({
    super.key,
    required this.labels,
    required this.currentIndex,
  });

  final List<String> labels;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label:
          'Step ${currentIndex + 1} of ${labels.length}: '
          '${labels[currentIndex]}',
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 11, left: 8, right: 8),
                  child: Container(
                    height: 2,
                    color: i <= currentIndex ? colors.primary : colors.outline,
                  ),
                ),
              ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepDot(
                  completed: i < currentIndex,
                  current: i == currentIndex,
                ),
                const SizedBox(height: 4),
                Text(
                  labels[i],
                  style: textTheme.bodySmall?.copyWith(
                    color: i == currentIndex
                        ? colors.onSurface
                        : colors.onSurfaceVariant,
                    fontWeight: i == currentIndex ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.completed, required this.current});

  final bool completed;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final active = completed || current;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? colors.primary : Colors.transparent,
        border: Border.all(
          color: active ? colors.primary : colors.outline,
          width: 2,
        ),
      ),
      child: completed
          ? Icon(Icons.check_rounded, size: 14, color: colors.onPrimary)
          : null,
    );
  }
}
