import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/auth/auth_state.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/brand/brand_logo.dart';

/// Splash / landing screen shown on app launch.
///
/// Restores the persisted session via [AuthCubit] and redirects: signed-in
/// users go to the app shell, everyone else to the login screen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            context.go(RouteNames.app);
          case AuthStatus.unauthenticated:
            context.go(RouteNames.login);
          case AuthStatus.unknown:
            break;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(GewerberTokens.space32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    const SizedBox(height: GewerberTokens.space24),
                    const BrandLogo(size: 56),
                    const SizedBox(height: GewerberTokens.space16),
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: GewerberTokens.space8),
                    Text(
                      l10n.splashSubtitle,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: GewerberTokens.space40),
                    FilledButton(
                      onPressed: () => context.go(RouteNames.register),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: GewerberTokens.space4,
                        ),
                        child: Text(l10n.splashGetStarted),
                      ),
                    ),
                    const SizedBox(height: GewerberTokens.space12),
                    OutlinedButton(
                      onPressed: () => context.go(RouteNames.login),
                      child: Text(l10n.splashLogIn),
                    ),
                    const SizedBox(height: GewerberTokens.space24),
                    Text(
                      l10n.splashPrivacy,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
