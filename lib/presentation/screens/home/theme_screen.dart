import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/settings/app_settings_cubit.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// ThemeScreen — pick between system, light and dark appearance.
class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AppSettingsCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.themeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ThemeOptionTile(
            icon: Icons.brightness_auto_outlined,
            title: l10n.themeSystem,
            subtitle: l10n.themeSystemHint,
            selected: state.isSystemTheme,
            onTap: () {
              context.read<AppSettingsCubit>().setThemeMode(ThemeMode.system);
            },
          ),
          _ThemeOptionTile(
            icon: Icons.light_mode_outlined,
            title: l10n.themeLight,
            selected: state.isLightTheme,
            onTap: () {
              context.read<AppSettingsCubit>().setThemeMode(ThemeMode.light);
            },
          ),
          _ThemeOptionTile(
            icon: Icons.dark_mode_outlined,
            title: l10n.themeDark,
            selected: state.isDarkTheme,
            onTap: () {
              context.read<AppSettingsCubit>().setThemeMode(ThemeMode.dark);
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
    );
  }
}
