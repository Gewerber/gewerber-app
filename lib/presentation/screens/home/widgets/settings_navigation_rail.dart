import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// SettingsNavigationRail — master pane for settings master-detail layout.
class SettingsNavigationRail extends StatelessWidget {
  const SettingsNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.extended = true,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return NavigationRail(
      extended: extended,
      minExtendedWidth: 280,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: colors.surfaceContainerLow,
      indicatorColor: colors.primaryContainer,
      selectedLabelTextStyle: TextStyle(
        color: colors.onPrimaryContainer,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: TextStyle(color: colors.onSurfaceVariant),
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.storefront_outlined),
          selectedIcon: const Icon(Icons.storefront),
          label: Text(l10n.settingsBusinessProfile),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.receipt_long_outlined),
          selectedIcon: const Icon(Icons.receipt_long),
          label: Text(l10n.settingsBusinessSettings),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.language_outlined),
          selectedIcon: const Icon(Icons.language),
          label: Text(l10n.settingsLanguage),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.brightness_6_outlined),
          selectedIcon: const Icon(Icons.brightness_6),
          label: Text(l10n.settingsTheme),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.lightbulb_outline),
          selectedIcon: const Icon(Icons.lightbulb),
          label: Text(l10n.settingsGuides),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.info_outline),
          selectedIcon: const Icon(Icons.info),
          label: Text(l10n.settingsAbout),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.logout_outlined),
          selectedIcon: const Icon(Icons.logout),
          label: Text(l10n.settingsSignOut),
        ),
      ],
    );
  }
}
