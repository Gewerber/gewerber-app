import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/settings/app_settings_cubit.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/widgets/auth/auth_primary_button.dart';

/// First onboarding step: pick the app theme and language.
///
/// Choices are applied immediately through [AppSettingsCubit], so the whole
/// app — including this very screen — reflects the selection right away. The
/// user can still change both later from the settings.
class PreferencesStep extends StatelessWidget {
  const PreferencesStep({super.key, required this.onContinue});

  /// Advances to the business setup step.
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final state = context.watch<AppSettingsCubit>().state;
    final cubit = context.read<AppSettingsCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.onboardingPreferencesSubtitle, style: textTheme.bodyLarge),
        const SizedBox(height: GewerberTokens.space24),
        Text(l10n.onboardingPreferencesTheme, style: textTheme.titleMedium),
        const SizedBox(height: GewerberTokens.space12),
        _OptionTile(
          icon: Icons.brightness_auto_outlined,
          title: l10n.themeSystem,
          subtitle: l10n.themeSystemHint,
          selected: state.isSystemTheme,
          onTap: () => cubit.setThemeMode(ThemeMode.system),
        ),
        _OptionTile(
          icon: Icons.light_mode_outlined,
          title: l10n.themeLight,
          selected: state.isLightTheme,
          onTap: () => cubit.setThemeMode(ThemeMode.light),
        ),
        _OptionTile(
          icon: Icons.dark_mode_outlined,
          title: l10n.themeDark,
          selected: state.isDarkTheme,
          onTap: () => cubit.setThemeMode(ThemeMode.dark),
        ),
        const SizedBox(height: GewerberTokens.space24),
        Text(l10n.onboardingPreferencesLanguage, style: textTheme.titleMedium),
        const SizedBox(height: GewerberTokens.space12),
        _OptionTile(
          icon: Icons.translate_outlined,
          title: l10n.languageSystemDefault,
          subtitle: l10n.languageSystemHint,
          selected: state.isActiveLocale(null),
          onTap: cubit.useSystemLocale,
        ),
        _OptionTile(
          icon: Icons.translate_outlined,
          title: 'English',
          selected: state.isActiveLocale(const Locale('en')),
          onTap: () => cubit.setLocale(const Locale('en')),
        ),
        _OptionTile(
          icon: Icons.translate_outlined,
          title: 'Deutsch',
          selected: state.isActiveLocale(const Locale('de')),
          onTap: () => cubit.setLocale(const Locale('de')),
        ),
        _OptionTile(
          icon: Icons.translate_outlined,
          title: 'Русский',
          selected: state.isActiveLocale(const Locale('ru')),
          onTap: () => cubit.setLocale(const Locale('ru')),
        ),
        _OptionTile(
          icon: Icons.translate_outlined,
          title: 'Türkçe',
          selected: state.isActiveLocale(const Locale('tr')),
          onTap: () => cubit.setLocale(const Locale('tr')),
        ),
        const SizedBox(height: GewerberTokens.space32),
        AuthPrimaryButton(label: l10n.commonContinue, onPressed: onContinue),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(
          icon,
          color: selected ? colors.primary : colors.onSurfaceVariant,
        ),
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: selected
            ? Icon(Icons.check, color: colors.primary)
            : Icon(Icons.radio_button_unchecked, color: colors.outline),
        selected: selected,
        selectedTileColor: colors.primaryContainer.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
