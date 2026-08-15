import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/settings_detail_pane.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/settings_navigation_rail.dart';
import 'package:gewerber_app/presentation/widgets/common/stub_menu_tile.dart';

/// Breakpoint for two-pane master-detail layout (standard Material tablet breakpoint).
const double _settingsBreakpoint = 600;

/// SettingsMasterDetail — responsive settings screen with master-detail on desktop/tablet.
class SettingsMasterDetail extends StatefulWidget {
  const SettingsMasterDetail({super.key});

  @override
  State<SettingsMasterDetail> createState() => _SettingsMasterDetailState();
}

class _SettingsMasterDetailState extends State<SettingsMasterDetail> {
  int _selectedIndex = 0;

  void _onMobileTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.push(RouteNames.settingsBusiness);
        break;
      case 1:
        context.push(RouteNames.settingsBusinessSettings);
        break;
      case 2:
        context.push(RouteNames.settingsLanguage);
        break;
      case 3:
        context.push(RouteNames.settingsTheme);
        break;
      case 4:
        context.push(RouteNames.guides);
        break;
      case 5:
        context.push(RouteNames.settingsAbout);
        break;
      case 6:
        context.push(RouteNames.guideChecklist);
        break;
      case 7:
        _signOut(context);
        break;
    }
  }

  void _signOut(BuildContext context) {
    context.read<AuthCubit>().logOut();
    context.go(RouteNames.login);
  }

  // Desktop navigation - update detail pane in place
  void _onDesktopSelect(int index) {
    if (index == 7) {
      _signOut(context);
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _settingsBreakpoint;

        if (isDesktop) {
          return _buildDesktopLayout(context);
        }

        return _buildMobileLayout(context);
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).settingsTitle)),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Master pane - NavigationRail
          SizedBox(
            width: 280,
            child: SettingsNavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDesktopSelect,
              extended: true,
            ),
          ),
          // Vertical divider
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: Theme.of(context).dividerColor,
          ),
          // Detail pane - flexible
          Expanded(child: SettingsDetailPane(selectedIndex: _selectedIndex)),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StubMenuTile(
            icon: Icons.storefront_outlined,
            title: AppLocalizations.of(context).settingsBusinessProfile,
            onTap: () => _onMobileTap(context, 0),
          ),
          StubMenuTile(
            icon: Icons.receipt_long_outlined,
            title: AppLocalizations.of(context).settingsBusinessSettings,
            onTap: () => _onMobileTap(context, 1),
          ),
          StubMenuTile(
            icon: Icons.language_outlined,
            title: AppLocalizations.of(context).settingsLanguage,
            onTap: () => _onMobileTap(context, 2),
          ),
          StubMenuTile(
            icon: Icons.brightness_6_outlined,
            title: AppLocalizations.of(context).settingsTheme,
            onTap: () => _onMobileTap(context, 3),
          ),
          StubMenuTile(
            icon: Icons.lightbulb_outline,
            title: AppLocalizations.of(context).settingsGuides,
            onTap: () => _onMobileTap(context, 4),
          ),
          StubMenuTile(
            icon: Icons.info_outline,
            title: AppLocalizations.of(context).settingsAbout,
            onTap: () => _onMobileTap(context, 5),
          ),
          StubMenuTile(
            icon: Icons.logout_outlined,
            title: AppLocalizations.of(context).settingsSignOut,
            onTap: () => _onMobileTap(context, 7),
          ),
        ],
      ),
    );
  }
}
