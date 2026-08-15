import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/business/business_cubit.dart';
import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/customers/customer_state.dart';
import 'package:gewerber_app/application/invoices/invoice_cubit.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/domain/entities/customer.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// InvoiceCreateScreen — create a new invoice or edit a draft.
class InvoiceCreateScreen extends StatefulWidget {
  const InvoiceCreateScreen({super.key, this.invoice});

  /// The invoice being edited, or `null` to create a new one.
  final Invoice? invoice;

  @override
  State<InvoiceCreateScreen> createState() => _InvoiceCreateScreenState();
}

class _InvoiceCreateScreenState extends State<InvoiceCreateScreen> {
  final _itemsKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final List<_ItemDraft> _items = [];
  int? _customerId;
  DateTime? _issueDate;
  DateTime? _dueDate;
  DateTime? _serviceFrom;
  DateTime? _serviceTo;
  bool _isSaving = false;
  bool _initialized = false;

  bool get _isEditing => widget.invoice != null;

  @override
  void initState() {
    super.initState();
    final invoice = widget.invoice;
    _notesController.text = invoice?.notes ?? '';
    _customerId = invoice?.customerId;
    _issueDate = invoice?.issueDate;
    _dueDate = invoice?.dueDate;
    _serviceFrom = invoice?.serviceDateFrom;
    _serviceTo = invoice?.serviceDateTo;
    _loadItems();
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final invoice = widget.invoice;
    if (invoice == null || _initialized) return;
    _initialized = true;
    final result = await context.read<InvoiceCubit>().get(invoice.id);
    if (!mounted || result == null) return;
    setState(() {
      _items
        ..clear()
        ..addAll(
          result.items.map(
            (item) => _ItemDraft(
              description: item.description,
              quantity: item.quantity,
              unitPriceCents: item.unitPriceCents,
            ),
          ),
        );
    });
  }

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime> onPicked,
    bool isStartDate = false,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: isStartDate
          ? DateTime(2000)
          : now.subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    final l10n = AppLocalizations.of(context);
    final customers = context.read<CustomerCubit>().state.customers;
    final customerExists =
        _customerId == null ||
        customers.any((customer) => customer.id == _customerId);
    final itemsValid =
        _items.isNotEmpty &&
        _items.every((item) => item.description.trim().isNotEmpty);
    if (!customerExists) {
      _showSnack(l10n.invoiceMissingCustomer);
      return;
    }
    if (!itemsValid) {
      _showSnack(l10n.invoiceMissingItems);
      return;
    }

    final invoiceCubit = context.read<InvoiceCubit>();
    final business = context.read<BusinessCubit>().state.activeBusiness;
    final vatRate = (business?.isKleinunternehmer ?? false)
        ? InvoiceVatRate.none
        : InvoiceVatRate.standard;

    setState(() => _isSaving = true);
    final itemDrafts = _items.map((item) => item.toItem(vatRate)).toList();

