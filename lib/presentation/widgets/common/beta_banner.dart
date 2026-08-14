import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// Persistent strip shown above the home shell while the product is in a
/// public beta: sets honest expectations and points to the feedback channel.
class BetaBanner extends StatelessWidget {
  const BetaBanner({super.key});

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            ],
          ),
        ),
      ),
    );
  }
}
