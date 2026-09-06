import 'package:flutter/material.dart';

import 'package:gewerber_app/core/theme/gewerber_tokens.dart';

/// Unified empty/failure state: icon + centered message + optional action.
///
/// Replaces the private `_EmptyState` duplicates that previously existed on
/// the list screens. Use it for empty data, empty search results, and list
/// errors. Pass a retry or call-to-action button as [action] when the state
/// offers one.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.action,
    this.compact = false,
  });

  /// Icon shown above the message.
  final IconData icon;

  /// Centered explanation of why the area is empty or failed to load.
  final String message;

  /// Optional call-to-action (e.g. a retry button) rendered below the
  /// message; built by the calling code.
  final Widget? action;

  /// Compact mode for small areas and cards: tighter padding and a smaller
  /// icon.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          compact ? GewerberTokens.space16 : GewerberTokens.space32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 40 : 56, color: colors.outline),
            const SizedBox(height: GewerberTokens.space16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
            if (action != null) ...[
              const SizedBox(height: GewerberTokens.space16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
