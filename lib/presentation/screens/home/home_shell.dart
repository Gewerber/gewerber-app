import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/common/beta_banner.dart';

/// Authenticated shell hosting the bottom navigation bar.
///
/// The active branch is rendered through [StatefulShellRoute.indexedStack],
/// keeping each module's state alive while switching tabs. A persistent
/// [BetaBanner] sits above the branches while the product is in beta.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          const BetaBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.space_dashboard_outlined),
            selectedIcon: const Icon(Icons.space_dashboard),
            label: l10n.homeDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.homeInvoicing,
          ),
          NavigationDestination(
            icon: const Icon(Icons.timer_outlined),
            selectedIcon: const Icon(Icons.timer),
            label: l10n.homeTimeTracking,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_outlined),
            selectedIcon: const Icon(Icons.account_balance),
            label: l10n.homeAccounting,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settingsTitle,
          ),
        ],
      ),
    );
  }
}

/// Helper to navigate to a specific shell branch by route name.
void goToBranch(StatefulNavigationShell shell, String route) {
  switch (route) {
    case RouteNames.invoicing:
      shell.goBranch(1, initialLocation: route == RouteNames.invoicing);
      break;
    case RouteNames.timeTracking:
      shell.goBranch(2, initialLocation: route == RouteNames.timeTracking);
      break;
    case RouteNames.accounting:
      shell.goBranch(3, initialLocation: route == RouteNames.accounting);
      break;
    case RouteNames.settings:
      shell.goBranch(4, initialLocation: route == RouteNames.settings);
      break;
    default:
      shell.goBranch(0);
  }
}
