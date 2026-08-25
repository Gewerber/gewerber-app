import 'package:flutter/material.dart';

import 'package:gewerber_app/core/theme/gewerber_tokens.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// Shell for a dashboard-style section card with an optional tap-through
/// target.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.onTap,
  });

  final String title;
  final Widget child;

  /// When set, the whole card navigates to the module on tap.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(GewerberTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    // Announced as a heading so screen reader users can
                    // jump between the dashboard sections.
                    child: Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                ],
              ),
              const SizedBox(height: GewerberTokens.space12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline loading placeholder of a section body.
class SectionCardLoading extends StatelessWidget {
  const SectionCardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: GewerberTokens.space16),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

/// Inline error of a section body with a retry action.
class SectionCardError extends StatelessWidget {
  const SectionCardError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dashboardLoadError,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
      ],
    );
  }
}

/// Small rounded count badge used inside section cards.
///
/// Named `SectionBadge` to avoid clashing with [Badge] from
/// `package:flutter/material.dart`.
class SectionBadge extends StatelessWidget {
  const SectionBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GewerberTokens.space8,
        vertical: GewerberTokens.space2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GewerberTokens.radiusChip),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
