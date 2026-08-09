import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/module_placeholder.dart';

/// TimerScreen — future stopwatch time recorder stub.
class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ModulePlaceholder(
      icon: Icons.timer_outlined,
      title: l10n.timeTimerTitle,
      subtitle: l10n.timeTimerSubtitle,
    );
  }
}