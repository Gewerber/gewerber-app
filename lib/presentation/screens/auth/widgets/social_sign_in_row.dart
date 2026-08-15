import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/auth/auth_state.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// Row of social identity-provider buttons shown on auth screens.
///
/// Taps delegate to [AuthCubit.socialLogin]; failures (e.g. a provider that
/// is not configured for the current build) surface as a snackbar.
class SocialSignInRow extends StatelessWidget {
  const SocialSignInRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.failure != current.failure && !current.isSubmitting,
      listener: (context, state) {
        final message = switch (state.failure) {
          SocialAuthNotConfiguredFailure() => l10n.commonSocialUnavailable,
          SocialAuthFailure(:final message) =>
            message ?? l10n.commonSocialUnavailable,
          _ => null,
        };
        if (message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      child: Column(
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
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _ProviderButton(
                label: l10n.commonGoogle,
                icon: Icons.g_mobiledata,
                onPressed: () => _signIn(context, SocialAuthProvider.google),
              ),
              _ProviderButton(
                label: l10n.commonApple,
                icon: Icons.apple,
                onPressed: () => _signIn(context, SocialAuthProvider.apple),
              ),
              // Facebook is feature-gated: rendered once the backend provider
              // and its configuration exist (see core/config/app_config.dart).
              _ProviderButton(
                label: l10n.commonFacebook,
                icon: Icons.facebook,
                onPressed: () => _signIn(context, SocialAuthProvider.facebook),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _signIn(BuildContext context, SocialAuthProvider provider) {
    context.read<AuthCubit>().socialLogin(provider);
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
