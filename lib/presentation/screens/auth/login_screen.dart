import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/auth/auth_state.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/domain/value_objects/email.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/auth/widgets/social_sign_in_row.dart';
import 'package:gewerber_app/presentation/widgets/auth/auth_error_banner.dart';
import 'package:gewerber_app/presentation/widgets/auth/auth_primary_button.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';
import 'package:gewerber_app/presentation/widgets/layout/auth_panel_layout.dart';

/// Email/password sign-in screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return AppLocalizations.of(context).loginEmailInvalid;
    }
    try {
      Email(email);
      return null;
    } on FormatException {
      return AppLocalizations.of(context).loginEmailInvalid;
    }
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return AppLocalizations.of(context).loginPasswordRequired;
    }
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.read<AuthCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  /// Failures surfaced by [SocialSignInRow] are not repeated inline here.
  Failure? _visibleFailure(AuthState state) {
    final failure = state.failure;
    if (failure == null || state.isSubmitting) {
      return null;
    }
    return switch (failure) {
      SocialAuthNotConfiguredFailure() => null,
      SocialAuthFailure() => null,
      _ => failure,
    };
  }

  String _failureMessage(Failure failure) {
    final l10n = AppLocalizations.of(context);
    return switch (failure) {
      InvalidCredentialsFailure() => l10n.loginInvalidCredentials,
      TooManyAttemptsFailure() => l10n.loginTooManyAttempts,
      UserBlockedFailure() => l10n.authUserBlocked,
      ValidationFailure() => l10n.authValidationError,
      NetworkFailure() => l10n.authNetworkError,
      _ => failure.toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.isAuthenticated) {
          context.go(RouteNames.app);
        }
      },
      child: AuthPanelLayout(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final failure = _visibleFailure(state);
            return Form(
              key: _formKey,
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
                  if (failure != null) ...[
                    AuthErrorBanner(
                      message: _failureMessage(failure),
                      onDismiss: () => context.read<AuthCubit>().clearFailure(),
                    ),
                  ],
                  CustomTextField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    label: l10n.emailLabel,
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: _validateEmail,
                    onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                  ),
                  const SizedBox(height: GewerberTokens.space16),
                  CustomTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
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
                    validator: _validatePassword,
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
                  AuthPrimaryButton(
                    label: l10n.loginCta,
                    isSubmitting: state.isSubmitting,
                    onPressed: _submit,
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
            );
          },
        ),
      ),
    );
  }
}
