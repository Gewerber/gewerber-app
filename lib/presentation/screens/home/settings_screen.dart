import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/common/stub_menu_tile.dart';

/// SettingsScreen — static stub: profile, language, guides, about.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StubMenuTile(
            icon: Icons.storefront_outlined,
            title: l10n.settingsBusinessProfile,
            onTap: () => context.push(RouteNames.settingsBusiness),
          ),
          StubMenuTile(
            icon: Icons.language_outlined,
            title: l10n.settingsLanguage,
            onTap: () => context.push(RouteNames.settingsLanguage),
          ),
          StubMenuTile(
            icon: Icons.brightness_6_outlined,
            title: l10n.settingsTheme,
            onTap: () => context.push(RouteNames.settingsTheme),
          ),
          StubMenuTile(
            icon: Icons.lightbulb_outline,
            title: l10n.settingsGuides,
            onTap: () => context.push(RouteNames.guides),
          ),
          StubMenuTile(
            icon: Icons.info_outline,
            title: l10n.settingsAbout,
            onTap: () => context.push(RouteNames.settingsAbout),
          ),
          StubMenuTile(
            icon: Icons.logout_outlined,
            title: l10n.settingsSignOut,
            onTap: () {
              context.read<AuthCubit>().logOut();
              context.go(RouteNames.login);
            },
          ),
        ],
      ),
    );
  }
}
