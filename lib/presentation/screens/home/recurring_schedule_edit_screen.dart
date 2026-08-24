import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/invoices/invoice_cubit.dart';
import 'package:gewerber_app/application/invoices/invoice_state.dart';
import 'package:gewerber_app/application/recurring_schedules/recurring_schedule_cubit.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/domain/entities/recurring_schedule.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// RecurringScheduleEditScreen — attach a recurring schedule to an invoice
/// or edit the settings of an existing one.
class RecurringScheduleEditScreen extends StatefulWidget {
  const RecurringScheduleEditScreen({super.key, this.schedule});

  /// The schedule being edited, or `null` to attach a new one.
  final RecurringSchedule? schedule;

  @override
  State<RecurringScheduleEditScreen> createState() =>
      _RecurringScheduleEditScreenState();
}

class _RecurringScheduleEditScreenState
    extends State<RecurringScheduleEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _maxOccurrencesController = TextEditingController();
  Invoice? _selectedInvoice;
  RecurrenceInterval _interval = RecurrenceInterval.monthly;
  DateTime? _nextDate;
  DateTime? _endDate;
  // Armed by the explicit "clear" controls next to a filled end date /
  // occurrence limit. An empty field alone keeps the stored value ("leave
  // as is"), so lifting a limit is always an explicit act.
  bool _clearEndDate = false;
  bool _clearMaxOccurrences = false;

  bool get _isEditing => widget.schedule != null;

  @override
  void initState() {
    super.initState();
    final schedule = widget.schedule;
    _interval = schedule?.interval ?? RecurrenceInterval.monthly;
    _nextDate = schedule?.nextRecurrenceDate;
    _endDate = schedule?.recurrenceEndDate;
    if (schedule?.recurrenceMaxOccurrences != null) {
      _maxOccurrencesController.text = schedule!.recurrenceMaxOccurrences
          .toString();
    }
    _maxOccurrencesController.addListener(() {
      // Typing a new limit revokes a pending clear request.
      if (_clearMaxOccurrences && _maxOccurrencesController.text.isNotEmpty) {
        setState(() => _clearMaxOccurrences = false);
      }
    });
    // Attach mode needs the invoice candidates; the invoicing module does
    // not preload them when navigating here directly.
    if (!_isEditing) {
      final invoices = context.read<InvoiceCubit>();
      if (invoices.state.status == InvoiceViewStatus.initial) {
        invoices.load();
      }
    }
  }

  @override
  void dispose() {
    _maxOccurrencesController.dispose();
    super.dispose();
  }

  /// The date from which the end-date validation is anchored: the explicit
  /// next date or, when absent, the source invoice's issue date (the server
  /// derives the first occurrence from it).
  DateTime get _effectiveNextDate {
    if (_nextDate != null) return _nextDate!;
    if (_isEditing) return widget.schedule!.effectiveNextDate;
    return _selectedInvoice?.issueDate ?? DateTime.now();
  }

  int? get _maxOccurrences {
    final text = _maxOccurrencesController.text.trim();
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }

  Future<void> _pickDate({
    required DateTime? current,
    required ValueChanged<DateTime> onPicked,
    DateTime? firstDate,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? (firstDate ?? now),
      firstDate: firstDate ?? now.subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = AppLocalizations.of(context);

    final maxOccurrences = _maxOccurrences;
    if (!_isEditing && _selectedInvoice == null) {
      _showSnack(l10n.invoiceMissingCustomer);
      return;
    }
    if (!_clearMaxOccurrences && maxOccurrences != null && maxOccurrences < 1) {
      _showSnack(l10n.recurringMaxOccurrencesInvalid);
      return;
    }
    if (!_clearEndDate) {
      final endDate = _endDate;
      if (endDate != null && !endDate.isAfter(_effectiveNextDate)) {
        _showSnack(l10n.recurringEndDateInvalid);
        return;
      }
    }

    // Edit mode: an untouched empty field keeps the stored value; only the
    // explicit clear controls lift a limit.
    final endDate = _clearEndDate
        ? null
        : (_endDate ?? widget.schedule?.recurrenceEndDate);
    final effectiveMaxOccurrences = _clearMaxOccurrences
        ? null
        : (maxOccurrences ?? widget.schedule?.recurrenceMaxOccurrences);

    final cubit = context.read<RecurringScheduleCubit>();
    final saved = _isEditing
        ? await cubit.update(
            widget.schedule!,
            interval: _interval,
            nextRecurrenceDate:
                _nextDate ?? widget.schedule!.nextRecurrenceDate,
            recurrenceEndDate: endDate,
            recurrenceMaxOccurrences: effectiveMaxOccurrences,
            clearRecurrenceEndDate: _clearEndDate,
            clearMaxOccurrences: _clearMaxOccurrences,
          )
        : await cubit.attach(
            invoiceId: _selectedInvoice!.id,
            interval: _interval,
            nextRecurrenceDate: _nextDate,
            recurrenceEndDate: endDate,
            recurrenceMaxOccurrences: maxOccurrences,
          );

    if (!mounted) return;
    if (saved) {
      _showSnack(l10n.recurringSaved);
      context.pop();
      return;
    }
    // Surface a message that matches the failure kind.
    final failure = cubit.state.failure;
    if (failure is ConflictFailure) {
      _showSnack(l10n.recurringConflict);
    } else if (failure is NotFoundFailure) {
      _showSnack(l10n.recurringNotFound);
    } else {
      _showSnack(l10n.recurringSaveError);
    }
  }

  Future<void> _cancelSchedule() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.event_busy_outlined),
        title: Text(l10n.recurringCancelTitle),
        content: Text(l10n.recurringCancelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.recurringCancelTitle),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final cubit = context.read<RecurringScheduleCubit>();
    final cancelled = await cubit.cancel(widget.schedule!.invoiceId);
    if (!mounted) return;
    if (cancelled) {
      _showSnack(l10n.recurringCancelled);
      context.pop();
      return;
    }
    if (cubit.state.failure is NotFoundFailure) {
      _showSnack(l10n.recurringNotFound);
    } else {
      _showSnack(l10n.recurringCancelError);
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
    final isSaving = context.watch<RecurringScheduleCubit>().state.isSaving;
    // Watched so candidates appear once the invoice list finishes loading.
    final invoices = context.watch<InvoiceCubit>().state.invoices;
    final candidates = _pickerCandidates(invoices);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.recurringEditTitle : l10n.recurringNewTitle,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_isEditing)
                    _SourceInvoiceTile(schedule: widget.schedule!)
                  else ...[
                    _InvoicePicker(
                      invoices: candidates,
                      selected: _selectedInvoice,
                      onChanged: (invoice) =>
                          setState(() => _selectedInvoice = invoice),
                    ),
                    if (candidates.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: GewerberTokens.space8,
                        ),
                        child: Text(
                          l10n.recurringNoInvoices,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: GewerberTokens.space16),
                  DropdownButtonFormField<RecurrenceInterval>(
                    initialValue: _interval,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.recurringInterval,
                      prefixIcon: const Icon(Icons.repeat_outlined),
                    ),
                    items: [
                      for (final interval in RecurrenceInterval.values)
                        DropdownMenuItem<RecurrenceInterval>(
                          value: interval,
                          child: Text(_intervalLabel(l10n, interval)),
                        ),
                    ],
                    onChanged: (interval) {
                      if (interval != null) {
                        setState(() => _interval = interval);
                      }
                    },
                  ),
                  const SizedBox(height: GewerberTokens.space16),
                  _OptionalDateField(
                    label: l10n.recurringNextDate,
                    date: _nextDate,
                    onTap: () => _pickDate(
                      current: _nextDate,
                      firstDate: DateTime.now(),
                      onPicked: (date) => setState(() => _nextDate = date),
                    ),
                  ),
                  const SizedBox(height: GewerberTokens.space16),
                  _OptionalDateField(
                    label:
                        '${l10n.recurringEndDate} (${l10n.onboardingOptional})',
                    date: _endDate,
                    isCleared: _clearEndDate,
                    onClear:
                        _isEditing &&
                            widget.schedule!.recurrenceEndDate != null &&
                            !_clearEndDate
                        ? () => setState(() {
                            _clearEndDate = true;
                            _endDate = null;
                          })
                        : null,
                    onTap: () => _pickDate(
                      current: _endDate,
                      firstDate: _effectiveNextDate.add(
                        const Duration(days: 1),
                      ),
                      onPicked: (date) => setState(() {
                        // Picking a new end date revokes a pending clear.
                        _clearEndDate = false;
                        _endDate = date;
                      }),
                    ),
                  ),
                  const SizedBox(height: GewerberTokens.space16),
                  TextFormField(
                    controller: _maxOccurrencesController,
                    decoration: InputDecoration(
                      labelText:
                          '${l10n.recurringMaxOccurrences} (${l10n.onboardingOptional})',
                      prefixIcon: const Icon(Icons.format_list_numbered),
                      helperText: _clearMaxOccurrences
                          ? l10n.recurringWillBeCleared
                          : null,
                      suffixIcon:
                          _isEditing &&
                              widget.schedule!.recurrenceMaxOccurrences !=
                                  null &&
                              !_clearMaxOccurrences
                          ? IconButton(
                              tooltip: l10n.commonClear,
                              icon: const Icon(Icons.highlight_off_outlined),
                              onPressed: () => setState(() {
                                _clearMaxOccurrences = true;
                                _maxOccurrencesController.clear();
                              }),
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (_clearMaxOccurrences) return null;
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return null;
                      final parsed = int.tryParse(text);
                      if (parsed == null || parsed < 1) {
                        return l10n.recurringMaxOccurrencesInvalid;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: GewerberTokens.space32),
                  FilledButton(
                    onPressed: isSaving ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: GewerberTokens.space4,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.templateSave),
                    ),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: GewerberTokens.space12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: isSaving ? null : _cancelSchedule,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: GewerberTokens.space4,
                        ),
                        child: Text(l10n.recurringCancelTitle),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Candidates for the invoice dropdown: everything that is not cancelled
  /// and not already scheduled, plus the current selection so the picker
  /// never renders a value that is missing from its items (e.g. on the
  /// transient rebuild right after a successful save, before the screen
  /// pops).
  List<Invoice> _pickerCandidates(List<Invoice> invoices) {
    final scheduledIds = context
        .read<RecurringScheduleCubit>()
        .state
        .schedules
        .map((schedule) => schedule.invoiceId)
        .toSet();
    final candidates = invoices
        .where(
          (invoice) =>
              invoice.status != InvoiceStatus.cancelled &&
              !scheduledIds.contains(invoice.id),
        )
        .toList();
    final selected = _selectedInvoice;
    if (selected != null &&
        !candidates.any((invoice) => invoice.id == selected.id)) {
      return [...candidates, selected];
    }
    return candidates;
  }

  String _intervalLabel(AppLocalizations l10n, RecurrenceInterval interval) {
    return switch (interval) {
      RecurrenceInterval.daily => l10n.recurringIntervalDaily,
      RecurrenceInterval.weekly => l10n.recurringIntervalWeekly,
      RecurrenceInterval.monthly => l10n.recurringIntervalMonthly,
      RecurrenceInterval.quarterly => l10n.recurringIntervalQuarterly,
      RecurrenceInterval.yearly => l10n.recurringIntervalYearly,
    };
  }
}

