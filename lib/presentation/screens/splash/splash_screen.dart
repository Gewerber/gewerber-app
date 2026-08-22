import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    Widget entrance(Widget child, {Duration delay = Duration.zero}) {
      if (reduceMotion) return child;
      return child.animate().fadeIn(delay: delay, duration: 300.ms);
    }

    final logo = reduceMotion
        ? const Center(child: BrandLogo(size: 56))
        : const Center(child: BrandLogo(size: 56))
              .animate()
              .scale(
                begin: const Offset(0.6, 0.6),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 300.ms);

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
          // Scrollable so short viewports (small phones, landscape) do not
          // overflow: the content column can exceed the available height.
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.all(GewerberTokens.space32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        label: l10n.commonLoading,
                        child: const Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        ),
                      ),
                      const SizedBox(height: GewerberTokens.space24),
                      logo,
                      const SizedBox(height: GewerberTokens.space16),
                      entrance(
                        Text(
                          l10n.appTitle,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        delay: 150.ms,
                      ),
                      const SizedBox(height: GewerberTokens.space8),
                      entrance(
                        Text(
                          l10n.splashSubtitle,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        delay: 250.ms,
                      ),
                      const SizedBox(height: GewerberTokens.space40),
                      entrance(
                        FilledButton(
                          onPressed: () => context.go(RouteNames.register),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: GewerberTokens.space4,
                            ),
                            child: Text(l10n.splashGetStarted),
                          ),
                        ),
                        delay: 350.ms,
                      ),
                      const SizedBox(height: GewerberTokens.space12),
                      entrance(
                        OutlinedButton(
                          onPressed: () => context.go(RouteNames.login),
                          child: Text(l10n.splashLogIn),
                        ),
                        delay: 400.ms,
                      ),
                      const SizedBox(height: GewerberTokens.space24),
                      entrance(
                        Text(
                          l10n.splashPrivacy,
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        delay: 450.ms,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
