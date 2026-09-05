import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// Inline error banner shown above the form when an auth request fails.
///
/// Announced to assistive technology via a live region.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message, this.onDismiss});

  final String message;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final banner = Semantics(
      container: true,
      liveRegion: true,
      label: message,
      child: Container(
        margin: const EdgeInsets.only(bottom: GewerberTokens.space16),
        padding: const EdgeInsets.symmetric(
          horizontal: GewerberTokens.space12,
          vertical: GewerberTokens.space12,
        ),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(GewerberTokens.radiusCard),
          border: Border.all(color: colors.error.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 20,
              color: colors.onErrorContainer,
            ),
            const SizedBox(width: GewerberTokens.space8),
            Expanded(
              child: Text(
                message,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onErrorContainer,
                ),
              ),
            ),
            if (onDismiss != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: colors.onErrorContainer,
                ),
                tooltip: AppLocalizations.of(context).commonDismiss,
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );

    if (MediaQuery.disableAnimationsOf(context)) return banner;

    return banner
        .animate(onPlay: (controller) => controller.forward())
        .fadeIn(duration: 200.ms)
        .slide(begin: const Offset(-0.05, -0.05), duration: 200.ms);
  }
}
