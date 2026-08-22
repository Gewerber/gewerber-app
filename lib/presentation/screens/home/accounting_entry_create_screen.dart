import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/accounting/accounting_cubit.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// AccountingEntryCreateScreen — record an income or expense.
class AccountingEntryCreateScreen extends StatefulWidget {
  const AccountingEntryCreateScreen({super.key});

  @override
  State<AccountingEntryCreateScreen> createState() =>
      _AccountingEntryCreateScreenState();
}

class _AccountingEntryCreateScreenState
    extends State<AccountingEntryCreateScreen> {
  TransactionType _type = TransactionType.expense;
  TransactionCategory _category = TransactionCategory.office;
  DateTime _date = DateTime.now();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _syncCategoryWithType();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _syncCategoryWithType() {
    final valid = _type == TransactionType.income
        ? TransactionCategory.incomeCategories
        : TransactionCategory.expenseCategories;
    if (!valid.contains(_category)) {
      _category = valid.first;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  String _categoryLabel(TransactionCategory category) {
    final l10n = AppLocalizations.of(context);
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

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final amountCents = parseEuroInput(_amountController.text);
    if (amountCents == null || amountCents <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.transactionAmountInvalid)));
      return;
    }
    setState(() => _isSaving = true);
    final success = await context.read<AccountingCubit>().create(
      type: _type,
      category: _category,
      occurredAt: _date,
      amountCents: amountCents,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.transactionSaved)));
      context.pop();
    } else {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.transactionSaveError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = _type == TransactionType.income
        ? TransactionCategory.incomeCategories
        : TransactionCategory.expenseCategories;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountingEntryCreateTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<TransactionType>(
            segments: [
              ButtonSegment(
                value: TransactionType.income,
                label: Text(l10n.transactionTypeIncome),
                icon: const Icon(Icons.trending_up),
              ),
              ButtonSegment(
                value: TransactionType.expense,
                label: Text(l10n.transactionTypeExpense),
                icon: const Icon(Icons.trending_down),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (selection) {
              setState(() => _type = selection.first);
              _syncCategoryWithType();
            },
          ),
          const SizedBox(height: GewerberTokens.space16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.transactionAmountLabel,
              suffixText: '€',
            ),
          ),
          const SizedBox(height: GewerberTokens.space12),
          DropdownButtonFormField<TransactionCategory>(
            initialValue: _category,
            decoration: InputDecoration(labelText: l10n.transactionCategory),
            items: [
              for (final category in categories)
                DropdownMenuItem(
                  value: category,
                  child: Text(_categoryLabel(category)),
                ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _category = value);
            },
          ),
          const SizedBox(height: GewerberTokens.space12),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(formatDate(_date)),
          ),
          const SizedBox(height: GewerberTokens.space12),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: l10n.transactionDescriptionLabel,
            ),
          ),
          const SizedBox(height: GewerberTokens.space24),
          FilledButton(
            onPressed: _isSaving ? null : _submit,
            child: _isSaving
                ? Text(l10n.invoiceSaving)
                : Text(l10n.invoiceSave),
          ),
        ],
      ),
    );
  }
}
