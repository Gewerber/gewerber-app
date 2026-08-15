import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_cubit.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';

/// InvoiceDetailScreen — shows a single invoice and its line items.
class InvoiceDetailScreen extends StatefulWidget {
  const InvoiceDetailScreen({super.key, this.invoice});

  /// The invoice to display. `null` when deep-linked without data.
  final Invoice? invoice;

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  List<InvoiceItem>? _items;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final invoice = widget.invoice;
    if (invoice == null || _loaded) return;
    _loaded = true;
    final result = await context.read<InvoiceCubit>().get(invoice.id);
    if (!mounted || result == null) return;
    setState(() => _items = result.items);
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final invoice = widget.invoice;
    if (invoice == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.invoiceDelete),
        content: Text(l10n.invoiceDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonBack),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.invoiceDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final deleted = await context.read<InvoiceCubit>().delete(invoice.id);
    if (!mounted) return;
    if (deleted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.invoiceDeleted)));
      context.pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.invoiceDeleteDraftOnly)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final invoice = widget.invoice;
    if (invoice == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.invoiceNumber)),
        body: Center(child: Text(l10n.invoiceNotFound)),
      );
    }
    final customers = context.watch<CustomerCubit>().state.customers;
    final customer = customers
        .where((c) => c.id == invoice.customerId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invoiceNumber),
        actions: [
          if (invoice.isDraft) ...[
            IconButton(
              tooltip: l10n.invoiceEditTitle,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.push(RouteNames.invoiceCreate, extra: invoice),
            ),
            IconButton(
              tooltip: l10n.invoiceDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.number,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(_statusLabel(l10n, invoice.status)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCents(invoice.totalCents),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 32),
          _InfoRow(
            label: l10n.invoiceCustomer,
            value: customer?.displayName ?? l10n.invoiceNoCustomer,
          ),
          _InfoRow(
            label: l10n.invoiceIssueDate,
            value: _formatDate(invoice.issueDate),
          ),
          if (invoice.dueDate != null)
            _InfoRow(
              label: l10n.invoiceDueDate,
              value: _formatDate(invoice.dueDate!),
            ),
          if (invoice.serviceDateFrom != null && invoice.serviceDateTo != null)
            _InfoRow(
              label: l10n.invoiceServicePeriod,
              value:
                  '${_formatDate(invoice.serviceDateFrom!)} – ${_formatDate(invoice.serviceDateTo!)}',
            ),
          const SizedBox(height: GewerberTokens.space16),
          Text(
            l10n.invoiceItems,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: GewerberTokens.space8),
          if (_items == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_items!.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(l10n.invoicesEmpty),
            )
          else
            Card(
              margin: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final item in _items!)
                    ListTile(
                      dense: true,
                      title: Text(item.description),
                      subtitle: Text(
                        '${item.quantity} × ${_formatCents(item.unitPriceCents)}',
                      ),
                      trailing: Text(_formatCents(item.lineTotalCents)),
                    ),
                ],
              ),
            ),
          const SizedBox(height: GewerberTokens.space16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _SummaryRow(
                    l10n.invoiceSubtotal,
                    _formatCents(invoice.subtotalCents),
                  ),
                  _SummaryRow(
                    l10n.invoiceVat,
                    _formatCents(invoice.vatTotalCents),
                  ),
                  const Divider(),
                  _SummaryRow(
                    l10n.invoiceTotal,
                    _formatCents(invoice.totalCents),
                    emphasized: true,
                  ),
                ],
              ),
            ],
          ),
          if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
            const SizedBox(height: GewerberTokens.space24),
            Text(
              l10n.invoiceNotes,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: GewerberTokens.space8),
            Text(invoice.notes!),
          ],
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, InvoiceStatus status) {
    return switch (status) {
      InvoiceStatus.draft => l10n.invoiceStatusDraft,
      InvoiceStatus.sent => l10n.invoiceStatusSent,
      InvoiceStatus.paid => l10n.invoiceStatusPaid,
      InvoiceStatus.overdue => l10n.invoiceStatusOverdue,
      InvoiceStatus.cancelled => l10n.invoiceStatusCancelled,
    };
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          Expanded(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.emphasized = false});

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = emphasized ? textTheme.titleMedium : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: style),
          const SizedBox(width: 24),
          Text(value, style: style),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String _formatCents(int cents) {
  final euros = cents ~/ 100;
  final rest = (cents % 100).abs().toString().padLeft(2, '0');
  final sign = cents < 0 ? '-' : '';
  return '$sign$euros.$rest €';
}
