import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/module_placeholder.dart';

/// InvoiceCreateScreen — future invoice create/edit form stub.
class InvoiceCreateScreen extends StatelessWidget {
  const InvoiceCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ModulePlaceholder(
      icon: Icons.add_circle_outline,
      title: l10n.invoicesCreateTitle,
      subtitle: l10n.invoicesCreateSubtitle,
    );
  }
}
