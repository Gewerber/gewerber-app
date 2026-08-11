import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/module_placeholder.dart';

/// TimeEntryCreateScreen — future manual time entry form stub.
class TimeEntryCreateScreen extends StatelessWidget {
  const TimeEntryCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ModulePlaceholder(
      icon: Icons.edit_calendar_outlined,
      title: l10n.timeEntryCreateTitle,
      subtitle: l10n.timeEntryCreateSubtitle,
    );
  }
}
