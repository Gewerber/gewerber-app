import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/forgot_password/forgot_password_cubit.dart';
import 'package:gewerber_app/application/forgot_password/forgot_password_state.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/domain/value_objects/email.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/auth/auth_error_banner.dart';
import 'package:gewerber_app/presentation/widgets/auth/auth_primary_button.dart';
import 'package:gewerber_app/presentation/widgets/auth/auth_step_indicator.dart';
import 'package:gewerber_app/presentation/widgets/auth/auth_success_view.dart';
import 'package:gewerber_app/presentation/widgets/auth/password_strength_meter.dart';
import 'package:gewerber_app/presentation/widgets/auth/verification_code_input.dart';
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
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
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

  List<String> _stepLabels(AppLocalizations l10n) => [
    l10n.forgotStepEmail,
    l10n.forgotStepCode,
    l10n.forgotStepPassword,
  ];

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
    final l10n = AppLocalizations.of(context);
    final password = value ?? '';
    if (password.isEmpty) {
      return l10n.loginPasswordRequired;
    }
    if (password.length < 8) {
      return l10n.authPasswordPolicy;
    }
    return null;
  }

  void _submitEmail(ForgotPasswordCubit cubit) {
    if (!(_emailFormKey.currentState?.validate() ?? false)) {
      return;
    }
    cubit.submitEmail(_emailController.text.trim());
  }

  void _resendCode(ForgotPasswordCubit cubit) {
    cubit.submitEmail(_emailController.text.trim());
  }

  void _submitPassword(ForgotPasswordCubit cubit) {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) {
      return;
    }
    cubit.submitPassword(_passwordController.text);
  }

  Failure? _visibleFailure(ForgotPasswordState state) {
    if (state.isSubmitting) return null;
    return state.failure;
  }

  String _failureMessage(Failure failure, AppLocalizations l10n) {
    return switch (failure) {
      InvalidVerificationCodeFailure() => l10n.registerCodeInvalid,
      ExpiredVerificationCodeFailure() => l10n.registerCodeExpired,
      PasswordPolicyViolationFailure() => l10n.authPasswordPolicy,
      ValidationFailure() => l10n.authValidationError,
      NetworkFailure() => l10n.authNetworkError,
      _ => failure.toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider<ForgotPasswordCubit>(
      create: (_) => getIt<ForgotPasswordCubit>(),
      child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
        buildWhen: (previous, current) =>
            previous.step != current.step ||
            previous.isSubmitting != current.isSubmitting ||
            previous.failure != current.failure,
        builder: (context, state) {
          final failure = _visibleFailure(state);
          return switch (state.step) {
            ForgotPasswordStep.email => AuthPanelLayout(
              child: _buildEmailStep(context, l10n, state, failure),
            ),
            ForgotPasswordStep.code => AuthPanelLayout(
              onBack: () => context.read<ForgotPasswordCubit>().goBack(),
              child: _buildCodeStep(context, l10n, state, failure),
            ),
            ForgotPasswordStep.password => AuthPanelLayout(
              onBack: () => context.read<ForgotPasswordCubit>().goBack(),
              child: _buildPasswordStep(context, l10n, state, failure),
            ),
            ForgotPasswordStep.completed => AuthPanelLayout(
              showBackButton: false,
              child: AuthSuccessView(
                title: l10n.forgotSuccessTitle,
                subtitle: l10n.forgotSuccessSubtitle,
                onContinue: () => context.go(RouteNames.login),
              ),
            ),
          };
        },
      ),
    );
  }

  Widget _buildEmailStep(
    BuildContext context,
    AppLocalizations l10n,
    ForgotPasswordState state,
    Failure? failure,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('reset-email'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthStepIndicator(labels: _stepLabels(l10n), currentIndex: 0),
        const SizedBox(height: GewerberTokens.space32),
        Text(l10n.forgotTitle, style: textTheme.headlineSmall),
        const SizedBox(height: GewerberTokens.space8),
        Text(
          l10n.forgotSubtitle,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: GewerberTokens.space32),
        if (failure != null) ...[
          AuthErrorBanner(
            message: _failureMessage(failure, l10n),
            onDismiss: () => context.read<ForgotPasswordCubit>().clearFailure(),
          ),
        ],
        Form(
          key: _emailFormKey,
          child: CustomTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            label: l10n.emailLabel,
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            validator: _validateEmail,
            onSubmitted: (_) =>
                _submitEmail(context.read<ForgotPasswordCubit>()),
          ),
        ),
        const SizedBox(height: GewerberTokens.space24),
        AuthPrimaryButton(
          label: l10n.forgotSendCode,
          isSubmitting: state.isSubmitting,
          onPressed: () => _submitEmail(context.read<ForgotPasswordCubit>()),
        ),
        const SizedBox(height: GewerberTokens.space12),
        TextButton(
          onPressed: () => context.go(RouteNames.login),
          child: Text(l10n.forgotBackToLogin),
        ),
      ],
    );
  }

  Widget _buildCodeStep(
    BuildContext context,
    AppLocalizations l10n,
    ForgotPasswordState state,
    Failure? failure,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('reset-code'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthStepIndicator(labels: _stepLabels(l10n), currentIndex: 1),
        const SizedBox(height: GewerberTokens.space16),
        Text(l10n.forgotCodeStepTitle, style: textTheme.headlineSmall),
        const SizedBox(height: GewerberTokens.space8),
        Text(
          l10n.forgotCodeStepSubtitle(state.email ?? ''),
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: GewerberTokens.space32),
        if (failure != null) ...[
          AuthErrorBanner(
            message: _failureMessage(failure, l10n),
            onDismiss: () => context.read<ForgotPasswordCubit>().clearFailure(),
          ),
        ],
        VerificationCodeInput(
          length: 6,
          enabled: !state.isSubmitting,
          hasError: failure != null,
          semanticsLabel: l10n.forgotCodeStepTitle,
          onCompleted: (code) =>
              context.read<ForgotPasswordCubit>().submitCode(code.trim()),
        ),
        const SizedBox(height: GewerberTokens.space8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _resendCode(context.read<ForgotPasswordCubit>()),
            child: Text(l10n.resendCode),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep(
    BuildContext context,
    AppLocalizations l10n,
    ForgotPasswordState state,
    Failure? failure,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('reset-password'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthStepIndicator(labels: _stepLabels(l10n), currentIndex: 2),
        const SizedBox(height: GewerberTokens.space16),
        Text(l10n.forgotPasswordStepTitle, style: textTheme.headlineSmall),
        const SizedBox(height: GewerberTokens.space8),
        Text(
          l10n.forgotPasswordStepSubtitle,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: GewerberTokens.space32),
        if (failure != null) ...[
          AuthErrorBanner(
            message: _failureMessage(failure, l10n),
            onDismiss: () => context.read<ForgotPasswordCubit>().clearFailure(),
          ),
        ],
        Form(
          key: _passwordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                autofillHints: const [AutofillHints.newPassword],
                validator: _validatePassword,
                onSubmitted: (_) =>
                    _submitPassword(context.read<ForgotPasswordCubit>()),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _passwordController,
                builder: (context, value, _) =>
                    PasswordStrengthMeter(password: value.text),
              ),
            ],
          ),
        ),
        const SizedBox(height: GewerberTokens.space24),
        AuthPrimaryButton(
          label: l10n.forgotSubmit,
          isSubmitting: state.isSubmitting,
          onPressed: () => _submitPassword(context.read<ForgotPasswordCubit>()),
        ),
      ],
    );
  }
}
