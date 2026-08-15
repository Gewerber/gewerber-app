import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/auth/auth_state.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/auth/widgets/social_sign_in_row.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';
import 'package:gewerber_app/presentation/widgets/layout/auth_panel_layout.dart';

/// Email/password sign-in screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<AuthCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.failure != current.failure,
      listener: (context, state) {
        if (state.isAuthenticated) {
          context.go(RouteNames.app);
        } else if (state.failure != null && !state.isSubmitting) {
          final message = switch (state.failure) {
            InvalidCredentialsFailure() => l10n.loginInvalidCredentials,
            TooManyAttemptsFailure() => l10n.loginTooManyAttempts,
            UserBlockedFailure() => l10n.authUserBlocked,
            SocialAuthNotConfiguredFailure() => l10n.commonSocialUnavailable,
            ValidationFailure() => l10n.authValidationError,
            _ => state.failure!.toString(),
          };
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      child: AuthPanelLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.loginTitle, style: textTheme.headlineSmall),
            const SizedBox(height: GewerberTokens.space8),
            Text(
              l10n.loginSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: GewerberTokens.space32),
            CustomTextField(
              controller: _emailController,
              label: l10n.emailLabel,
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: GewerberTokens.space16),
            CustomTextField(
              controller: _passwordController,
              label: l10n.passwordLabel,
              icon: Icons.lock_outline,
              obscure: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                tooltip: _obscurePassword
                    ? l10n.passwordShow
                    : l10n.passwordHide,
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: GewerberTokens.space8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go(RouteNames.forgotPassword),
                child: Text(l10n.loginForgotPassword),
              ),
            ),
            const SizedBox(height: GewerberTokens.space16),
            BlocBuilder<AuthCubit, AuthState>(
              buildWhen: (previous, current) =>
                  previous.isSubmitting != current.isSubmitting,
              builder: (context, state) {
                return FilledButton(
                  onPressed: state.isSubmitting ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: GewerberTokens.space4,
                    ),
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.loginCta),
                  ),
                );
              },
            ),
            const SizedBox(height: GewerberTokens.space12),
            TextButton(
              onPressed: () {
                context.read<AuthCubit>().login(
                  email: 'demo@gewerber.de',
                  password: 'demo-password',
                );
              },
              child: Text(l10n.loginDemoCta),
            ),
            const SizedBox(height: GewerberTokens.space8),
            Text(
              l10n.loginDemoHint,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: GewerberTokens.space24),
            const SocialSignInRow(),
            const SizedBox(height: GewerberTokens.space24),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.loginNoAccount,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(RouteNames.register),
                  child: Text(l10n.loginCreateAccount),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
