import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// Full-width primary action button with a built-in loading state.
///
/// Replaces the per-screen private button widgets; use for every primary
/// auth action (log in, continue, send code, update password).
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSubmitting = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FilledButton(
      onPressed: isSubmitting ? null : onPressed,
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      child: isSubmitting
          ? Semantics(
              liveRegion: true,
              label: '$label, ${l10n.commonLoading}',
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : Text(label),
    );
  }
}
