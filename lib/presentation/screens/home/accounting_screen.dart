import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/accounting/accounting_cubit.dart';
import 'package:gewerber_app/application/accounting/accounting_state.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';

/// AccountingScreen — income and expense transactions of the business.
class AccountingScreen extends StatefulWidget {
  const AccountingScreen({super.key});

  @override
  State<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends State<AccountingScreen> {
  TransactionType? _filter;

  @override
  void initState() {
    super.initState();
    context.read<AccountingCubit>().load();
  }

  Future<void> _delete(AccountingTransaction transaction) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.transactionDeleteTitle),
        content: Text(l10n.transactionDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonBack),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.transactionDeleteTitle),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<AccountingCubit>().delete(transaction.id);
  }

  Future<void> _openEntryCreate() async {
    await context.push(RouteNames.accountingEntryCreate);
    if (!mounted) return;
    context.read<AccountingCubit>().load(type: _filter);
  }

  Future<void> _openEntryEdit(AccountingTransaction transaction) async {
    await context.push(RouteNames.accountingEntryEdit, extra: transaction);
    if (!mounted) return;
    context.read<AccountingCubit>().load(type: _filter);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AccountingCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeAccounting),
        actions: [
          IconButton(
            tooltip: l10n.accountingReportTitle,
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => context.push(RouteNames.accountingReport),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'accounting-fab',
        onPressed: _openEntryCreate,
        icon: const Icon(Icons.add),
        label: Text(l10n.accountingEntryCreateTitle),
      ),
      body: Column(
        children: [
          _TypeFilter(
            selected: _filter,
            onChanged: (type) {
              setState(() => _filter = type);
              context.read<AccountingCubit>().load(type: type);
            },
          ),
          Expanded(
            child: switch (state.status) {
              AccountingViewStatus.initial || AccountingViewStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              AccountingViewStatus.failure => Center(
                child: Text(l10n.accountingLoadError),
              ),
              AccountingViewStatus.loaded when state.transactions.isEmpty =>
                const _EmptyState(),
              AccountingViewStatus.loaded => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.transactions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final transaction = state.transactions[index];
                  return _TransactionTile(
                    transaction: transaction,
                    onEdit: () => _openEntryEdit(transaction),
                    onDelete: () => _delete(transaction),
                  );
                },
              ),
            },
          ),
        ],
      ),
    );
  }
}

class _TypeFilter extends StatelessWidget {
  const _TypeFilter({required this.selected, required this.onChanged});

  final TransactionType? selected;
  final ValueChanged<TransactionType?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ChoiceChip(
            label: Text(l10n.transactionsAll),
            selected: selected == null,
            onSelected: (_) => onChanged(null),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: Text(l10n.transactionTypeIncome),
            selected: selected == TransactionType.income,
            onSelected: (_) => onChanged(TransactionType.income),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: Text(l10n.transactionTypeExpense),
            selected: selected == TransactionType.expense,
            onSelected: (_) => onChanged(TransactionType.expense),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  final AccountingTransaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final isIncome = transaction.type == TransactionType.income;

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome
              ? colors.primaryContainer
              : colors.errorContainer,
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome
                ? colors.onPrimaryContainer
                : colors.onErrorContainer,
            // Announce the direction ("Income"/"Expense") instead of an
            // unlabeled arrow glyph.
            semanticLabel: isIncome
                ? l10n.transactionTypeIncome
                : l10n.transactionTypeExpense,
          ),
        ),
        title: Text(
          transaction.description?.isNotEmpty ?? false
              ? transaction.description!
              : _categoryLabel(l10n, transaction.category),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${formatDate(transaction.occurredAt)} · '
          '${_categoryLabel(l10n, transaction.category)}',
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${formatCents(transaction.amountCents)}',
          style: TextStyle(
            color: isIncome ? colors.primary : colors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        // Opens the editor, mirroring the customers and recurring-schedule
        // lists; delete stays on long-press.
        onTap: onEdit,
        onLongPress: onDelete,
      ),
    );
  }

  static String _categoryLabel(
    AppLocalizations l10n,
    TransactionCategory category,
  ) {
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GewerberTokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_outlined,
              size: 56,
              color: colors.outline,
            ),
            const SizedBox(height: GewerberTokens.space16),
            Text(l10n.transactionsEmpty, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
