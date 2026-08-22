import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/checklist_view.dart';

/// ChecklistScreen — step-by-step getting-started checklist.
class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.checklistTitle)),
      body: const ChecklistView(),
    );
  }
}
