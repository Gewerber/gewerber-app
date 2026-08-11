import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/common/stub_menu_tile.dart';

/// GuidanceScreen — index of the guidance system (checklists, tips).
class GuidanceScreen extends StatelessWidget {
  const GuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.guidesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StubMenuTile(
            icon: Icons.checklist_outlined,
            title: l10n.checklistTitle,
            subtitle: l10n.checklistSubtitle,
            onTap: () => context.go(RouteNames.guideChecklist),
          ),
        ],
      ),
    );
  }
}
