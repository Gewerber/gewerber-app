import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/accounting/accounting_cubit.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// ReportScreen — basic profit & loss (EÜR style) for a period.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

enum _PeriodPreset { thisMonth, lastMonth, thisQuarter, thisYear }

class _ReportScreenState extends State<ReportScreen> {
  _PeriodPreset _preset = _PeriodPreset.thisMonth;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  (DateTime, DateTime) _rangeFor(_PeriodPreset preset) {
    final now = DateTime.now();
    return switch (preset) {
      _PeriodPreset.thisMonth => (
        DateTime(now.year, now.month, 1),
        DateTime(now.year, now.month, now.day, 23, 59),
      ),
      _PeriodPreset.lastMonth => (
        DateTime(now.year, now.month - 1, 1),
        DateTime(now.year, now.month, 0, 23, 59),
      ),
      _PeriodPreset.thisQuarter => (
        DateTime(now.year, ((now.month - 1) ~/ 3) * 3 + 1, 1),
        DateTime(now.year, now.month, now.day, 23, 59),
      ),
      _PeriodPreset.thisYear => (
        DateTime(now.year, 1, 1),
        DateTime(now.year, now.month, now.day, 23, 59),
      ),
    };
  }

  Future<void> _load() async {
    final (from, to) = _rangeFor(_preset);
    setState(() => _isLoading = true);
    await context.read<AccountingCubit>().loadReport(from, to);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _exportCsv() async {
    final l10n = AppLocalizations.of(context);
    final (from, to) = _rangeFor(_preset);
    final csv = await context.read<AccountingCubit>().exportCsv(
      from: from,
      to: to,
    );
    if (!mounted) return;
    if (csv == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.exportError)));
      return;
    }
    await FileSaver.instance.saveFile(
      name: 'gewerber-transactions-${formatDateIso(from)}-${formatDateIso(to)}',
      bytes: Uint8List.fromList(utf8.encode(csv)),
      fileExtension: 'csv',
      mimeType: MimeType.csv,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.exportSuccess)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final report = context.watch<AccountingCubit>().state.report;
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountingReportTitle),
        actions: [
          IconButton(
            tooltip: l10n.exportCsv,
            icon: const Icon(Icons.download_outlined),
            onPressed: report == null ? null : _exportCsv,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: GewerberTokens.space8,
            children: [
              for (final preset in _PeriodPreset.values)
                ChoiceChip(
                  label: Text(_presetLabel(l10n, preset)),
                  selected: _preset == preset,
                  onSelected: (_) {
                    setState(() => _preset = preset);
                    _load();
                  },
                ),
            ],
          ),
          const SizedBox(height: GewerberTokens.space16),
          if (_isLoading || report == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: GewerberTokens.space32),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: l10n.reportIncome,
                    value: formatCents(report.incomeCents),
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: GewerberTokens.space12),
                Expanded(
                  child: _SummaryCard(
                    label: l10n.reportExpenses,
                    value: formatCents(report.expenseCents),
                    color: colors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: GewerberTokens.space12),
            _SummaryCard(
              label: l10n.reportProfit,
              value: formatCents(report.profitCents),
              color: report.profitCents >= 0 ? colors.primary : colors.error,
              emphasized: true,
            ),
            const SizedBox(height: GewerberTokens.space24),
            if (report.incomeLines.isNotEmpty) ...[
              Text(l10n.reportIncomeByCategory, style: textTheme.titleMedium),
              const SizedBox(height: GewerberTokens.space8),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final line in report.incomeLines)
                      ListTile(
                        dense: true,
                        title: Text(_categoryLabel(l10n, line.category)),
                        subtitle: Text(l10n.reportLineCount(line.count)),
                        trailing: Text(formatCents(line.amountCents)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: GewerberTokens.space16),
            ],
            if (report.expenseLines.isNotEmpty) ...[
              Text(l10n.reportExpensesByCategory, style: textTheme.titleMedium),
              const SizedBox(height: GewerberTokens.space8),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final line in report.expenseLines)
                      ListTile(
                        dense: true,
                        title: Text(_categoryLabel(l10n, line.category)),
                        subtitle: Text(l10n.reportLineCount(line.count)),
                        trailing: Text(formatCents(line.amountCents)),
                      ),
                  ],
                ),
              ),
            ],
            if (report.incomeLines.isEmpty && report.expenseLines.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: GewerberTokens.space16,
                ),
                child: Text(l10n.reportEmpty),
              ),
          ],
        ],
      ),
    );
  }

  String _presetLabel(AppLocalizations l10n, _PeriodPreset preset) {
    return switch (preset) {
      _PeriodPreset.thisMonth => l10n.reportPeriodThisMonth,
      _PeriodPreset.lastMonth => l10n.reportPeriodLastMonth,
      _PeriodPreset.thisQuarter => l10n.reportPeriodThisQuarter,
      _PeriodPreset.thisYear => l10n.reportPeriodThisYear,
    };
  }

  String _categoryLabel(AppLocalizations l10n, TransactionCategory category) {
    return switch (category) {
      TransactionCategory.salesRevenue => l10n.categorySalesRevenue,
      TransactionCategory.serviceRevenue => l10n.categoryServiceRevenue,
      TransactionCategory.otherIncome => l10n.categoryOtherIncome,
      TransactionCategory.goodsPurchase => l10n.categoryGoodsPurchase,
      TransactionCategory.rent => l10n.categoryRent,
      TransactionCategory.office => l10n.categoryOffice,
      TransactionCategory.travel => l10n.categoryTravel,
      TransactionCategory.vehicle => l10n.categoryVehicle,
      TransactionCategory.advertising => l10n.categoryAdvertising,
      TransactionCategory.insurance => l10n.categoryInsurance,
      TransactionCategory.telecommunication => l10n.categoryTelecommunication,
      TransactionCategory.training => l10n.categoryTraining,
      TransactionCategory.consulting => l10n.categoryConsulting,
      TransactionCategory.feesAndDuties => l10n.categoryFeesAndDuties,
      TransactionCategory.tools => l10n.categoryTools,
      TransactionCategory.otherExpense => l10n.categoryOtherExpense,
    };
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: emphasized
          ? colors.primaryContainer
          : colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(GewerberTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: emphasized
                    ? colors.onPrimaryContainer
                    : colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: GewerberTokens.space4),
            Text(
              value,
              style:
                  (emphasized
                          ? Theme.of(context).textTheme.headlineSmall
                          : Theme.of(context).textTheme.titleLarge)
                      ?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
