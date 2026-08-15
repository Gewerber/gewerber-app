import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/settings/app_settings_cubit.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// LanguageSelector — pick the app language (extracted for master-detail).
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AppSettingsCubit>().state;
    final active = context.read<AppSettingsCubit>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _LanguageTile(
          title: l10n.languageSystemDefault,
          subtitle: l10n.languageSystemHint,
          selected: state.isActiveLocale(null),
          onTap: active.useSystemLocale,
        ),
        const Divider(height: 24),
        _LanguageTile(
          title: 'English',
          selected: state.isActiveLocale(const Locale('en')),
          onTap: () => active.setLocale(const Locale('en')),
        ),
        _LanguageTile(
          title: 'Deutsch',
          selected: state.isActiveLocale(const Locale('de')),
          onTap: () => active.setLocale(const Locale('de')),
        ),
        _LanguageTile(
          title: 'Русский',
          selected: state.isActiveLocale(const Locale('ru')),
          onTap: () => active.setLocale(const Locale('ru')),
        ),
        _LanguageTile(
          title: 'Türkçe',
          selected: state.isActiveLocale(const Locale('tr')),
          onTap: () => active.setLocale(const Locale('tr')),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        Icons.translate_outlined,
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
