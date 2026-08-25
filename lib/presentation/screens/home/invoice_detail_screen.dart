import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_cubit.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';

/// InvoiceDetailScreen — shows a single invoice, its line items and the
/// lifecycle actions (send, cancel, PDF, payments, reminders).
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
  bool _busy = false;
  InvoicePaymentStatus? _paymentStatus;
  List<InvoiceReminder> _reminders = const [];

  Invoice get _invoice => widget.invoice!;

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

    // Payment state and reminder history matter once the invoice left the
    // draft state.
    if (!invoice.isDraft) {
      final cubit = context.read<InvoiceCubit>();
      final status = await cubit.paymentStatus(invoice.id);
      final reminders = await cubit.listReminders(invoice.id);
      if (!mounted) return;
      setState(() {
        _paymentStatus = status;
        _reminders = reminders ?? const [];
      });
    }
  }

  /// Re-reads the invoice from the cubit's list after a status transition.
  Invoice _currentInvoice() {
    final invoices = context.read<InvoiceCubit>().state.invoices;
    return invoices
            .where((candidate) => candidate.id == _invoice.id)
            .firstOrNull ??
        _invoice;
  }

  Future<void> _run(
    Future<bool> Function() action,
    String successMessage,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    final success = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? successMessage
              : AppLocalizations.of(context).invoiceActionError,
        ),
      ),
    );
    if (success) setState(() {});
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

  Future<void> _downloadPdf() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    final pdf = await context.read<InvoiceCubit>().downloadPdf(_invoice.id);
    if (!mounted) return;
    setState(() => _busy = false);
    if (pdf == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.invoiceActionError)));
      return;
    }
    final name = pdf.fileName.endsWith('.pdf')
        ? pdf.fileName.substring(0, pdf.fileName.length - 4)
        : pdf.fileName;
    await FileSaver.instance.saveFile(
      name: name,
      bytes: Uint8List.fromList(pdf.bytes),
      fileExtension: 'pdf',
      mimeType: MimeType.pdf,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.invoicePdfSaved)));
  }

  Future<void> _recordPayment() async {
    final l10n = AppLocalizations.of(context);
    final remaining = _paymentStatus?.remainingCents ?? _invoice.totalCents;
    final amountController = TextEditingController(
      text: (remaining / 100).toStringAsFixed(2),
    );
    final referenceController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.paymentRecordTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.paymentAmountLabel,
                suffixText: '€',
              ),
            ),
            const SizedBox(height: GewerberTokens.space12),
            TextField(
              controller: referenceController,
              decoration: InputDecoration(
                labelText: l10n.paymentReferenceLabel,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonBack),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.paymentRecordTitle),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final amountCents = parseEuroInput(amountController.text);
    if (amountCents == null || amountCents <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.transactionAmountInvalid)));
      return;
    }
    final success = await context.read<InvoiceCubit>().recordPayment(
      invoiceId: _invoice.id,
      amountCents: amountCents,
      reference: referenceController.text.trim().isEmpty
          ? null
          : referenceController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      final status = await context.read<InvoiceCubit>().paymentStatus(
        _invoice.id,
      );
      if (!mounted) return;
      setState(() => _paymentStatus = status);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.paymentRecorded)));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.invoiceActionError)));
    }
  }

  Future<void> _sendReminder() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reminderSendTitle),
        content: Text(l10n.reminderSendConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonBack),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.reminderSendTitle),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(
      () => context.read<InvoiceCubit>().sendReminder(_invoice.id),
      l10n.reminderSent,
    );
    if (!mounted) return;
    final reminders = await context.read<InvoiceCubit>().listReminders(
      _invoice.id,
    );
    if (!mounted) return;
    setState(() => _reminders = reminders ?? const []);
  }

  Future<void> _cancelInvoice() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.invoiceCancelTitle),
        content: Text(l10n.invoiceCancelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonBack),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.invoiceCancelTitle),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _run(
      () => context.read<InvoiceCubit>().cancelInvoice(_invoice.id),
      l10n.invoiceCancelled,
    );
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
    // Reflect status transitions applied through this screen.
    final current = _loaded ? _currentInvoice() : invoice;
    final customers = context.watch<CustomerCubit>().state.customers;
    final customer = customers
        .where((c) => c.id == current.customerId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invoiceNumber),
        actions: [
          if (_busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else ...[
            if (current.isDraft) ...[
              IconButton(
                tooltip: l10n.invoiceMarkSent,
                icon: const Icon(Icons.send_outlined),
                onPressed: () => _run(
                  () => context.read<InvoiceCubit>().markSent(current.id),
                  l10n.invoiceMarkedSent,
                ),
              ),
              IconButton(
                tooltip: l10n.invoiceEditTitle,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    context.push(RouteNames.invoiceCreate, extra: current),
              ),
              IconButton(
                tooltip: l10n.invoiceDelete,
                icon: const Icon(Icons.delete_outline),
                onPressed: _delete,
              ),
            ],
            if (current.status == InvoiceStatus.sent ||
                current.status == InvoiceStatus.overdue) ...[
              IconButton(
                tooltip: l10n.paymentRecordTitle,
                icon: const Icon(Icons.payments_outlined),
                onPressed: _recordPayment,
              ),
              IconButton(
                tooltip: l10n.reminderSendTitle,
                icon: const Icon(Icons.notifications_outlined),
                onPressed: _sendReminder,
              ),
              IconButton(
                tooltip: l10n.invoiceCancelTitle,
                icon: const Icon(Icons.cancel_outlined),
                onPressed: _cancelInvoice,
              ),
            ],
            PopupMenuButton<String>(
              tooltip: l10n.invoiceMoreActions,
              onSelected: (value) {
                switch (value) {
                  case 'pdf':
                    _downloadPdf();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'pdf',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.picture_as_pdf_outlined),
                    title: Text(l10n.invoiceDownloadPdf),
                  ),
                ),
              ],
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
                      current.number,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(_statusLabel(l10n, current.status)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCents(current.totalCents),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ],
          ),
          if (_paymentStatus != null &&
              (_paymentStatus!.payments.isNotEmpty ||
                  current.status == InvoiceStatus.paid)) ...[
            const SizedBox(height: GewerberTokens.space16),
            _PaymentStatusCard(
              status: _paymentStatus!,
              totalCents: current.totalCents,
            ),
          ],
          if (_reminders.isNotEmpty) ...[
            const SizedBox(height: GewerberTokens.space12),
            _RemindersCard(reminders: _reminders),
          ],
          const Divider(height: 32),
          _InfoRow(
            label: l10n.invoiceCustomer,
            value: customer?.displayName ?? l10n.invoiceNoCustomer,
          ),
          _InfoRow(
            label: l10n.invoiceIssueDate,
            value: formatDate(current.issueDate),
          ),
          if (current.dueDate != null)
            _InfoRow(
              label: l10n.invoiceDueDate,
              value: formatDate(current.dueDate!),
            ),
          if (current.serviceDateFrom != null && current.serviceDateTo != null)
            _InfoRow(
              label: l10n.invoiceServicePeriod,
              value:
                  '${formatDate(current.serviceDateFrom!)} – ${formatDate(current.serviceDateTo!)}',
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
                        '${item.quantity} × ${formatCents(item.unitPriceCents)}',
                      ),
                      trailing: Text(formatCents(item.lineTotalCents)),
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
                    formatCents(current.subtotalCents),
                  ),
                  _SummaryRow(
                    l10n.invoiceVat,
                    formatCents(current.vatTotalCents),
                  ),
                  const Divider(),
                  _SummaryRow(
                    l10n.invoiceTotal,
                    formatCents(current.totalCents),
                    emphasized: true,
                  ),
                ],
              ),
            ],
          ),
          if (current.notes != null && current.notes!.isNotEmpty) ...[
            const SizedBox(height: GewerberTokens.space24),
            Text(
              l10n.invoiceNotes,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: GewerberTokens.space8),
            Text(current.notes!),
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

class _PaymentStatusCard extends StatelessWidget {
  const _PaymentStatusCard({required this.status, required this.totalCents});

  final InvoicePaymentStatus status;
  final int totalCents;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: status.isPaid
          ? colors.primaryContainer
          : colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(GewerberTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.paymentHistoryTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: status.isPaid
                    ? colors.onPrimaryContainer
                    : colors.onSurface,
              ),
            ),
            const SizedBox(height: GewerberTokens.space8),
            Text(
              '${l10n.paymentPaidAmount}: ${formatCents(status.paidTotalCents)}',
            ),
            if (!status.isPaid)
              Text(
                '${l10n.paymentRemainingAmount}: '
                '${formatCents(status.remainingCents)}',
              ),
            // Recorded payments, newest first.
            for (final payment
                in status.payments.toList()..sort(
                  (a, b) => (b.paidAt ?? DateTime(0)).compareTo(
                    a.paidAt ?? DateTime(0),
                  ),
                )) ...[
              const Divider(height: GewerberTokens.space16),
              // Amount, date/method and reference read as one payment
              // node instead of scattered texts.
              MergeSemantics(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 18,
                      color: status.isPaid
                          ? colors.onPrimaryContainer
                          : colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: GewerberTokens.space8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(formatCents(payment.amountCents)),
                          Text(
                            [
                              if (payment.paidAt != null)
                                formatDate(payment.paidAt!),
                              _methodLabel(l10n, payment.method),
                            ].join(' · '),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                          if (payment.reference != null &&
                              payment.reference!.isNotEmpty)
                            Text(
                              payment.reference!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _methodLabel(AppLocalizations l10n, PaymentMethod method) {
    return switch (method) {
      PaymentMethod.bankTransfer => l10n.paymentMethodBankTransfer,
      PaymentMethod.cash => l10n.paymentMethodCash,
      PaymentMethod.card => l10n.paymentMethodCard,
      PaymentMethod.paypal => l10n.paymentMethodPaypal,
      PaymentMethod.directDebit => l10n.paymentMethodDirectDebit,
      PaymentMethod.other => l10n.paymentMethodOther,
    };
  }
}

class _RemindersCard extends StatelessWidget {
  const _RemindersCard({required this.reminders});

  final List<InvoiceReminder> reminders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(GewerberTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reminderHistoryTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: colors.onErrorContainer),
            ),
            const SizedBox(height: GewerberTokens.space8),
            for (final reminder in reminders)
              Text(
                '${l10n.reminderLevel(reminder.level)}'
                '${reminder.sentAt == null ? '' : ' · ${formatDate(reminder.sentAt!)}'}',
                style: TextStyle(color: colors.onErrorContainer),
              ),
          ],
        ),
      ),
    );
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
