import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/widgets/common/beta_banner.dart';

/// Minimum width at which the shell switches from the bottom navigation bar
/// to a side [NavigationRail] (web-first layout).
const double _railBreakpoint = 900;

/// One navigation destination of the app shell, shared by the bottom
/// navigation bar (narrow screens) and the navigation rail (wide screens).
typedef _ShellDestination = ({
  IconData icon,
  IconData selectedIcon,
  String label,
});

/// Authenticated shell hosting the app's module navigation.
///
/// The active branch is rendered through [StatefulShellRoute.indexedStack],
/// keeping each module's state alive while switching tabs — regardless of
/// which navigation surface is shown. A persistent [BetaBanner] sits above
/// the branches while the product is in beta.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = _buildDestinations(l10n);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _railBreakpoint) {
          return Scaffold(
            body: Column(
              children: [
                const BetaBanner(),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Rail(
                        destinations: destinations,
                        selectedIndex: navigationShell.currentIndex,
                        onDestinationSelected: (index) =>
                            _selectBranch(context, index),
                        extended: constraints.maxWidth >= 1400,
                      ),
                      const VerticalDivider(thickness: 1, width: 1),
                      Expanded(child: navigationShell),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Column(
            children: [
              const BetaBanner(),
              Expanded(child: navigationShell),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => _selectBranch(context, index),
            destinations: [
              for (final (:icon, :selectedIcon, :label) in destinations)
                NavigationDestination(
                  icon: Icon(icon),
                  selectedIcon: Icon(selectedIcon),
                  label: label,
                ),
            ],
          ),
        );
      },
    );
  }

  void _selectBranch(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  List<_ShellDestination> _buildDestinations(AppLocalizations l10n) {
    return [
      (
        icon: Icons.space_dashboard_outlined,
        selectedIcon: Icons.space_dashboard,
        label: l10n.homeDashboard,
      ),
      (
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long,
        label: l10n.homeInvoicing,
      ),
      (
        icon: Icons.timer_outlined,
        selectedIcon: Icons.timer,
        label: l10n.homeTimeTracking,
      ),
      (
        icon: Icons.account_balance_outlined,
        selectedIcon: Icons.account_balance,
        label: l10n.homeAccounting,
      ),
      (
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: l10n.settingsTitle,
      ),
    ];
  }
}

/// Side navigation for wide screens. Extends to show labels beside the icons
/// when there is plenty of room, otherwise labels sit below the icons.
class _Rail extends StatelessWidget {
  const _Rail({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.extended,
  });

  final List<_ShellDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  /// Shows the labels beside the icons instead of below them.
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return NavigationRail(
      extended: extended,
      minExtendedWidth: 220,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: colors.surfaceContainerLow,
      labelType: extended ? null : NavigationRailLabelType.all,
      destinations: [
        for (final (:icon, :selectedIcon, :label) in destinations)
          NavigationRailDestination(
            icon: Icon(icon),
            selectedIcon: Icon(selectedIcon),
            label: Text(label),
          ),
      ],
    );
  }
}
