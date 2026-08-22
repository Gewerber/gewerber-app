import 'package:flutter/material.dart';

/// A single tappable entry inside a module/index stub screen.
class StubMenuTile extends StatelessWidget {
  const StubMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  /// Replaces the default chevron (e.g. with a progress indicator).
  final Widget? trailing;

  /// When false the tile is greyed out and not tappable.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        enabled: enabled,
        leading: Icon(icon, color: colors.primary),
        title: Text(
          title,
          style: textTheme.bodyLarge?.copyWith(
            color: enabled ? null : colors.outline,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: textTheme.bodySmall?.copyWith(
                  color: enabled ? colors.onSurfaceVariant : colors.outline,
                ),
              ),
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
