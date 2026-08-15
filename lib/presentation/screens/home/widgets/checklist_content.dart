import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/module_placeholder.dart';

/// ChecklistContent — step-by-step checklist view for master-detail.
class ChecklistContent extends StatelessWidget {
  const ChecklistContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ModulePlaceholder(
      icon: Icons.checklist_outlined,
      title: l10n.checklistTitle,
      subtitle: l10n.checklistSubtitle,
    );
  }
}
