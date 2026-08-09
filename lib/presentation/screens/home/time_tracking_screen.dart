import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/common/stub_menu_tile.dart';

/// Time tracking tab — index of the upcoming sub-screens.
class TimeTrackingScreen extends StatelessWidget {
  const TimeTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTimeTracking)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(RouteNames.timeEntryCreate),
        tooltip: l10n.commonAdd,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StubMenuTile(
            icon: Icons.folder_outlined,
            title: l10n.timeProjectsTitle,
            subtitle: l10n.timeProjectsSubtitle,
            onTap: () => context.go(RouteNames.timeProjects),
          ),
          StubMenuTile(
            icon: Icons.timer_outlined,
            title: l10n.timeTimerTitle,
            subtitle: l10n.timeTimerSubtitle,
            onTap: () => context.go(RouteNames.timeTimer),
          ),
          StubMenuTile(
            icon: Icons.edit_calendar_outlined,
            title: l10n.timeEntryCreateTitle,
            subtitle: l10n.timeEntryCreateSubtitle,
            onTap: () => context.go(RouteNames.timeEntryCreate),
          ),
        ],
      ),
    );
  }
}