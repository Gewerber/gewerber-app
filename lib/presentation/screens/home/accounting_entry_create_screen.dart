import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/accounting/accounting_cubit.dart';
import 'package:gewerber_app/application/business/business_cubit.dart';
import 'package:gewerber_app/application/documents/documents_cubit.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/document.dart';
import 'package:gewerber_app/domain/entities/transaction.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// AccountingEntryCreateScreen — record an income or expense, optionally
/// with an attached receipt document (uploaded via `document.upload`).
///
/// With [transaction] set the same form edits an existing entry: fields are
/// prefilled, saving goes through `accounting.update`, and the receipt
/// section shows the currently attached file (replace by picking a new one,
/// clear by removing it).
class AccountingEntryCreateScreen extends StatefulWidget {
  const AccountingEntryCreateScreen({super.key, this.transaction});

  /// The transaction being edited, or `null` to record a new one.
  final AccountingTransaction? transaction;

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

  bool get _isEditing => widget.transaction != null;

  /// Newly picked receipt, held locally until the transaction is saved.
  /// The upload happens on save so removing the attachment needs no cleanup.
  PickedFileAttachment? _newReceipt;

  /// Whether the user detached the receipt that was already stored on the
  /// server (edit mode only). Saving then clears the link.
  bool _receiptRemoved = false;

  /// File name of the receipt currently stored on the server, resolved via
  /// `document.get` after opening the editor.
  String? _currentReceiptName;
  int? _currentReceiptSizeBytes;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    if (transaction != null) {
      _type = transaction.type;
      _category = transaction.category;
      _date = transaction.occurredAt;
      // Plain dot-decimal text; the field parser accepts it regardless of
      // the app language (localized group separators would not round-trip).
      _amountController.text = (transaction.amountCents / 100).toStringAsFixed(
        2,
      );
      _descriptionController.text = transaction.description ?? '';
    }
    _syncCategoryWithType();
    if (transaction?.receiptDocumentId case final documentId?) {
      _loadCurrentReceipt(documentId);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentReceipt(int documentId) async {
    final document = await context.read<DocumentsCubit>().getById(documentId);
    if (!mounted || document == null) return;
    setState(() {
      _currentReceiptName = document.fileName;
      _currentReceiptSizeBytes = document.sizeBytes;
    });
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

  Future<void> _attachReceipt() async {
    final l10n = AppLocalizations.of(context);
    final file = await context.read<DocumentsCubit>().pickFile();
    if (!mounted || file == null) return;
    // Mirror the server-side size limit; fail before saving.
    if (file.sizeBytes > documentMaxSizeBytes) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.receiptTooLarge)));
      return;
    }
    setState(() {
      _newReceipt = file;
      // A newly picked file supersedes the stored one entirely.
      _receiptRemoved = false;
    });
  }

  void _removeNewReceipt() {
    setState(() => _newReceipt = null);
  }

  void _detachCurrentReceipt() {
    setState(() {
      _currentReceiptName = null;
      _currentReceiptSizeBytes = null;
      _receiptRemoved = true;
    });
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

    final original = widget.transaction;

    // Upload a replacement receipt first so the transaction can reference
    // it. A failed upload keeps the form open with the attachment intact.
    int? receiptDocumentId = original?.receiptDocumentId;
    if (_receiptRemoved) {
      receiptDocumentId = null;
    }
    final newReceipt = _newReceipt;
    if (newReceipt != null) {
      final businessId = context.read<BusinessCubit>().state.activeBusiness?.id;
      final document = businessId == null
          ? null
          : await context.read<DocumentsCubit>().upload(
              businessId: businessId,
              file: newReceipt,
              kind: DocumentKind.receipt,
            );
      if (!mounted) return;
      if (document == null) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.receiptUploadError)));
        return;
      }
      receiptDocumentId = document.id;
    }

    final description = _descriptionController.text.trim();

    final success = original == null
        ? await context.read<AccountingCubit>().create(
            type: _type,
            category: _category,
            occurredAt: _date,
            amountCents: amountCents,
            description: description.isEmpty ? null : description,
            receiptDocumentId: receiptDocumentId,
          )
        : await context.read<AccountingCubit>().update(
            AccountingTransaction(
              id: original.id,
              type: _type,
              category: _category,
              occurredAt: _date,
              amountCents: amountCents,
              description: description.isEmpty ? null : description,
              receiptDocumentId: receiptDocumentId,
              relatedInvoiceId: original.relatedInvoiceId,
            ),
          );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? l10n.transactionUpdated : l10n.transactionSaved,
          ),
        ),
      );
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
      appBar: AppBar(
        title: Text(
          _isEditing
              ? l10n.accountingEntryEditTitle
              : l10n.accountingEntryCreateTitle,
        ),
      ),
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
          const SizedBox(height: GewerberTokens.space16),
          _ReceiptAttachment(
            newReceipt: _newReceipt,
            currentReceiptName: _currentReceiptName,
            currentReceiptSizeBytes: _currentReceiptSizeBytes,
            isBusy: _isSaving,
            onAttach: _attachReceipt,
            onRemoveNew: _removeNewReceipt,
            onDetachCurrent: _detachCurrentReceipt,
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

/// Attach-receipt section: shows either the "attach" action, the picked
/// file, or the receipt already stored on the server (edit mode). A picked
/// file stays local until save; detaching the stored one clears the link
/// when the form is submitted.
class _ReceiptAttachment extends StatelessWidget {
  const _ReceiptAttachment({
    required this.newReceipt,
    required this.currentReceiptName,
    required this.currentReceiptSizeBytes,
    required this.isBusy,
    required this.onAttach,
    required this.onRemoveNew,
    required this.onDetachCurrent,
  });

  final PickedFileAttachment? newReceipt;

  /// File name of the stored receipt (`null` while loading or once
  /// detached / replaced).
  final String? currentReceiptName;
  final int? currentReceiptSizeBytes;
  final bool isBusy;
  final VoidCallback onAttach;
  final VoidCallback onRemoveNew;
  final VoidCallback onDetachCurrent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final picked = newReceipt;

    if (picked == null && currentReceiptName != null) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: l10n.receiptAttachedLabel,
          prefixIcon: const Icon(Icons.description_outlined),
          suffixIcon: IconButton(
            tooltip: l10n.receiptRemove,
            icon: const Icon(Icons.close_outlined),
            onPressed: isBusy ? null : onDetachCurrent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                currentReceiptName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (currentReceiptSizeBytes != null) ...[
              const SizedBox(width: GewerberTokens.space8),
              Text(
                formatFileSize(currentReceiptSizeBytes!),
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ],
        ),
      );
    }

    if (picked == null) {
      return OutlinedButton.icon(
        onPressed: isBusy ? null : onAttach,
        icon: const Icon(Icons.attach_file_outlined),
        label: Text(l10n.receiptAttachButton),
      );
    }

    return InputDecorator(
      decoration: InputDecoration(
        labelText: l10n.receiptAttachedLabel,
        prefixIcon: const Icon(Icons.description_outlined),
        suffixIcon: IconButton(
          tooltip: l10n.receiptRemove,
          icon: const Icon(Icons.close_outlined),
          onPressed: isBusy ? null : onRemoveNew,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              picked.fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: GewerberTokens.space8),
          Text(
            formatFileSize(picked.sizeBytes),
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