    final saved = _isEditing
        ? await invoiceCubit.update(
            widget.invoice!.copyWith(
              customerId: _customerId,
              issueDate: _issueDate,
              dueDate: _dueDate,
              serviceDateFrom: _serviceFrom,
              serviceDateTo: _serviceTo,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            ),
            items: itemDrafts,
          )
        : await invoiceCubit.create(
            items: itemDrafts,
            customerId: _customerId,
            issueDate: _issueDate,
            dueDate: _dueDate,
            serviceDateFrom: _serviceFrom,
            serviceDateTo: _serviceTo,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

    if (!mounted) return;
    setState(() => _isSaving = false);
    if (saved) {
      _showSnack(l10n.invoiceSaved);
      context.pop();
    } else {
      _showSnack(l10n.invoiceError);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.invoiceEditTitle : l10n.invoiceNewTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _CustomerPicker(
                    selectedId: _customerId,
                    onChanged: (id) => setState(() => _customerId = id),
                  ),
                  const SizedBox(height: GewerberTokens.space16),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: l10n.invoiceIssueDate,
                          date: _issueDate,
                          onTap: () => _pickDate(
                            current: _issueDate,
                            onPicked: (date) =>
                                setState(() => _issueDate = date),
                          ),
                        ),
                      ),
                      const SizedBox(width: GewerberTokens.space12),
                      Expanded(
                        child: _DateField(
                          label: l10n.invoiceDueDate,
                          date: _dueDate,
                          onTap: () => _pickDate(
                            current: _dueDate,
                            onPicked: (date) => setState(() => _dueDate = date),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GewerberTokens.space8),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label:
                              '${l10n.invoiceServiceFrom} (${l10n.onboardingOptional})',
                          date: _serviceFrom,
                          onTap: () => _pickDate(
                            current: _serviceFrom,
                            isStartDate: true,
                            onPicked: (date) =>
                                setState(() => _serviceFrom = date),
                          ),
                        ),
                      ),
                      const SizedBox(width: GewerberTokens.space12),
                      Expanded(
                        child: _DateField(
                          label:
                              '${l10n.invoiceServiceTo} (${l10n.onboardingOptional})',
                          date: _serviceTo,
                          onTap: () => _pickDate(
                            current: _serviceTo,
                            onPicked: (date) =>
                                setState(() => _serviceTo = date),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GewerberTokens.space24),
                  Text(
                    l10n.invoiceItems,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: GewerberTokens.space12),
                  Form(
                    key: _itemsKey,
                    child: Column(
                      children: [
                        for (final item in _items) ...[
                          _ItemEditor(
                            item: item,
                            onRemove: () {
                              setState(() => _items.remove(item));
                            },
                          ),
                          const SizedBox(height: GewerberTokens.space12),
                        ],
                        if (_items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              l10n.invoicesEmpty,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _items.add(_ItemDraft()));
                          },
                          icon: const Icon(Icons.add),
                          label: Text(l10n.invoiceAddItem),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GewerberTokens.space24),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: l10n.invoiceNotes,
                      helperText: l10n.invoiceNotesHint,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: GewerberTokens.space32),
                  FilledButton(
                    onPressed: _isSaving ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: GewerberTokens.space4,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.invoiceSave),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension on Invoice {
  Invoice copyWith({
    int? customerId,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? serviceDateFrom,
    DateTime? serviceDateTo,
    String? notes,
  }) {
    return Invoice(
      id: id,
      number: number,
      status: status,
      customerId: customerId,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      serviceDateFrom: serviceDateFrom ?? this.serviceDateFrom,
      serviceDateTo: serviceDateTo ?? this.serviceDateTo,
      subtotalCents: subtotalCents,
      vatTotalCents: vatTotalCents,
      totalCents: totalCents,
      notes: notes,
    );
  }
}

class _CustomerPicker extends StatelessWidget {
  const _CustomerPicker({required this.selectedId, required this.onChanged});

  final int? selectedId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<CustomerCubit>().state;
    final customers = state.customers
        .where((customer) => customer.status == CustomerStatus.active)
        .toList();

    if (state.status == CustomerViewStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownButtonFormField<int?>(
      initialValue: selectedId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.invoiceCustomer,
        prefixIcon: const Icon(Icons.person_outline),
      ),
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: Text(l10n.invoiceNoCustomer),
        ),
        for (final customer in customers)
          DropdownMenuItem<int?>(
            value: customer.id,
            child: Text(customer.displayName),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dateText = date == null
        ? null
        : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.event_outlined),
        ),
        child: Text(
          dateText ?? '',
          style: date == null
              ? TextStyle(color: colors.onSurfaceVariant)
              : null,
        ),
      ),
    );
  }
}

class _ItemDraft {
  _ItemDraft({
    String description = '',
    double quantity = 1,
    int unitPriceCents = 0,
  }) : descriptionController = TextEditingController(text: description),
       quantityController = TextEditingController(text: quantity.toString()),
       priceController = TextEditingController(
         text: (unitPriceCents / 100).toStringAsFixed(2),
       );

  final TextEditingController descriptionController;
  final TextEditingController quantityController;
  final TextEditingController priceController;

  String get description => descriptionController.text.trim();

  InvoiceItem toItem(InvoiceVatRate vatRate) {
    final quantity = double.tryParse(quantityController.text) ?? 1;
    final priceEuros = double.tryParse(priceController.text) ?? 0;
    final unitPriceCents = (priceEuros * 100).round();
    return InvoiceItem(
      description: description,
      quantity: quantity,
      unitPriceCents: unitPriceCents,
      vatRate: vatRate,
      lineTotalCents: (quantity * unitPriceCents).round(),
    );
  }

  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    priceController.dispose();
  }
}

class _ItemEditor extends StatelessWidget {
  const _ItemEditor({required this.item, required this.onRemove});

  final _ItemDraft item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.invoiceItemDescription,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.authValidationError;
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.invoiceDelete,
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.quantityController,
                    decoration: InputDecoration(
                      labelText: l10n.invoiceItemQuantity,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: item.priceController,
                    decoration: InputDecoration(
                      labelText: '${l10n.invoiceItemUnitPrice} (€)',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
