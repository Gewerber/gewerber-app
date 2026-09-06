import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/user_profile/user_profile_cubit.dart';
import 'package:gewerber_app/core/theme/gewerber_tokens.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/delete_account_dialog.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/settings_detail_pane.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/settings_navigation_rail.dart';
import 'package:gewerber_app/presentation/widgets/common/module_menu_tile.dart';

/// Settings sections shared by the mobile list and the desktop rail/pane.
///
/// The order defines both the rail index and the detail-pane index.
enum SettingsSection {
  profile,
  businessProfile,
  businessSettings,
  documents,
  language,
  theme,
  guides,
  about;

  /// The route pushed on narrow screens; `null` renders inline on desktop.
  String get routeName => switch (this) {
    SettingsSection.profile => RouteNames.settingsProfile,
    SettingsSection.businessProfile => RouteNames.settingsBusiness,
    SettingsSection.businessSettings => RouteNames.settingsBusinessSettings,
    SettingsSection.documents => RouteNames.settingsDocuments,
    SettingsSection.language => RouteNames.settingsLanguage,
    SettingsSection.theme => RouteNames.settingsTheme,
    SettingsSection.guides => RouteNames.guides,
    SettingsSection.about => RouteNames.settingsAbout,
  };

  IconData get icon => switch (this) {
    SettingsSection.profile => Icons.person_outline,
    SettingsSection.businessProfile => Icons.storefront_outlined,
    SettingsSection.businessSettings => Icons.receipt_long_outlined,
    SettingsSection.documents => Icons.folder_outlined,
    SettingsSection.language => Icons.language_outlined,
    SettingsSection.theme => Icons.brightness_6_outlined,
    SettingsSection.guides => Icons.lightbulb_outline,
    SettingsSection.about => Icons.info_outline,
  };

  IconData get selectedIcon => switch (this) {
    SettingsSection.profile => Icons.person,
    SettingsSection.businessProfile => Icons.storefront,
    SettingsSection.businessSettings => Icons.receipt_long,
    SettingsSection.documents => Icons.folder,
    SettingsSection.language => Icons.language,
    SettingsSection.theme => Icons.brightness_6,
    SettingsSection.guides => Icons.lightbulb,
    SettingsSection.about => Icons.info,
  };

  String label(AppLocalizations l10n) => switch (this) {
    SettingsSection.profile => l10n.settingsProfile,
    SettingsSection.businessProfile => l10n.settingsBusinessProfile,
    SettingsSection.businessSettings => l10n.settingsBusinessSettings,
    SettingsSection.documents => l10n.documentsTitle,
    SettingsSection.language => l10n.settingsLanguage,
    SettingsSection.theme => l10n.settingsTheme,
    SettingsSection.guides => l10n.settingsGuides,
    SettingsSection.about => l10n.settingsAbout,
  };
}

/// Sign-out is the second-to-last entry of the navigation surfaces and
/// "delete account" (danger zone) the very last one; neither is a detail pane
/// of its own.
final int _signOutIndex = SettingsSection.values.length;
final int _deleteAccountIndex = SettingsSection.values.length + 1;

/// SettingsMasterDetail — responsive settings screen with master-detail on desktop/tablet.
class SettingsMasterDetail extends StatefulWidget {
  const SettingsMasterDetail({super.key});

  @override
  State<SettingsMasterDetail> createState() => _SettingsMasterDetailState();
}

class _SettingsMasterDetailState extends State<SettingsMasterDetail> {
  int _selectedIndex = 0;
  bool _isSigningOut = false;
  bool _isDeletingAccount = false;

  void _onMobileTap(SettingsSection section) {
    context.push(section.routeName);
  }

  /// Clears the session and lets the router redirect to the login flow.
  ///
  /// Navigation is driven by the auth state: once [AuthCubit.logOut] emits
  /// [AuthStatus.unauthenticated], the app-level redirect sends the user to
  /// the login screen. This also resets the previous user's preferences and
  /// businesses (see `_AppView`).
  Future<void> _signOut() async {
    if (_isSigningOut) return;
    setState(() => _isSigningOut = true);
    try {
      await context.read<AuthCubit>().logOut();
    } finally {
      // The router may already have moved this screen out of the tree; only
      // reset the flag if the state is still mounted.
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  /// Asks for confirmation and permanently deletes the account.
  ///
  /// On success the local session is cleared so the router returns to the
  /// login screen. On failure a snackbar explains the problem and the user
  /// stays signed in (retry possible). While the request runs, both
  /// navigation surfaces show a blocking indicator.
  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteAccountConfirmDialog(),
    );
    if (confirmed != true || !mounted) return;
    if (_isDeletingAccount) return;
    setState(() => _isDeletingAccount = true);
    try {
      final deleted = await context.read<UserProfileCubit>().deleteAccount();
      if (!mounted) return;
      if (deleted) {
        await context.read<AuthCubit>().logOut();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.accountDeleteError)));
      }
    } finally {
      if (mounted) setState(() => _isDeletingAccount = false);
    }
  }

  // Desktop navigation - update detail pane in place. The sign-out and
  // delete-account destinations are the last rail entries; tapping them must
  // not select a detail pane.
  void _onDesktopSelect(int index) {
    if (index == _signOutIndex) {
      if (!_isSigningOut) _signOut();
    } else if (index == _deleteAccountIndex) {
      if (!_isDeletingAccount && !_isSigningOut) _deleteAccount();
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop =
            constraints.maxWidth >= GewerberTokens.breakpointCompact;

        if (isDesktop) {
          return _buildDesktopLayout(context, l10n);
        }

        return _buildMobileLayout(context, l10n);
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
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
              isSigningOut: _isSigningOut,
              isDeletingAccount: _isDeletingAccount,
              sections: SettingsSection.values,
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

  Widget _buildMobileLayout(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final section in SettingsSection.values)
            ModuleMenuTile(
              icon: section.icon,
              title: section.label(l10n),
              onTap: () => _onMobileTap(section),
            ),
          ModuleMenuTile(
            icon: Icons.logout_outlined,
            title: l10n.settingsSignOut,
            onTap: _signOut,
            enabled: !_isSigningOut && !_isDeletingAccount,
            trailing: _isSigningOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          // Danger zone: irreversible account deletion.
          ModuleMenuTile(
            icon: Icons.delete_forever_outlined,
            title: l10n.settingsDeleteAccount,
            onTap: _deleteAccount,
            enabled: !_isSigningOut && !_isDeletingAccount,
            destructive: true,
            trailing: _isDeletingAccount
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
