import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/auth/auth_state.dart';
import 'package:gewerber_app/core/config/social_provider_availability.dart';
import 'package:gewerber_app/core/config/social_provider_config.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// Row of social identity-provider buttons shown on auth screens.
///
/// Taps delegate to [AuthCubit.socialLogin]; failures (e.g. a provider the
/// backend has disabled) surface as a snackbar. Cancelling a provider sheet is
/// silent. The button of the provider being signed in with shows a loading
/// spinner and all social buttons are disabled while any auth operation is in
/// flight.
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
          // Cancelling the provider sheet is not an error.
          SocialAuthCancelledFailure() => null,
          _ => null,
        };
        if (message != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final providers = SocialAuthProvider.values
              .where(_isOffered)
              .toList(growable: false);
          if (providers.isEmpty) {
            return const SizedBox.shrink();
          }

          final busy = state.isSubmitting;
          final activeProvider = state.submittingProvider;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        l10n.commonOrContinueWith,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
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
                  for (final provider in providers)
                    _ProviderButton(
                      label: _labelFor(l10n, provider),
                      icon: _iconFor(provider),
                      isLoading: activeProvider == provider,
                      onPressed: busy ? null : () => _signIn(context, provider),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// A provider is offered when this build can run its flow and the OAuth
  /// credentials are present.
  static bool _isOffered(SocialAuthProvider provider) {
    return SocialProviderAvailability.isAvailableNow(provider) &&
        SocialProviderConfig.isConfigured(provider);
  }

  static String _labelFor(AppLocalizations l10n, SocialAuthProvider provider) {
    return switch (provider) {
      SocialAuthProvider.google => l10n.commonGoogle,
      SocialAuthProvider.apple => l10n.commonApple,
      SocialAuthProvider.facebook => l10n.commonFacebook,
      SocialAuthProvider.microsoft => l10n.commonMicrosoft,
    };
  }

  static IconData _iconFor(SocialAuthProvider provider) {
    return switch (provider) {
      SocialAuthProvider.google => Icons.g_mobiledata,
      SocialAuthProvider.apple => Icons.apple,
      SocialAuthProvider.facebook => Icons.facebook,
      // No Microsoft glyph ships with Material Icons.
      SocialAuthProvider.microsoft => Icons.window,
    };
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
    this.isLoading = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: 20),
      label: Text(label),
    );
  }
}
