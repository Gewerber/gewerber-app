import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_state.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';

/// InvoicingScreen — list of the active business's invoices.
class InvoicingScreen extends StatefulWidget {
  const InvoicingScreen({super.key});

  @override
  State<InvoicingScreen> createState() => _InvoicingScreenState();
}

class _InvoicingScreenState extends State<InvoicingScreen> {
  InvoiceStatus? _filter;

  @override
  void initState() {
    super.initState();
    context.read<InvoiceCubit>().load();
    context.read<CustomerCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<InvoiceCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invoicesTitle),
        actions: [
          IconButton(
            tooltip: l10n.customersTitle,
            icon: const Icon(Icons.people_outline),
            onPressed: () => context.push(RouteNames.customers),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.invoiceCreate),
        icon: const Icon(Icons.add),
        label: Text(l10n.invoicesNew),
      ),
      body: Column(
        children: [
          _StatusFilter(
            selected: _filter,
            onChanged: (status) {
              setState(() => _filter = status);
              context.read<InvoiceCubit>().load(status: status);
            },
          ),
          Expanded(
            child: switch (state.status) {
              InvoiceViewStatus.initial || InvoiceViewStatus.loading =>
                const Center(child: CircularProgressIndicator()),
              InvoiceViewStatus.failure => Center(
                child: Text(l10n.invoiceError),
              ),
              InvoiceViewStatus.loaded when state.invoices.isEmpty =>
                const _EmptyState(),
              InvoiceViewStatus.loaded => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.invoices.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final invoice = state.invoices[index];
                  return _InvoiceTile(
                    invoice: invoice,
                    onTap: () =>
                        context.push(RouteNames.invoiceDetail, extra: invoice),
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

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.selected, required this.onChanged});

  final InvoiceStatus? selected;
  final ValueChanged<InvoiceStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ChoiceChip(
            label: Text(l10n.invoicesTitle),
            selected: selected == null,
            onSelected: (_) => onChanged(null),
          ),
          const SizedBox(width: 8),
          for (final status in InvoiceStatus.values) ...[
            ChoiceChip(
              label: Text(_statusLabel(l10n, status)),
              selected: selected == status,
              onSelected: (_) => onChanged(status),
            ),
            const SizedBox(width: 8),
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

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice, required this.onTap});

  final Invoice invoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final date = invoice.issueDate;
    final formattedDate =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(Icons.receipt_outlined, color: colors.onSurfaceVariant),
        ),
        title: Text(invoice.number),
        subtitle: Text(
          '$formattedDate · ${_statusLabel(l10n, invoice.status)}',
        ),
        trailing: Text(_formatCents(invoice.totalCents)),
        onTap: onTap,
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

String _formatCents(int cents) {
  final euros = cents ~/ 100;
  final rest = (cents % 100).abs().toString().padLeft(2, '0');
  final sign = cents < 0 ? '-' : '';
  return '$sign$euros.$rest €';
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
            Icon(Icons.receipt_long_outlined, size: 56, color: colors.outline),
            const SizedBox(height: GewerberTokens.space16),
            Text(l10n.invoicesEmpty, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
