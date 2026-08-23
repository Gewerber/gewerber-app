import 'package:flutter/material.dart';

/// A single tappable entry inside a module/index screen.
class ModuleMenuTile extends StatelessWidget {
  const ModuleMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.enabled = true,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  /// Replaces the default chevron (e.g. with a progress indicator).
  final Widget? trailing;

  /// When false the tile is greyed out and not tappable.
  final bool enabled;

  /// Renders icon and title in the error color (danger zone entries).
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final foreground = destructive ? colors.error : colors.primary;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        enabled: enabled,
        leading: Icon(icon, color: foreground),
        title: Text(
          title,
          style: textTheme.bodyLarge?.copyWith(
            color: !enabled
                ? colors.outline
                : (destructive ? colors.error : null),
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
