import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// Client-side strength for a password.
enum PasswordStrength { weak, medium, strong }

/// Client-side password rules shown as hints.
///
/// The authoritative policy lives on the backend; this only drives the
/// strength meter UI.
abstract final class PasswordRules {
  PasswordRules._();

  static bool hasLength(String password) => password.length >= 8;

  static bool hasCaseMix(String password) =>
      password != password.toUpperCase() && password != password.toLowerCase();

  static bool hasDigit(String password) => password.contains(RegExp(r'[0-9]'));

  static bool hasSymbol(String password) =>
      password.contains(RegExp(r'[^0-9a-zA-Z]'));

  static PasswordStrength evaluate(String password) {
    final score = [
      hasLength(password),
      hasCaseMix(password),
      hasDigit(password),
      hasSymbol(password),
    ].where((rule) => rule).length;
    return switch (score) {
      <= 2 => PasswordStrength.weak,
      3 => PasswordStrength.medium,
      _ => PasswordStrength.strong,
    };
  }
}

/// Live password strength meter: segmented bar, label and rule checklist.
///
/// Hidden while the password is empty.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final strength = PasswordRules.evaluate(password);

    final (Color barColor, String label) = switch (strength) {
      PasswordStrength.weak => (colors.error, l10n.passwordStrengthWeak),
      PasswordStrength.medium => (
        colors.secondary,
        l10n.passwordStrengthMedium,
      ),
      PasswordStrength.strong => (colors.tertiary, l10n.passwordStrengthStrong),
    };
    final filledSegments = switch (strength) {
      PasswordStrength.weak => 1,
      PasswordStrength.medium => 2,
      PasswordStrength.strong => 3,
    };

    final meter = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // `Expanded` must be a direct child of this Row; wrapping it in
            // ExcludeSemantics broke the Flex parent data and threw an
            // assertion whenever the meter was rendered.
            Expanded(
              child: ExcludeSemantics(
                child: Row(
                  children: List.generate(3, (i) {
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      height: 6,
                      decoration: BoxDecoration(
                        color: i < filledSegments
                            ? barColor
                            : colors.outline.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),
            ),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: barColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            _Rule(
              met: PasswordRules.hasLength(password),
              label: l10n.passwordRuleLength,
            ),
            _Rule(
              met: PasswordRules.hasCaseMix(password),
              label: l10n.passwordRuleCase,
            ),
            _Rule(
              met: PasswordRules.hasDigit(password),
              label: l10n.passwordRuleDigit,
            ),
            _Rule(
              met: PasswordRules.hasSymbol(password),
              label: l10n.passwordRuleSymbol,
            ),
          ],
        ),
      ],
    );

    if (MediaQuery.disableAnimationsOf(context)) return meter;

    return meter
        .animate(onPlay: (controller) => controller.forward())
        .fadeIn(duration: 150.ms);
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: 16,
          color: met
              ? colors.primary
              : colors.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 4),
        // `Flexible` lets long localized labels wrap instead of overflowing
        // the row on narrow screens.
        Flexible(
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: met
                  ? colors.onSurfaceVariant
                  : colors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}
