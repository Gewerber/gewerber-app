import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/module_placeholder.dart';

/// InvoiceDetailScreen — future single-invoice view stub.
class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ModulePlaceholder(
      icon: Icons.receipt_long_outlined,
      title: l10n.invoicesDetailTitle,
      subtitle: l10n.invoicesDetailSubtitle,
    );
  }
}