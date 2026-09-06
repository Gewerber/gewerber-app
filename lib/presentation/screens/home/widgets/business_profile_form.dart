import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/business/business_cubit.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/domain/entities/business.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';
import 'package:gewerber_app/presentation/widgets/forms/field_hint.dart';
import 'package:gewerber_app/presentation/widgets/forms/field_info_icon.dart';
import 'package:gewerber_app/presentation/widgets/forms/field_label.dart';

/// BusinessProfileForm — editable business profile form (extracted for master-detail).
class BusinessProfileForm extends StatefulWidget {
  const BusinessProfileForm({super.key});

  @override
  State<BusinessProfileForm> createState() => _BusinessProfileFormState();
}

class _BusinessProfileFormState extends State<BusinessProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _vatIdController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _zipController = TextEditingController();
  final _cityController = TextEditingController();

  LegalForm _legalForm = LegalForm.einzelunternehmen;
  bool _isKleinunternehmer = false;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _vatIdController.dispose();
    _taxNumberController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _zipController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _initFrom(Business? business) {
    if (_initialized || business == null) return;
    _initialized = true;
    _nameController.text = business.name;
    _vatIdController.text = business.vatId ?? '';
    _taxNumberController.text = business.taxNumber ?? '';
    _emailController.text = business.email ?? '';
    _phoneController.text = business.phone ?? '';
    _streetController.text = business.address?.street ?? '';
    _zipController.text = business.address?.zip ?? '';
    _cityController.text = business.address?.city ?? '';
    _legalForm = business.legalForm;
    _isKleinunternehmer = business.isKleinunternehmer;
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final business = context.read<BusinessCubit>().state.activeBusiness;
    if (business == null) return;

    setState(() => _isSaving = true);
    final saved = await context.read<BusinessCubit>().update(
      Business(
        id: business.id,
        name: _nameController.text.trim(),
        legalForm: _legalForm,
        isKleinunternehmer: _isKleinunternehmer,
        vatId: _vatIdController.text.trim().isEmpty
            ? null
            : _vatIdController.text.trim(),
        taxNumber: _taxNumberController.text.trim().isEmpty
            ? null
            : _taxNumberController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        address: _addressValid()
            ? Address(
                street: _streetController.text.trim(),
                zip: _zipController.text.trim(),
                city: _cityController.text.trim(),
              )
            : null,
        locale: business.locale,
        currency: business.currency,
      ),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved ? l10n.businessFormSaved : l10n.businessFormError),
      ),
    );
  }

  bool _addressValid() {
    return _streetController.text.trim().isNotEmpty &&
        _zipController.text.trim().isNotEmpty &&
        _cityController.text.trim().isNotEmpty;
  }

  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final business = context.select<BusinessCubit, Business?>(
      (cubit) => cubit.state.activeBusiness,
    );
    _initFrom(business);

    if (business == null) {
      return Center(child: Text(l10n.businessProfileSubtitle));
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.businessFormName,
              prefixIcon: const Icon(Icons.storefront_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.authValidationError;
              }
              return null;
            },
          ),
          const SizedBox(height: GewerberTokens.space16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FieldLabel(
                label: l10n.businessFormLegalForm,
                infoText: l10n.fieldHintLegalForm,
              ),
              const SizedBox(height: GewerberTokens.space8),
              DropdownButtonFormField<LegalForm>(
                initialValue: _legalForm,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.gavel_outlined),
                ),
                items: [
                  for (final form in LegalForm.values)
                    DropdownMenuItem(
                      value: form,
                      child: Text(_legalFormLabel(form)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _legalForm = value);
                },
              ),
            ],
          ),
          const SizedBox(height: GewerberTokens.space8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Expanded(child: Text(l10n.businessFormKleinunternehmer)),
                FieldInfoIcon(
                  infoText: l10n.onboardingKleinunternehmerHint,
                  longInfoText: l10n.fieldHintKleinunternehmerInfo,
                  sheetTitle: l10n.businessFormKleinunternehmer,
                ),
              ],
            ),
            value: _isKleinunternehmer,
            onChanged: (value) {
              setState(() => _isKleinunternehmer = value);
            },
          ),
          const SizedBox(height: GewerberTokens.space16),
          CustomTextField(
            controller: _vatIdController,
            label: l10n.businessFormVatId,
            icon: Icons.badge_outlined,
            hint: FieldHint(
              shortText: l10n.onboardingVatIdHint,
              longText: l10n.fieldHintVatIdInfo,
            ),
            onHintMoreRequested: () => context.push(RouteNames.guideTips),
          ),
          const SizedBox(height: GewerberTokens.space16),
          CustomTextField(
            controller: _taxNumberController,
            label: l10n.onboardingTaxNumber,
            icon: Icons.receipt_long_outlined,
            hint: FieldHint(
              shortText: l10n.fieldHintTaxNumberShort,
              longText: l10n.fieldHintTaxNumberInfo,
            ),
            onHintMoreRequested: () => context.push(RouteNames.guideTips),
          ),
          const SizedBox(height: GewerberTokens.space16),
          CustomTextField(
            controller: _emailController,
            label: l10n.businessFormEmail,
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: GewerberTokens.space16),
          CustomTextField(
            controller: _phoneController,
            label: l10n.businessFormPhone,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: GewerberTokens.space24),
          Text(l10n.onboardingAddressSection, style: textTheme.titleMedium),
          const SizedBox(height: GewerberTokens.space12),
          CustomTextField(
            controller: _streetController,
            label: l10n.businessFormStreet,
            icon: Icons.home_outlined,
          ),
          const SizedBox(height: GewerberTokens.space12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _zipController,
                  label: l10n.businessFormZip,
                ),
              ),
              const SizedBox(width: GewerberTokens.space12),
              Expanded(
                flex: 2,
                child: CustomTextField(
                  controller: _cityController,
                  label: l10n.businessFormCity,
                ),
              ),
            ],
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
                  : Text(l10n.businessFormSave),
            ),
          ),
        ],
      ),
    );
  }

  String _legalFormLabel(LegalForm form) {
    return switch (form) {
      LegalForm.einzelunternehmen => l10n.onboardingLegalFormEinzelunternehmen,
      LegalForm.kleingewerbe => l10n.onboardingLegalFormKleingewerbe,
      LegalForm.freiberufler => l10n.onboardingLegalFormFreiberufler,
      LegalForm.gbr => l10n.onboardingLegalFormGbr,
      LegalForm.other => l10n.onboardingLegalFormOther,
    };
  }
}
