import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/common/stub_menu_tile.dart';

/// GuidanceIndex — index of the guidance system (checklists, tips) for master-detail.
class GuidanceIndex extends StatelessWidget {
  const GuidanceIndex({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        StubMenuTile(
          icon: Icons.checklist_outlined,
          title: l10n.checklistTitle,
          subtitle: l10n.checklistSubtitle,
          onTap: () => context.push(RouteNames.guideChecklist),
        ),
      ],
    );
  }
}
