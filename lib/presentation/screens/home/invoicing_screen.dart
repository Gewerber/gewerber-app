import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_state.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/common/section_card.dart';
import 'package:gewerber_app/presentation/widgets/common/shimmer_loader.dart';
import 'package:gewerber_app/presentation/widgets/common/staggered_list_item.dart';

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

  Future<void> _export(String format) async {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<InvoiceCubit>();
    final content = format == 'csv'
        ? await cubit.exportCsv(status: _filter)
        : await cubit.exportJson(status: _filter);
    if (!mounted) return;
    if (content == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.exportError)));
      return;
    }
    final isCsv = format == 'csv';
    await FileSaver.instance.saveFile(
      name: 'gewerber-invoices',
      bytes: Uint8List.fromList(utf8.encode(content)),
      fileExtension: isCsv ? 'csv' : 'json',
      mimeType: isCsv ? MimeType.csv : MimeType.json,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.exportSuccess)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<InvoiceCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invoicesTitle),
        actions: [
          PopupMenuButton<String>(
            tooltip: l10n.exportMenu,
            onSelected: _export,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'csv',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.table_chart_outlined),
                  title: Text(l10n.exportCsv),
                ),
              ),
              PopupMenuItem(
                value: 'json',
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.data_object),
                  title: Text(l10n.exportJson),
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: l10n.customersTitle,
            icon: const Icon(Icons.people_outline),
            onPressed: () => context.push(RouteNames.customers),
          ),
          IconButton(
            tooltip: l10n.templatesTitle,
            icon: const Icon(Icons.description_outlined),
            onPressed: () => context.push(RouteNames.invoiceTemplates),
          ),
          IconButton(
            tooltip: l10n.recurringTitle,
            icon: const Icon(Icons.event_repeat),
            onPressed: () => context.push(RouteNames.recurringSchedules),
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
                const Center(child: ShimmerLoader(lines: 5, height: 16)),
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
                  return StaggeredListItem(
                    index: index,
                    child: _InvoiceTile(
                      invoice: invoice,
                      onTap: () => context.push(
                        RouteNames.invoiceDetail,
                        extra: invoice,
                      ),
                    ),
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
    final subtitle = formatDate(invoice.issueDate);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(Icons.receipt_outlined, color: colors.onSurfaceVariant),
        ),
        title: Text(invoice.number),
        subtitle: Text(subtitle),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(formatCents(invoice.totalCents)),
            const SizedBox(height: 4),
            SectionBadge(
              label: _statusLabel(l10n, invoice.status),
              color: _statusColor(colors, invoice.status),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Color _statusColor(ColorScheme colors, InvoiceStatus status) {
    return switch (status) {
      InvoiceStatus.draft => colors.onSurfaceVariant,
      InvoiceStatus.sent => colors.primary,
      InvoiceStatus.paid => GewerberColors.success,
      InvoiceStatus.overdue => colors.error,
      InvoiceStatus.cancelled => colors.outline,
    };
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
