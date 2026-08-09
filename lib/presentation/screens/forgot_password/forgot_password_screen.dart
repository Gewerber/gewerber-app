import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';
import 'package:gewerber_app/presentation/widgets/layout/auth_panel_layout.dart';

/// Password reset flow screen: email → verification code → new password.
///
/// Steps advance through pure UI state; real endpoints are wired with the
/// forgot-password bloc later.
enum _ResetStep { email, code, password }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  _ResetStep _step = _ResetStep.email;
  bool _done = false;

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

  void _advance() {
    setState(() {
      switch (_step) {
        case _ResetStep.email:
          _step = _ResetStep.code;
        case _ResetStep.code:
          _step = _ResetStep.password;
        case _ResetStep.password:
          _done = true;
      }
    });
  }

  void _goBack() {
    if (_step == _ResetStep.email) return;
    setState(() => _step = _ResetStep.values[_step.index - 1]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    if (_done) {
      return AuthPanelLayout(
        showBackButton: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 40,
                color: colors.secondary,
              ),
            ),
            const SizedBox(height: GewerberTokens.space24),
            Text(l10n.forgotBackToLogin, style: textTheme.titleLarge),
            const SizedBox(height: GewerberTokens.space32),
            FilledButton(
              onPressed: () => context.go(RouteNames.login),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: GewerberTokens.space4,
                ),
                child: Text(l10n.forgotBackToLogin),
              ),
            ),
          ],
        ),
      );
    }

    return AuthPanelLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: switch (_step) {
              _ResetStep.email => _buildEmailStep(context, l10n),
              _ResetStep.code => _buildCodeStep(context, l10n),
              _ResetStep.password => _buildPasswordStep(context, l10n),
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmailStep(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('reset-email'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.forgotTitle, style: textTheme.headlineSmall),
        const SizedBox(height: GewerberTokens.space8),
        Text(
          l10n.forgotSubtitle,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: GewerberTokens.space32),
        CustomTextField(
          controller: _emailController,
          label: l10n.emailLabel,
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: GewerberTokens.space24),
        FilledButton(onPressed: _advance, child: Text(l10n.forgotSendCode)),
        const SizedBox(height: GewerberTokens.space12),
        TextButton(
          onPressed: () => context.go(RouteNames.login),
          child: Text(l10n.forgotBackToLogin),
        ),
      ],
    );
  }

  Widget _buildCodeStep(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('reset-code'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton.icon(
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back, size: 18),
          label: Text(l10n.commonBack),
        ),
        const SizedBox(height: GewerberTokens.space16),
        Text(l10n.forgotCodeStepTitle, style: textTheme.headlineSmall),
        const SizedBox(height: GewerberTokens.space8),
        Text(
          l10n.forgotCodeStepSubtitle(_emailController.text),
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: GewerberTokens.space32),
        CustomTextField(
          controller: _codeController,
          label: l10n.emailLabel,
          icon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: GewerberTokens.space8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.commonComingSoon)));
            },
            child: Text(l10n.resendCode),
          ),
        ),
        const SizedBox(height: GewerberTokens.space8),
        FilledButton(onPressed: _advance, child: Text(l10n.commonContinue)),
      ],
    );
  }

  Widget _buildPasswordStep(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('reset-password'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton.icon(
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back, size: 18),
          label: Text(l10n.commonBack),
        ),
        const SizedBox(height: GewerberTokens.space16),
        Text(l10n.forgotPasswordStepTitle, style: textTheme.headlineSmall),
        const SizedBox(height: GewerberTokens.space8),
        Text(
          l10n.forgotPasswordStepSubtitle,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: GewerberTokens.space32),
        CustomTextField(
          controller: _passwordController,
          label: l10n.passwordLabel,
          icon: Icons.lock_outline,
          obscure: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
        ),
        const SizedBox(height: GewerberTokens.space24),
        FilledButton(onPressed: _advance, child: Text(l10n.forgotSubmit)),
      ],
    );
  }
}
