import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/business/business_cubit.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/domain/entities/business.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/screens/onboarding/widgets/preferences_step.dart';
import 'package:gewerber_app/presentation/widgets/auth/auth_primary_button.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';
import 'package:gewerber_app/presentation/widgets/forms/field_hint.dart';
import 'package:gewerber_app/presentation/widgets/forms/field_info_icon.dart';
import 'package:gewerber_app/presentation/widgets/forms/field_label.dart';

/// Onboarding — set up the app and create the user's first business.
///
/// Shown to signed-in users without a business. The flow has two steps:
/// 1. [PreferencesStep] — pick theme and language (initial-stage personalization).
/// 2. Business form — create the first business.
///
/// On success the router moves the user into the app shell.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  /// 0 = preferences (theme/language), 1 = business setup form.
  int _step = 0;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _vatIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _zipController = TextEditingController();
  final _cityController = TextEditingController();

  LegalForm _legalForm = LegalForm.einzelunternehmen;
  bool _isKleinunternehmer = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _vatIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _zipController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final created = await context.read<BusinessCubit>().create(
      name: _nameController.text.trim(),
      legalForm: _legalForm,
      isKleinunternehmer: _isKleinunternehmer,
      vatId: _vatIdController.text.trim().isEmpty
          ? null
          : _vatIdController.text.trim(),
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
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (created) {
      context.go(RouteNames.app);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.onboardingError)));
    }
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _step == 0 ? l10n.onboardingPreferencesTitle : l10n.onboardingTitle,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: _step == 0 ? 0.5 : 1.0,
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l10n.onboardingStepOf(_step + 1, 2),
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(color: colors.outline),
                ),
                const SizedBox(height: GewerberTokens.space16),
                if (_step == 0)
                  PreferencesStep(onContinue: () => setState(() => _step = 1))
                else ...[
                  Text(l10n.onboardingSubtitle, style: textTheme.bodyLarge),
                  const SizedBox(height: GewerberTokens.space24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          controller: _nameController,
                          label: l10n.onboardingBusinessName,
                          icon: Icons.storefront_outlined,
                          helperText: l10n.onboardingBusinessNameHint,
                          textInputAction: TextInputAction.next,
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
                              label: l10n.onboardingLegalForm,
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
                                if (value != null) {
                                  setState(() => _legalForm = value);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: GewerberTokens.space16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(l10n.onboardingKleinunternehmer),
                              ),
                              FieldInfoIcon(
                                infoText: l10n.onboardingKleinunternehmerHint,
                                longInfoText:
                                    l10n.fieldHintKleinunternehmerInfo,
                                sheetTitle: l10n.onboardingKleinunternehmer,
                              ),
                            ],
                          ),
                          subtitle: Text(l10n.onboardingKleinunternehmerHint),
                          value: _isKleinunternehmer,
                          onChanged: (value) {
                            setState(() => _isKleinunternehmer = value);
                          },
                        ),
                        const SizedBox(height: GewerberTokens.space8),
                        CustomTextField(
                          controller: _vatIdController,
                          label: l10n.onboardingVatId,
                          icon: Icons.badge_outlined,
                          helperText: l10n.onboardingVatIdHint,
                          hint: FieldHint(
                            shortText: l10n.onboardingVatIdHint,
                            longText: l10n.fieldHintVatIdInfo,
                          ),
                          onHintMoreRequested: () =>
                              context.push(RouteNames.guideTips),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: GewerberTokens.space16),
                        CustomTextField(
                          controller: _emailController,
                          label: l10n.onboardingEmail,
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: GewerberTokens.space16),
                        CustomTextField(
                          controller: _phoneController,
                          label: l10n.onboardingPhone,
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: GewerberTokens.space24),
                        Text(
                          l10n.onboardingAddressSection,
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: GewerberTokens.space12),
                        CustomTextField(
                          controller: _streetController,
                          label:
                              '${l10n.onboardingStreet} (${l10n.onboardingOptional})',
                          icon: Icons.home_outlined,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: GewerberTokens.space12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _zipController,
                                label:
                                    '${l10n.onboardingZip} (${l10n.onboardingOptional})',
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(width: GewerberTokens.space12),
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                controller: _cityController,
                                label:
                                    '${l10n.onboardingCity} (${l10n.onboardingOptional})',
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: GewerberTokens.space32),
                        AuthPrimaryButton(
                          label: l10n.onboardingCreate,
                          isSubmitting: _isSubmitting,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: GewerberTokens.space8),
                        TextButton.icon(
                          onPressed: () => setState(() => _step = 0),
                          icon: const Icon(Icons.arrow_back_outlined),
                          label: Text(l10n.commonBack),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GewerberTokens.space16),
                  Text(
                    '${l10n.onboardingOptional} · ${l10n.onboardingKleinunternehmer}',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(color: colors.outline),
                  ),
                ],
              ],
            ),
          ),
        ),
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
