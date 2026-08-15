import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/register/register_cubit.dart';
import 'package:gewerber_app/application/register/register_state.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/auth/widgets/social_sign_in_row.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';
import 'package:gewerber_app/presentation/widgets/layout/auth_panel_layout.dart';

/// Registration flow screen: email → verification code → set password.
///
/// Each step is backed by [RegisterCubit]; the stepper advances once the
/// backend confirms the previous step.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submitEmail(RegisterCubit cubit) =>
      cubit.submitEmail(_emailController.text.trim());

  void _submitCode(RegisterCubit cubit) =>
      cubit.submitCode(_codeController.text.trim());

  void _submitPassword(RegisterCubit cubit, BuildContext context) {
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).passwordMismatch)),
      );
      return;
    }
    cubit.submitPassword(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider<RegisterCubit>(
      create: (_) => getIt<RegisterCubit>(),
      child: BlocListener<RegisterCubit, RegisterState>(
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
        child: BlocBuilder<RegisterCubit, RegisterState>(
          buildWhen: (previous, current) =>
              previous.step != current.step ||
              previous.isSubmitting != current.isSubmitting,
          builder: (context, state) {
            return switch (state.step) {
              RegisterStep.email => AuthPanelLayout(
                child: _buildEmailStep(context, l10n),
              ),
              RegisterStep.code => AuthPanelLayout(
                child: _buildCodeStep(context, l10n),
              ),
              RegisterStep.password => AuthPanelLayout(
                child: _buildPasswordStep(context, l10n),
              ),
              RegisterStep.completed => AuthPanelLayout(
                showBackButton: false,
                child: _SuccessView(
                  title: l10n.registerSuccessTitle,
                  subtitle: l10n.registerSuccessSubtitle,
                  onContinue: () => context.go(RouteNames.app),
                ),
              ),
            };
          },
        ),
      ),
    );
  }

  String? _failureMessage(RegisterState state, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (state.failure) {
      EmailAlreadyRegisteredFailure() => l10n.registerEmailExists,
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

    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) =>
          previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        return Column(
          key: const ValueKey('email'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.registerTitle, style: textTheme.headlineSmall),
            const SizedBox(height: GewerberTokens.space8),
            Text(
              l10n.registerEmailStepSubtitle,
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
              onSubmitted: (_) => _submitEmail(context.read<RegisterCubit>()),
            ),
            const SizedBox(height: GewerberTokens.space24),
            _PrimaryButton(
              isSubmitting: state.isSubmitting,
              label: l10n.registerContinue,
              onPressed: () => _submitEmail(context.read<RegisterCubit>()),
            ),
            const SizedBox(height: GewerberTokens.space16),
            const SocialSignInRow(),
            const SizedBox(height: GewerberTokens.space16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.registerHaveAccount,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(RouteNames.login),
                  child: Text(l10n.reRegisterCta),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCodeStep(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) =>
          previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        return Column(
          key: const ValueKey('code'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton.icon(
              onPressed: context.read<RegisterCubit>().goBack,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(l10n.commonBack),
            ),
            const SizedBox(height: GewerberTokens.space16),
            Text(l10n.registerCodeStepTitle, style: textTheme.headlineSmall),
            const SizedBox(height: GewerberTokens.space8),
            Text(
              l10n.registerCodeStepSubtitle(state.email ?? ''),
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: GewerberTokens.space32),
            CustomTextField(
              controller: _codeController,
              label: l10n.registerCodeStepTitle,
              icon: Icons.pin_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submitCode(context.read<RegisterCubit>()),
            ),
            const SizedBox(height: GewerberTokens.space12),
            Text(
              l10n.registerCodeHint,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _submitEmail(context.read<RegisterCubit>()),
                child: Text(l10n.resendCode),
              ),
            ),
            const SizedBox(height: GewerberTokens.space16),
            _PrimaryButton(
              isSubmitting: state.isSubmitting,
              label: l10n.registerContinue,
              onPressed: () => _submitCode(context.read<RegisterCubit>()),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPasswordStep(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<RegisterCubit, RegisterState>(
      buildWhen: (previous, current) =>
          previous.isSubmitting != current.isSubmitting,
      builder: (context, state) {
        return Column(
          key: const ValueKey('password'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton.icon(
              onPressed: context.read<RegisterCubit>().goBack,
              icon: const Icon(Icons.arrow_back, size: 18),
              label: Text(l10n.commonBack),
            ),
            const SizedBox(height: GewerberTokens.space16),
            Text(
              l10n.registerPasswordStepTitle,
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: GewerberTokens.space8),
            Text(
              l10n.registerPasswordStepSubtitle,
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
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: GewerberTokens.space16),
            CustomTextField(
              controller: _confirmController,
              label: l10n.confirmPasswordLabel,
              icon: Icons.lock_outline,
              obscure: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              onSubmitted: (_) =>
                  _submitPassword(context.read<RegisterCubit>(), context),
            ),
            const SizedBox(height: GewerberTokens.space24),
            _PrimaryButton(
              isSubmitting: state.isSubmitting,
              label: l10n.loginCta,
              onPressed: () =>
                  _submitPassword(context.read<RegisterCubit>(), context),
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

class _SuccessView extends StatelessWidget {
  const _SuccessView({
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
