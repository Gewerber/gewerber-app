import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/widgets/auth/auth_primary_button.dart';

/// Animated success confirmation with a check mark and a continue action.
///
/// Shared by the registration and password-reset flows.
class AuthSuccessView extends StatelessWidget {
  const AuthSuccessView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onContinue,
  });

  final String title;
  final String subtitle;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final check = Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_rounded,
        size: 40,
        color: colors.onSecondaryContainer,
      ),
    );
    final titleWidget = Text(
      title,
      style: textTheme.headlineSmall,
      textAlign: TextAlign.center,
    );
    final subtitleWidget = Text(
      subtitle,
      style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
      textAlign: TextAlign.center,
    );
    final button = AuthPrimaryButton(
      label: AppLocalizations.of(context).commonContinue,
      onPressed: onContinue,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        reduceMotion
            ? check
            : check
                  .animate()
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 300.ms),
        const SizedBox(height: GewerberTokens.space24),
        reduceMotion
            ? titleWidget
            : titleWidget
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 300.ms)
                  .moveY(begin: 0.1, duration: 300.ms, delay: 150.ms),
        const SizedBox(height: GewerberTokens.space8),
        reduceMotion
            ? subtitleWidget
            : subtitleWidget
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 300.ms)
                  .moveY(begin: 0.1, duration: 300.ms, delay: 250.ms),
        const SizedBox(height: GewerberTokens.space32),
        reduceMotion
            ? button
            : button.animate().fadeIn(delay: 350.ms, duration: 300.ms),
      ],
    );
  }
}
