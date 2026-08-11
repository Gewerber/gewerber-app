import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/module_placeholder.dart';

/// DashboardScreen — future overview of invoices, time and P&L.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModulePlaceholder(
      icon: Icons.space_dashboard_outlined,
      title: AppLocalizations.of(context).homeDashboard,
    );
  }
}
