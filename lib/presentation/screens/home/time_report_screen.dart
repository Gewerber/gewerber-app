import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/time_tracking/time_entries_cubit.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// TimeReportScreen — aggregated tracked time for a period.
class TimeReportScreen extends StatefulWidget {
  const TimeReportScreen({super.key});

  @override
  State<TimeReportScreen> createState() => _TimeReportScreenState();
}

class _TimeReportScreenState extends State<TimeReportScreen> {
  late DateTime _from;
  late DateTime _to;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _from = DateTime(now.year, now.month, 1);
    _to = DateTime(now.year, now.month, now.day, 23, 59);
    _load();
  }

  void _load() {
    context.read<TimeEntriesCubit>().loadReport(_from, _to);
  }

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _from,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _from = picked;
      if (_to.isBefore(_from)) _to = picked;
    });
    _load();
  }

  Future<void> _pickTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _to,
      firstDate: _from,
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(
      () => _to = DateTime(picked.year, picked.month, picked.day, 23, 59),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final report = context.watch<TimeEntriesCubit>().state.report;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.timeReportTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickFrom,
                  child: Text(formatDate(_from)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: GewerberTokens.space8,
                ),
                child: Text(l10n.timeReportUntil),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickTo,
                  child: Text(formatDate(_to)),
                ),
              ),
            ],
          ),
          const SizedBox(height: GewerberTokens.space16),
          if (report == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: GewerberTokens.space32),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: l10n.timeReportTotal,
                    value: formatMinutes(report.totalMinutes),
                  ),
                ),
                const SizedBox(width: GewerberTokens.space12),
                Expanded(
                  child: _SummaryCard(
                    label: l10n.timeReportBillable,
                    value: formatMinutes(report.billableMinutes),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GewerberTokens.space24),
            if (report.lines.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: GewerberTokens.space16,
                ),
                child: Text(l10n.timeReportEmpty),
              )
            else ...[
              Text(l10n.timeReportByProject, style: textTheme.titleMedium),
              const SizedBox(height: GewerberTokens.space8),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final line in report.lines)
                      ListTile(
                        dense: true,
                        title: Text(
                          [
                            line.projectName ?? l10n.timerNoProject,
                            if (line.taskName != null) line.taskName!,
                          ].join(' · '),
                        ),
                        subtitle: Text(
                          l10n.timeReportEntryCount(line.entryCount),
                        ),
                        trailing: Text(formatMinutes(line.totalMinutes)),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(GewerberTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: GewerberTokens.space4),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