/// Static summary of the source invoice in edit mode.
class _SourceInvoiceTile extends StatelessWidget {
  const _SourceInvoiceTile({required this.schedule});

  final RecurringSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).recurringInvoiceLabel,
        prefixIcon: const Icon(Icons.receipt_outlined),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(schedule.invoiceNumber),
          Text(
            formatDate(schedule.issueDate),
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _InvoicePicker extends StatelessWidget {
  const _InvoicePicker({
    required this.invoices,
    required this.selected,
    required this.onChanged,
  });

  final List<Invoice> invoices;
  final Invoice? selected;
  final ValueChanged<Invoice?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<Invoice>(
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.recurringInvoiceLabel,
        prefixIcon: const Icon(Icons.receipt_outlined),
      ),
      items: [
        for (final invoice in invoices)
          DropdownMenuItem<Invoice>(
            value: invoice,
            child: Text('${invoice.number} · ${formatDate(invoice.issueDate)}'),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

/// Date field for optional dates; empty until picked. Optionally offers a
/// clear action that arms the matching clear flag on save.
class _OptionalDateField extends StatelessWidget {
  const _OptionalDateField({
    required this.label,
    required this.date,
    required this.onTap,
    this.onClear,
    this.isCleared = false,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  /// Shown when set and a date is displayed (or a clear is pending).
  final VoidCallback? onClear;
  final bool isCleared;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GewerberTokens.radiusField),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.event_outlined),
          helperText: isCleared
              ? AppLocalizations.of(context).recurringWillBeCleared
              : null,
          suffixIcon: onClear != null && (date != null || isCleared)
              ? IconButton(
                  tooltip: AppLocalizations.of(context).commonClear,
                  icon: const Icon(Icons.highlight_off_outlined),
                  onPressed: onClear,
                )
              : null,
        ),
        child: Text(
          date == null ? '' : formatDate(date!),
          style: date == null
              ? TextStyle(color: colors.onSurfaceVariant)
              : null,
        ),
      ),
    );
  }
}
