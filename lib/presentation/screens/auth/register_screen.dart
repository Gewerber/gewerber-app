import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/register/register_cubit.dart';
import 'package:gewerber_app/application/register/register_state.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/di/injection.dart';
import 'package:gewerber_app/domain/value_objects/email.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/auth/widgets/social_sign_in_row.dart';
import 'package:gewerber_app/presentation/widgets/auth/auth_error_banner.dart';
import 'package:gewerber_app/presentation/widgets/auth/auth_primary_button.dart';
import 'package:gewerber_app/presentation/widgets/auth/auth_step_indicator.dart';
import 'package:gewerber_app/presentation/widgets/auth/auth_success_view.dart';
import 'package:gewerber_app/presentation/widgets/auth/password_strength_meter.dart';
import 'package:gewerber_app/core/utils/constants.dart';
import 'package:gewerber_app/presentation/widgets/auth/verification_code_input.dart';
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
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  List<String> _stepLabels(AppLocalizations l10n) => [
    l10n.registerStepEmail,
    l10n.registerStepCode,
    l10n.registerStepPassword,
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

  String? _validateConfirm(String? value) {
    if (value != _passwordController.text) {
      return AppLocalizations.of(context).passwordMismatch;
    }
    return null;
  }

  void _submitEmail(RegisterCubit cubit) {
    if (!(_emailFormKey.currentState?.validate() ?? false)) {
      return;
    }
    cubit.submitEmail(_emailController.text.trim());
  }

  void _resendCode(RegisterCubit cubit) {
    cubit.submitEmail(_emailController.text.trim());
  }

  void _submitPassword(RegisterCubit cubit) {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) {
      return;
    }
    cubit.submitPassword(_passwordController.text);
  }

  Failure? _visibleFailure(RegisterState state) {
    if (state.isSubmitting) return null;
    return state.failure;
  }

  String _failureMessage(Failure failure, AppLocalizations l10n) {
    return switch (failure) {
      EmailAlreadyRegisteredFailure() => l10n.registerEmailExists,
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

    return BlocProvider<RegisterCubit>(
      create: (_) => getIt<RegisterCubit>(),
      child: BlocBuilder<RegisterCubit, RegisterState>(
        buildWhen: (previous, current) =>
            previous.step != current.step ||
            previous.isSubmitting != current.isSubmitting ||
            previous.failure != current.failure,
        builder: (context, state) {
          final failure = _visibleFailure(state);
          return switch (state.step) {
            RegisterStep.email => AuthPanelLayout(
              child: _buildEmailStep(context, l10n, state, failure),
            ),
            RegisterStep.code => AuthPanelLayout(
              onBack: () => context.read<RegisterCubit>().goBack(),
              child: _buildCodeStep(context, l10n, state, failure),
            ),
            RegisterStep.password => AuthPanelLayout(
              onBack: () => context.read<RegisterCubit>().goBack(),
              child: _buildPasswordStep(context, l10n, state, failure),
            ),
            RegisterStep.completed => AuthPanelLayout(
              showBackButton: false,
              child: AuthSuccessView(
                title: l10n.registerSuccessTitle,
                subtitle: l10n.registerSuccessSubtitle,
                onContinue: () => context.go(RouteNames.app),
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
    RegisterState state,
    Failure? failure,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('email'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthStepIndicator(labels: _stepLabels(l10n), currentIndex: 0),
        const SizedBox(height: GewerberTokens.space32),
        Text(l10n.registerTitle, style: textTheme.headlineSmall),
        const SizedBox(height: GewerberTokens.space8),
        Text(
          l10n.registerEmailStepSubtitle,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: GewerberTokens.space32),
        if (failure != null) ...[
          AuthErrorBanner(
            message: _failureMessage(failure, l10n),
            onDismiss: () => context.read<RegisterCubit>().clearFailure(),
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
            onSubmitted: (_) => _submitEmail(context.read<RegisterCubit>()),
          ),
        ),
        const SizedBox(height: GewerberTokens.space24),
        AuthPrimaryButton(
          label: l10n.registerContinue,
          isSubmitting: state.isSubmitting,
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
  }

  Widget _buildCodeStep(
    BuildContext context,
    AppLocalizations l10n,
    RegisterState state,
    Failure? failure,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('code'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthStepIndicator(labels: _stepLabels(l10n), currentIndex: 1),
        const SizedBox(height: GewerberTokens.space16),
        Text(l10n.registerCodeStepTitle, style: textTheme.headlineSmall),
        const SizedBox(height: GewerberTokens.space8),
        Text(
          l10n.registerCodeStepSubtitle(state.email ?? ''),
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: GewerberTokens.space32),
        if (failure != null) ...[
          AuthErrorBanner(
            message: _failureMessage(failure, l10n),
            onDismiss: () => context.read<RegisterCubit>().clearFailure(),
          ),
        ],
        VerificationCodeInput(
          length: AppConstants.verificationCodeLength,
          enabled: !state.isSubmitting,
          hasError: failure != null,
          semanticsLabel: l10n.registerCodeStepTitle,
          onCompleted: (code) =>
              context.read<RegisterCubit>().submitCode(code.trim()),
        ),
        const SizedBox(height: GewerberTokens.space12),
        Text(
          l10n.registerCodeHint,
          style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _resendCode(context.read<RegisterCubit>()),
            child: Text(l10n.resendCode),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep(
    BuildContext context,
    AppLocalizations l10n,
    RegisterState state,
    Failure? failure,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('password'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthStepIndicator(labels: _stepLabels(l10n), currentIndex: 2),
        const SizedBox(height: GewerberTokens.space16),
        Text(l10n.registerPasswordStepTitle, style: textTheme.headlineSmall),
        const SizedBox(height: GewerberTokens.space8),
        Text(
          l10n.registerPasswordStepSubtitle,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: GewerberTokens.space32),
        if (failure != null) ...[
          AuthErrorBanner(
            message: _failureMessage(failure, l10n),
            onDismiss: () => context.read<RegisterCubit>().clearFailure(),
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
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: _validatePassword,
                onSubmitted: (_) => _confirmFocusNode.requestFocus(),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _passwordController,
                builder: (context, value, _) =>
                    PasswordStrengthMeter(password: value.text),
              ),
              const SizedBox(height: GewerberTokens.space16),
              CustomTextField(
                controller: _confirmController,
                focusNode: _confirmFocusNode,
                label: l10n.confirmPasswordLabel,
                icon: Icons.lock_outline,
                obscure: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  tooltip: _obscureConfirm
                      ? l10n.passwordShow
                      : l10n.passwordHide,
                  onPressed: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                ),
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: _validateConfirm,
                onSubmitted: (_) =>
                    _submitPassword(context.read<RegisterCubit>()),
              ),
            ],
          ),
        ),
        const SizedBox(height: GewerberTokens.space24),
        AuthPrimaryButton(
          label: l10n.loginCta,
          isSubmitting: state.isSubmitting,
          onPressed: () => _submitPassword(context.read<RegisterCubit>()),
        ),
      ],
    );
  }
}
