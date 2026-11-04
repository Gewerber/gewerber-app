import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// Persistent strip shown above the home shell while the product is in a
/// public beta: sets honest expectations and points to the feedback channel.
class BetaBanner extends StatelessWidget {
  /// Creates a [BetaBanner].
  const BetaBanner({super.key, required this.onDismiss});

  /// Called when the user dismisses the banner.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSecondaryContainer;
    return Material(
      color: theme.colorScheme.secondaryContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 16,
            end: 4,
            top: 8,
            bottom: 8,
          ),
          child: Row(
            children: [
              Icon(Icons.science_outlined, size: 20, color: foreground),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: '${l10n.betaBannerTitle} · ',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foreground,
                    ),
                    children: [
                      TextSpan(
                        text: l10n.betaBannerText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.close_rounded, size: 18, color: foreground),
                onPressed: onDismiss,
                tooltip: l10n.commonDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
