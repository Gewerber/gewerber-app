import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';

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
  ///
  /// The destructive nature is also exposed to assistive technologies:
  /// the tile reads as one node labelled `"<title>, <danger zone>"`, so
  /// the warning never relies on color alone.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final foreground = destructive ? colors.error : colors.primary;
    final l10n = AppLocalizations.of(context);

    final tile = ListTile(
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
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      // Danger-zone entries get an explicit semantic label so screen
      // readers announce the destructive context, not just the title.
      child: destructive
          ? Semantics(
              label: '$title, ${l10n.settingsDangerZone}',
              child: MergeSemantics(child: tile),
            )
          : tile,
    );
  }
}
