import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/auth/auth_state.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/social_auth_remote_data_source.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// Row of social identity-provider buttons shown on auth screens.
///
/// A provider is offered only when its flow reports itself as configured for
/// this build ([SocialAuthRemoteDataSource.isConfigured]), which is the single
/// source of truth: it covers both the platform matrix and the
/// platform-specific credentials (e.g. the Google iOS client id, the Apple web
/// redirect URI). The check is asynchronous, so nothing is rendered until the
/// answer is known — a button that renders and then always fails is worse than
/// a short delay.
///
/// Taps delegate to [AuthCubit.socialLogin]. A provider the backend has
/// disabled, or one that rejects the credential, surfaces a snackbar with a
/// localized generic message (the raw provider error only goes to the debug
/// log). Cancelling a provider sheet is silent. The button of the provider being
/// signed in with shows a loading spinner and all social buttons are disabled
/// while any auth operation is in flight.
class SocialSignInRow extends StatefulWidget {
  const SocialSignInRow({super.key, this.dataSource});

  /// Overrides the flow-configuration lookup, for tests.
  final SocialAuthRemoteDataSource? dataSource;

  @override
  State<SocialSignInRow> createState() => _SocialSignInRowState();
}

class _SocialSignInRowState extends State<SocialSignInRow> {
  /// Providers whose flow reported itself configured, or `null` while the
  /// lookup is still running.
  Set<SocialAuthProvider>? _offered;

  /// Set once the first answer arrived; keeps the row from re-resolving on
  /// every rebuild.
  bool _resolved = false;

  /// The lookup target of the in-flight resolution; guards against a stale
  /// answer after the widget was rebuilt with a different data source.
  SocialAuthRemoteDataSource? _dataSource;

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? const SocialAuthRemoteDataSource();
    _resolve();
  }

  @override
  void didUpdateWidget(SocialSignInRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataSource != widget.dataSource) {
      _offered = null;
      _resolved = false;
      _dataSource = widget.dataSource ?? const SocialAuthRemoteDataSource();
      _resolve();
    }
  }

  void _resolve() {
    final dataSource = _dataSource!;
    _resolveOffered(dataSource).then((offered) {
      if (!mounted || !identical(dataSource, _dataSource)) {
        // The widget was rebuilt with a different data source (or disposed)
        // before the answer arrived.
        return;
      }
      setState(() {
        _offered = offered;
        _resolved = true;
      });
    });
  }

  static Future<Set<SocialAuthProvider>> _resolveOffered(
    SocialAuthRemoteDataSource dataSource,
  ) async {
    final offered = <SocialAuthProvider>{};
    for (final provider in SocialAuthProvider.values) {
      if (await dataSource.isConfigured(provider)) {
        offered.add(provider);
      }
    }
    return offered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (!_resolved) {
      // The configuration lookup is still in flight (it resolves in a
      // microtask); the parent rebuilds when it completes.
      return const SizedBox.shrink();
    }

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.failure != current.failure && !current.isSubmitting,
      listener: (context, state) {
        final message = switch (state.failure) {
          SocialAuthNotConfiguredFailure() => l10n.commonSocialUnavailable,
          // The provider's own message is diagnostic detail, not user-facing
          // copy: show a localized generic failure instead.
          SocialAuthFailure(:final message) => _reportFailure(message),
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
          final offered = _offered;
          if (offered == null) {
            // Still resolving; render nothing rather than a partial row.
            return const SizedBox.shrink();
          }
          final providers = SocialAuthProvider.values
              .where(offered.contains)
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

  /// Maps a provider failure to the localized generic snackbar text and logs
  /// the raw provider message in debug builds only.
  String _reportFailure(String? detail) {
    if (kDebugMode && detail != null && detail.isNotEmpty) {
      debugPrint('Social sign-in failed: $detail');
    }
    return AppLocalizations.of(context).socialSignInFailed;
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
