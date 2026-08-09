import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/common/stub_menu_tile.dart';

/// SettingsScreen — static stub: profile, language, guides, about.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    void comingSoon() {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.commonComingSoon)));
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StubMenuTile(
            icon: Icons.storefront_outlined,
            title: l10n.settingsBusinessProfile,
            onTap: () => context.go(RouteNames.settingsBusiness),
          ),
          StubMenuTile(
            icon: Icons.language_outlined,
            title: l10n.settingsLanguage,
            onTap: () => context.go(RouteNames.settingsLanguage),
          ),
          StubMenuTile(
            icon: Icons.lightbulb_outline,
            title: l10n.settingsGuides,
            onTap: () => context.go(RouteNames.guides),
          ),
          StubMenuTile(
            icon: Icons.info_outline,
            title: l10n.settingsAbout,
            onTap: () => context.go(RouteNames.settingsAbout),
          ),
          StubMenuTile(
            icon: Icons.logout_outlined,
            title: l10n.settingsSignOut,
            onTap: comingSoon,
          ),
        ],
      ),
    );
  }
}