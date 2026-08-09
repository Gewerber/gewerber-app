import 'package:flutter/material.dart';

import 'package:gewerber_app/core/theme/app_theme.dart';

/// Minimal screen placeholder used before a module ships its real UI.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(GewerberTokens.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(
                      GewerberTokens.radiusCard,
                    ),
                  ),
                  child: Icon(icon, size: 28, color: colors.primary),
                ),
                const SizedBox(height: GewerberTokens.space16),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: GewerberTokens.space8),
                  Text(
                    subtitle!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
