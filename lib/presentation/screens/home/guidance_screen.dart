import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/guidance_index.dart';

/// GuidanceScreen — index of the guidance system (checklists, tips).
///
/// Thin route wrapper around [GuidanceIndex] (shared with the desktop settings
/// master-detail pane).
class GuidanceScreen extends StatelessWidget {
  const GuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).guidesTitle)),
      body: const GuidanceIndex(),
    );
  }
}
