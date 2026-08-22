import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/guidance/checklist_cubit.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/domain/entities/guidance.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// The getting-started checklist body.
///
/// Checklist content and progress come from the guidance system: in live mode
/// both are served by the backend, in demo mode a local catalog keeps the
/// experience fully functional offline.
class ChecklistView extends StatefulWidget {
  const ChecklistView({super.key});

  @override
  State<ChecklistView> createState() => _ChecklistViewState();
}

class _ChecklistViewState extends State<ChecklistView> {
  @override
  void initState() {
    super.initState();
    context.read<ChecklistCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<ChecklistCubit>().state;
    final allDone = state.allDone;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.checklistSubtitle,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: GewerberTokens.space16),
        _ProgressHeader(
          completed: state.completedCount,
          total: state.items.length,
          isLoading: state.isLoading,
        ),
        if (allDone) ...[
          const SizedBox(height: GewerberTokens.space16),
          _CompletionBanner(l10n: l10n),
        ],
        const SizedBox(height: GewerberTokens.space16),
        for (final item in state.items)
          _ChecklistTile(
            item: item,
            completed: state.isCompleted(item.key),
            canUnmark: state.supportsUnmark,
            onTap: () => context.read<ChecklistCubit>().toggle(item.key),
          ),
      ],
    );
  }
}

/// Maps well-known checklist item keys to icons; unknown server keys fall back
/// to a generic check icon.
IconData _iconFor(String key) {
  return switch (key) {
    'business_profile' ||
    'onboarding/business-profile' => Icons.storefront_outlined,
    'invoice_defaults' => Icons.receipt_long_outlined,
    'first_customer' ||
    'onboarding/first-customer' => Icons.person_add_outlined,
    'first_invoice' ||
    'onboarding/first-invoice' => Icons.request_quote_outlined,
    'vat_basics' || 'onboarding/kleinunternehmer' => Icons.percent_outlined,
    'personalize' => Icons.palette_outlined,
    _ => Icons.checklist_outlined,
  };
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.completed,
    required this.total,
    required this.isLoading,
  });

  final int completed;
  final int total;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).checklistProgress(completed, total),
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: total == 0 ? 0 : completed / total,
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),
        if (isLoading) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _CompletionBanner extends StatelessWidget {
  const _CompletionBanner({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.celebration_outlined, color: colors.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.checklistCompleteTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.checklistCompleteSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.item,
    required this.completed,
    required this.canUnmark,
    required this.onTap,
  });

  final GuidanceChecklistItem item;
  final bool completed;
  final bool canUnmark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Server guidance progress is one-way: completed items stay completed.
    final tappable = canUnmark || !completed;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        enabled: tappable,
        leading: Icon(
          _iconFor(item.key),
          color: completed ? colors.primary : colors.onSurfaceVariant,
        ),
        title: Text(item.title),
        subtitle: item.body == null ? null : Text(item.body!),
        trailing: completed
            ? Icon(Icons.check_circle, color: colors.primary)
            : Icon(Icons.radio_button_unchecked, color: colors.outline),
        onTap: tappable ? onTap : null,
      ),
    );
  }
}
