import 'package:flutter/material.dart';

import 'package:gewerber_app/core/theme/gewerber_tokens.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/widgets/common/shimmer_loader.dart';

/// Shell for a dashboard-style section card with an optional tap-through
/// target.
///
/// When [onTap] is provided the card gains subtle hover elevation and a brief
/// press-to-scale feedback animation.
class SectionCard extends StatefulWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.onTap,
    this.accentColor,
  });

  final String title;
  final Widget child;

  /// When set, the whole card navigates to the module on tap.
  final VoidCallback? onTap;

  /// Optional left accent stripe color. When non-null a 3 px vertical bar is
  /// rendered inside the card along the leading edge, vertically rounded to
  /// match the card's [GewerberTokens.radiusCard] corners.
  final Color? accentColor;

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final hasInteraction = widget.onTap != null;

    Widget card = Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: _isHovered && hasInteraction ? 2 : 0,
      child: InkWell(
        onTap: widget.onTap,
        onTapDown: hasInteraction
            ? (_) => setState(() => _isPressed = true)
            : null,
        onTapUp: hasInteraction
            ? (_) => setState(() => _isPressed = false)
            : null,
        onTapCancel: hasInteraction
            ? () => setState(() => _isPressed = false)
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.accentColor != null)
              Container(width: 3, color: widget.accentColor),
            Expanded(
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
                              widget.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ),
                        if (widget.onTap != null)
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                      ],
                    ),
                    const SizedBox(height: GewerberTokens.space12),
                    widget.child,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (hasInteraction) {
      card = AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// Inline loading placeholder of a section body.
class SectionCardLoading extends StatelessWidget {
  const SectionCardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: GewerberTokens.space8),
      child: ShimmerLoader(lines: 2, height: 14),
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
