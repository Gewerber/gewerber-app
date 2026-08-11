import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// Reusable placeholder body for an upcoming module screen.
///
/// Without business logic: an icon with a "coming soon" message. Optionally
/// shows a FAB when [onAdd] is provided (e.g. a tab stub linking to a
/// create form).
class ModulePlaceholder extends StatelessWidget {
  const ModulePlaceholder({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onAdd,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// When provided, a FAB is shown that invokes this callback.
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: onAdd == null
          ? null
          : FloatingActionButton(
              onPressed: onAdd,
              tooltip: l10n.commonAdd,
              child: const Icon(Icons.add),
            ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.moduleComingSoonTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle ?? l10n.moduleComingSoonSubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
