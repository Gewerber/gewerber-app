import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/guidance/guidance_cubit.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/widgets/common/empty_state.dart';

/// GuidanceTipsScreen — contextual tips served by the guidance system.
///
/// Content is curated centrally (currently in German); dismissing a tip hides
/// it for good.
class GuidanceTipsScreen extends StatefulWidget {
  const GuidanceTipsScreen({super.key});

  @override
  State<GuidanceTipsScreen> createState() => _GuidanceTipsScreenState();
}

class _GuidanceTipsScreenState extends State<GuidanceTipsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GuidanceCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<GuidanceCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tipsTitle)),
      body: switch ((state.isLoading, state.hasError, state.tips)) {
        (true, _, _) => const Center(child: CircularProgressIndicator()),
        (_, true, _) => EmptyState(
          icon: Icons.error_outline,
          message: l10n.tipsLoadError,
        ),
        (_, _, final tips) when tips.isEmpty => EmptyState(
          icon: Icons.lightbulb_outline,
          message: l10n.tipsEmpty,
        ),
        (_, _, final tips) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final tip in tips)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(GewerberTokens.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: GewerberTokens.space8),
                          Expanded(
                            child: Text(
                              tip.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.tipsDismiss,
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => context
                                .read<GuidanceCubit>()
                                .dismiss(tip.topic),
                          ),
                        ],
                      ),
                      const SizedBox(height: GewerberTokens.space8),
                      Text(tip.body),
                    ],
                  ),
                ),
              ),
          ],
        ),
      },
    );
  }
}
