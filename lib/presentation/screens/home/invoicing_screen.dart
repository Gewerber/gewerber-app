import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/common/stub_menu_tile.dart';

/// Invoicing module — index stub listing the upcoming sub-screens.
class InvoicingScreen extends StatelessWidget {
  const InvoicingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeInvoicing)),
      floatingActionButton: FloatingActionButton(
        heroTag: 'invoicing-fab',
        onPressed: () => context.push(RouteNames.invoiceCreate),
        tooltip: l10n.commonAdd,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StubMenuTile(
            icon: Icons.add_circle_outline,
            title: l10n.invoicesCreateTitle,
            subtitle: l10n.invoicesCreateSubtitle,
            onTap: () => context.push(RouteNames.invoiceCreate),
          ),
          StubMenuTile(
            icon: Icons.receipt_long_outlined,
            title: l10n.invoicesDetailTitle,
            subtitle: l10n.invoicesDetailSubtitle,
            onTap: () => context.push(RouteNames.invoiceDetail),
          ),
        ],
      ),
    );
  }
}
