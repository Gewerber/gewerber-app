import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/forgot_password/forgot_password_cubit.dart';
import 'package:gewerber_app/application/forgot_password/forgot_password_state.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';
import 'package:gewerber_app/presentation/widgets/layout/auth_panel_layout.dart';

/// Password reset flow screen: email → verification code → new password.
///
/// Each step is backed by [ForgotPasswordCubit]; the stepper advances once
/// the backend confirms the previous step.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider<ForgotPasswordCubit>(
      create: (_) => getIt<ForgotPasswordCubit>(),
      child: BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
        listenWhen: (previous, current) =>
            previous.failure != current.failure && !current.isSubmitting,
        listener: (context, state) {
          final message = _failureMessage(state, context);
          if (message != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        },
        child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
          buildWhen: (previous, current) =>
              previous.step != current.step ||
              previous.isSubmitting != current.isSubmitting,
          builder: (context, state) {
            return switch (state.step) {
              ForgotPasswordStep.email => AuthPanelLayout(
                child: _buildEmailStep(context, l10n),
              ),
              ForgotPasswordStep.code => AuthPanelLayout(
                child: _buildCodeStep(context, l10n),
              ),
              ForgotPasswordStep.password => AuthPanelLayout(
                child: _buildPasswordStep(context, l10n),
              ),
              ForgotPasswordStep.completed => AuthPanelLayout(
                showBackButton: false,
                child: _ResetSuccessView(
                  title: l10n.forgotSuccessTitle,
                  subtitle: l10n.forgotSuccessSubtitle,
                  onContinue: () => context.go(RouteNames.login),
                ),
              ),
            };
          },
        ),
      ),
    );
  }

  String? _failureMessage(ForgotPasswordState state, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (state.failure) {
      InvalidVerificationCodeFailure() => l10n.registerCodeInvalid,
      ExpiredVerificationCodeFailure() => l10n.registerCodeExpired,
      PasswordPolicyViolationFailure() => l10n.authPasswordPolicy,
      ValidationFailure() => l10n.authValidationError,
      _ => state.failure?.toString(),
    };
  }

  Widget _buildEmailStep(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
      buildWhen: (previous, current) =>
          previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        return Column(
          key: const ValueKey('reset-email'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.forgotTitle, style: textTheme.headlineSmall),
            const SizedBox(height: GewerberTokens.space8),
            Text(
              l10n.forgotSubtitle,
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
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              onSubmitted: (_) => context
                  .read<ForgotPasswordCubit>()
                  .submitEmail(_emailController.text.trim()),
            ),
            const SizedBox(height: GewerberTokens.space24),
            _PrimaryButton(
              isSubmitting: state.isSubmitting,
              label: l10n.forgotSendCode,
              onPressed: () => context.read<ForgotPasswordCubit>().submitEmail(
                _emailController.text.trim(),
              ),
            ),
            const SizedBox(height: GewerberTokens.space12),
            TextButton(
              onPressed: () => context.go(RouteNames.login),
              child: Text(l10n.forgotBackToLogin),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCodeStep(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
      buildWhen: (previous, current) =>
          previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        return Column(
          key: const ValueKey('reset-code'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton.icon(
              onPressed: context.read<ForgotPasswordCubit>().goBack,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(l10n.commonBack),
            ),
            const SizedBox(height: GewerberTokens.space16),
            Text(l10n.forgotCodeStepTitle, style: textTheme.headlineSmall),
            const SizedBox(height: GewerberTokens.space8),
            Text(
              l10n.forgotCodeStepSubtitle(state.email ?? ''),
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: GewerberTokens.space32),
            CustomTextField(
              controller: _codeController,
              label: l10n.forgotCodeStepTitle,
              icon: Icons.pin_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => context
                  .read<ForgotPasswordCubit>()
                  .submitCode(_codeController.text.trim()),
            ),
            const SizedBox(height: GewerberTokens.space8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context
                    .read<ForgotPasswordCubit>()
                    .submitEmail(_emailController.text.trim()),
                child: Text(l10n.resendCode),
              ),
            ),
            const SizedBox(height: GewerberTokens.space8),
            _PrimaryButton(
              isSubmitting: state.isSubmitting,
              label: l10n.commonContinue,
              onPressed: () => context.read<ForgotPasswordCubit>().submitCode(
                _codeController.text.trim(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPasswordStep(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
      buildWhen: (previous, current) =>
          previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        return Column(
          key: const ValueKey('reset-password'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton.icon(
              onPressed: context.read<ForgotPasswordCubit>().goBack,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(l10n.commonBack),
            ),
            const SizedBox(height: GewerberTokens.space16),
            Text(l10n.forgotPasswordStepTitle, style: textTheme.headlineSmall),
            const SizedBox(height: GewerberTokens.space8),
            Text(
              l10n.forgotPasswordStepSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: GewerberTokens.space32),
            CustomTextField(
              controller: _passwordController,
              label: l10n.passwordLabel,
              icon: Icons.lock_outline,
              obscure: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onSubmitted: (_) => context
                  .read<ForgotPasswordCubit>()
                  .submitPassword(_passwordController.text),
            ),
            const SizedBox(height: GewerberTokens.space24),
            _PrimaryButton(
              isSubmitting: state.isSubmitting,
              label: l10n.forgotSubmit,
              onPressed: () => context
                  .read<ForgotPasswordCubit>()
                  .submitPassword(_passwordController.text),
            ),
          ],
        );
      },
    );
  }
}

/// Primary flow button that shows a progress indicator while submitting.
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.isSubmitting,
    required this.label,
    required this.onPressed,
  });

  final bool isSubmitting;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isSubmitting ? null : onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: GewerberTokens.space4),
        child: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}

class _ResetSuccessView extends StatelessWidget {
  const _ResetSuccessView({
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, size: 40, color: colors.secondary),
        ),
        const SizedBox(height: GewerberTokens.space24),
        Text(
          title,
          style: textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: GewerberTokens.space8),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: GewerberTokens.space32),
        FilledButton(
          onPressed: onContinue,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: GewerberTokens.space4,
            ),
            child: Text(AppLocalizations.of(context).commonContinue),
          ),
        ),
      ],
    );
  }
}
