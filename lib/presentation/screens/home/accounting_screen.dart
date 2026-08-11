import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/common/stub_menu_tile.dart';

/// Accounting tab — index of the upcoming sub-screens.
class AccountingScreen extends StatelessWidget {
  const AccountingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeAccounting)),
      floatingActionButton: FloatingActionButton(
        heroTag: 'accounting-fab',
        onPressed: () => context.push(RouteNames.accountingEntryCreate),
        tooltip: l10n.commonAdd,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StubMenuTile(
            icon: Icons.account_balance_outlined,
            title: l10n.accountingReportTitle,
            subtitle: l10n.accountingReportSubtitle,
            onTap: () => context.push(RouteNames.accountingReport),
          ),
          StubMenuTile(
            icon: Icons.playlist_add_outlined,
            title: l10n.accountingEntryCreateTitle,
            subtitle: l10n.accountingEntryCreateSubtitle,
            onTap: () => context.push(RouteNames.accountingEntryCreate),
          ),
        ],
      ),
    );
  }
}
