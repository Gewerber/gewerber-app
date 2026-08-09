import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// Row of social identity-provider buttons shown on auth screens.
///
/// Purely presentational for now: taps surface a "coming soon" message.
/// Real sign-in flows are wired together with the authentication layer.
class SocialSignInRow extends StatelessWidget {
  const SocialSignInRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                l10n.commonOrContinueWith,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ProviderButton(
              label: l10n.commonGoogle,
              icon: Icons.g_mobiledata,
              onPressed: () => _comingSoon(context),
            ),
            _ProviderButton(
              label: l10n.commonApple,
              icon: Icons.apple,
              onPressed: () => _comingSoon(context),
            ),
            // Facebook is feature-gated: rendered once the backend provider
            // and its configuration exist (see core/config/social_auth_config).
            _ProviderButton(
              label: l10n.commonFacebook,
              icon: Icons.facebook,
              onPressed: () => _comingSoon(context),
            ),
          ],
        ),
      ],
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).commonSocialUnavailable),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}
