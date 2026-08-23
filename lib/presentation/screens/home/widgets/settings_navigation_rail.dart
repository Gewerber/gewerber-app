import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/settings_master_detail.dart'
    show SettingsSection;

/// SettingsNavigationRail — master pane for settings master-detail layout.
class SettingsNavigationRail extends StatelessWidget {
  const SettingsNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.sections,
    this.extended = true,
    this.isSigningOut = false,
    this.isDeletingAccount = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;

  /// Sections rendered before the sign-out destination.
  final List<SettingsSection> sections;

  /// Shows a spinner on the sign-out destination and disables it while the
  /// session is being cleared.
  final bool isSigningOut;

  /// Shows a spinner on the delete-account destination while the deletion
  /// request is in flight.
  final bool isDeletingAccount;

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
        for (final section in sections)
          NavigationRailDestination(
            icon: Icon(section.icon),
            selectedIcon: Icon(section.selectedIcon),
            label: Text(section.label(l10n)),
          ),
        NavigationRailDestination(
          icon: isSigningOut
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout_outlined),
          selectedIcon: isSigningOut
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout),
          label: Text(l10n.settingsSignOut),
        ),
        // Danger zone destination (irreversible account deletion).
        NavigationRailDestination(
          icon: isDeletingAccount
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.delete_forever_outlined, color: colors.error),
          selectedIcon: isDeletingAccount
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.delete_forever, color: colors.error),
          label: Text(l10n.settingsDeleteAccount),
        ),
      ],
    );
  }
}
