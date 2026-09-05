import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/business/business_cubit.dart';
import 'package:gewerber_app/application/business_settings/business_settings_cubit.dart';
import 'package:gewerber_app/application/business_settings/business_settings_state.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/domain/entities/business_settings.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';
import 'package:gewerber_app/presentation/widgets/forms/field_hint.dart';

/// BusinessSettingsForm — invoice numbering and payment terms form (extracted for master-detail).
class BusinessSettingsForm extends StatefulWidget {
  const BusinessSettingsForm({super.key});

  @override
  State<BusinessSettingsForm> createState() => _BusinessSettingsFormState();
}

class _BusinessSettingsFormState extends State<BusinessSettingsForm> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final businessId = context.read<BusinessCubit>().state.activeBusiness?.id;
    if (businessId != null) {
      context.read<BusinessSettingsCubit>().load(businessId: businessId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<BusinessSettingsCubit>().state;

    return switch (state.status) {
      BusinessSettingsViewStatus.loading ||
      BusinessSettingsViewStatus.initial => const Center(
        child: CircularProgressIndicator(),
      ),
      BusinessSettingsViewStatus.failure => Center(
        child: Text(l10n.businessSettingsError),
      ),
      BusinessSettingsViewStatus.loaded => _SettingsForm(
        initialSettings: state.settings,
        isSaving: state.isSaving,
        onSave: _save,
      ),
    };
  }

  Future<void> _save(BusinessSettings settings) async {
    final businessId = context.read<BusinessCubit>().state.activeBusiness?.id;
    final l10n = AppLocalizations.of(context);
    if (businessId == null) return;

    final saved = await context.read<BusinessSettingsCubit>().update(
      settings,
      businessId: businessId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved ? l10n.businessSettingsSaved : l10n.businessSettingsError,
        ),
      ),
    );
  }
}

class _SettingsForm extends StatefulWidget {
  const _SettingsForm({
    required this.initialSettings,
    required this.isSaving,
    required this.onSave,
  });

  final BusinessSettings initialSettings;
  final bool isSaving;
  final ValueChanged<BusinessSettings> onSave;

  @override
  State<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<_SettingsForm> {
  late final TextEditingController _prefixController;
  late int _dueDays;
  late bool _includeYear;
  late int _minDigits;
  bool _initDone = false;

  @override
  void initState() {
    super.initState();
    _prefixController = TextEditingController(
      text: widget.initialSettings.invoiceNumberPrefix ?? '',
    );
    _dueDays = widget.initialSettings.paymentTermsDays;
    _includeYear = widget.initialSettings.invoiceNumberIncludeYear;
    _minDigits = widget.initialSettings.invoiceNumberMinDigits;
  }

  @override
  void didUpdateWidget(_SettingsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_initDone && widget.initialSettings != oldWidget.initialSettings) {
      _initDone = true;
      _prefixController.text = widget.initialSettings.invoiceNumberPrefix ?? '';
      _dueDays = widget.initialSettings.paymentTermsDays;
      _includeYear = widget.initialSettings.invoiceNumberIncludeYear;
      _minDigits = widget.initialSettings.invoiceNumberMinDigits;
    }
  }

  @override
  void dispose() {
    _prefixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.businessSettingsSubtitle, style: textTheme.bodyLarge),
        const SizedBox(height: GewerberTokens.space24),
        Text(l10n.businessSettingsPaymentTerms, style: textTheme.titleMedium),
        const SizedBox(height: GewerberTokens.space12),
        TextFormField(
          initialValue: '$_dueDays',
          decoration: InputDecoration(
            labelText: l10n.businessSettingsDueDays,
            prefixIcon: const Icon(Icons.event_outlined),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _dueDays = int.tryParse(value) ?? _dueDays;
          },
        ),
        const SizedBox(height: GewerberTokens.space24),
        Text(l10n.businessSettingsInvoiceNumber, style: textTheme.titleMedium),
        const SizedBox(height: GewerberTokens.space12),
        CustomTextField(
          controller: _prefixController,
          label: l10n.businessSettingsNumberPrefix,
          helperText: l10n.businessSettingsNumberPrefixHint,
          hint: FieldHint(
            shortText: l10n.businessSettingsNumberPrefixHint,
            longText: l10n.fieldHintNumberPrefixInfo,
          ),
          onHintMoreRequested: () => context.push(RouteNames.guideTips),
        ),
        const SizedBox(height: GewerberTokens.space8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.businessSettingsIncludeYear),
          value: _includeYear,
          onChanged: (value) => setState(() => _includeYear = value),
        ),
        const SizedBox(height: GewerberTokens.space8),
        TextFormField(
          initialValue: '$_minDigits',
          decoration: InputDecoration(
            labelText: l10n.businessSettingsMinDigits,
            prefixIcon: const Icon(Icons.tag_outlined),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _minDigits = int.tryParse(value) ?? _minDigits;
          },
        ),
        const SizedBox(height: GewerberTokens.space32),
        FilledButton(
          onPressed: widget.isSaving ? null : _submit,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: GewerberTokens.space4,
            ),
            child: widget.isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.businessSettingsSave),
          ),
        ),
      ],
    );
  }

  void _submit() {
    widget.onSave(
      widget.initialSettings.copyWith(
        paymentTermsDays: _dueDays,
        invoiceNumberPrefix: _prefixController.text.trim().isEmpty
            ? null
            : _prefixController.text.trim(),
        clearInvoiceNumberPrefix: _prefixController.text.trim().isEmpty,
        invoiceNumberIncludeYear: _includeYear,
        invoiceNumberMinDigits: _minDigits,
      ),
    );
  }
}
