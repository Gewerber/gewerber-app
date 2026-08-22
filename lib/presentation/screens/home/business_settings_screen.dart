import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/business_settings_form.dart';

/// BusinessSettingsScreen — invoice numbering and payment terms.
///
/// Thin route wrapper around [BusinessSettingsForm] (shared with the desktop
/// settings master-detail pane).
class BusinessSettingsScreen extends StatelessWidget {
  const BusinessSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).businessSettingsTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: const BusinessSettingsForm(),
          ),
        ),
      ),
    );
  }
}
