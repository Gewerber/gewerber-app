import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/auth/widgets/social_sign_in_row.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';
import 'package:gewerber_app/presentation/widgets/layout/auth_panel_layout.dart';

/// Registration flow screen: email → verification code → set password.
///
/// The stepper advances through pure UI state for now; each step's "Continue"
/// is wired to the real endpoints together with the register bloc.
enum _RegisterStep { email, code, password }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  _RegisterStep _step = _RegisterStep.email;
  bool _done = false;

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

  void _advance() {
    setState(() {
      switch (_step) {
        case _RegisterStep.email:
          _step = _RegisterStep.code;
        case _RegisterStep.code:
          _step = _RegisterStep.password;
        case _RegisterStep.password:
          _done = true;
      }
    });
  }

  void _goBack() {
    if (_step == _RegisterStep.email) return;
    setState(() {
      _step = _RegisterStep.values[_step.index - 1];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_done) {
      return AuthPanelLayout(
        showBackButton: false,
        child: _SuccessView(
          title: l10n.registerSuccessTitle,
          subtitle: l10n.registerSuccessSubtitle,
          onContinue: () => context.go(RouteNames.app),
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
              _RegisterStep.email => _buildEmailStep(context, l10n),
              _RegisterStep.code => _buildCodeStep(context, l10n),
              _RegisterStep.password => _buildPasswordStep(context, l10n),
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
      key: const ValueKey('email'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.registerTitle, style: textTheme.headlineSmall),
        const SizedBox(height: GewerberTokens.space8),
        Text(
          l10n.registerEmailStepSubtitle,
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
        FilledButton(onPressed: _advance, child: Text(l10n.registerContinue)),
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

  Widget _buildCodeStep(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('code'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton.icon(
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back, size: 18),
          label: Text(l10n.commonBack),
        ),
        const SizedBox(height: GewerberTokens.space16),
        Text(l10n.registerCodeStepTitle, style: textTheme.headlineSmall),
        const SizedBox(height: GewerberTokens.space8),
        Text(
          l10n.registerCodeStepSubtitle(_emailController.text),
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
        const SizedBox(height: GewerberTokens.space12),
        Text(
          l10n.registerCodeHint,
          style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
        ),
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
        const SizedBox(height: GewerberTokens.space16),
        FilledButton(onPressed: _advance, child: Text(l10n.registerContinue)),
      ],
    );
  }

  Widget _buildPasswordStep(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      key: const ValueKey('password'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton.icon(
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back, size: 18),
          label: Text(l10n.commonBack),
        ),
        const SizedBox(height: GewerberTokens.space16),
        Text(l10n.registerPasswordStepTitle, style: textTheme.headlineSmall),
        const SizedBox(height: GewerberTokens.space8),
        Text(
          l10n.registerPasswordStepSubtitle,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
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
        ),
        const SizedBox(height: GewerberTokens.space24),
        FilledButton(
          onPressed: _advance,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: GewerberTokens.space4,
            ),
            child: Text(l10n.loginCta),
          ),
        ),
      ],
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
