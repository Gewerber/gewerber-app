import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/module_placeholder.dart';

/// ReportScreen — future profit & loss report stub.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ModulePlaceholder(
      icon: Icons.insights_outlined,
      title: l10n.accountingReportTitle,
      subtitle: l10n.accountingReportSubtitle,
    );
  }
}