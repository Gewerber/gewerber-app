import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/customers/customer_cubit.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/domain/entities/business.dart';
import 'package:gewerber_app/domain/entities/customer.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';
import 'package:gewerber_app/presentation/widgets/forms/field_hint.dart';

/// CustomerEditScreen — create or edit a customer.
class CustomerEditScreen extends StatefulWidget {
  const CustomerEditScreen({super.key, this.customer});

  /// The customer being edited, or `null` to create a new one.
  final Customer? customer;

  @override
  State<CustomerEditScreen> createState() => _CustomerEditScreenState();
}

class _CustomerEditScreenState extends State<CustomerEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _companyController;
  late final TextEditingController _vatIdController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _streetController;
  late final TextEditingController _zipController;
  late final TextEditingController _cityController;
  bool _isSaving = false;

  bool get _isEditing => widget.customer != null;

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    _nameController = TextEditingController(text: customer?.name ?? '');
    _companyController = TextEditingController(
      text: customer?.companyName ?? '',
    );
    _vatIdController = TextEditingController(text: customer?.vatId ?? '');
    _emailController = TextEditingController(text: customer?.email ?? '');
    _phoneController = TextEditingController(text: customer?.phone ?? '');
    _streetController = TextEditingController(
      text: customer?.address?.street ?? '',
    );
    _zipController = TextEditingController(text: customer?.address?.zip ?? '');
    _cityController = TextEditingController(
      text: customer?.address?.city ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _vatIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _zipController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = AppLocalizations.of(context);
    final cubit = context.read<CustomerCubit>();
    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final email = _opt(_emailController);
    final phone = _opt(_phoneController);
    final vatId = _opt(_vatIdController);
    final address = _addressValid()
        ? Address(
            street: _streetController.text.trim(),
            zip: _zipController.text.trim(),
            city: _cityController.text.trim(),
          )
        : null;

    final saved = _isEditing
        ? await cubit.update(
            Customer(
              id: widget.customer!.id,
              name: name,
              companyName: _opt(_companyController),
              vatId: vatId,
              email: email,
              phone: phone,
              address: address,
              notes: widget.customer!.notes,
              status: widget.customer!.status,
            ),
          )
        : await cubit.create(
            name: name,
            companyName: _opt(_companyController),
            vatId: vatId,
            email: email,
            phone: phone,
            address: address,
          );

    if (!mounted) return;
    setState(() => _isSaving = false);
    if (saved) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.customerSaved)));
      context.pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.customerError)));
    }
  }

  String? _opt(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  bool _addressValid() {
    return _streetController.text.trim().isNotEmpty &&
        _zipController.text.trim().isNotEmpty &&
        _cityController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.customerEditTitle : l10n.customerNewTitle,
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
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.customerName,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.authValidationError;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: GewerberTokens.space16),
                  CustomTextField(
                    controller: _companyController,
                    label: l10n.customerCompany,
                    icon: Icons.business_outlined,
                  ),
                  const SizedBox(height: GewerberTokens.space16),
                  CustomTextField(
                    controller: _vatIdController,
                    label: l10n.customerVatId,
                    icon: Icons.badge_outlined,
                    hint: FieldHint(
                      shortText: l10n.onboardingVatIdHint,
                      longText: l10n.fieldHintCustomerVatIdInfo,
                    ),
                    onHintMoreRequested: () =>
                        context.push(RouteNames.guideTips),
                  ),
                  const SizedBox(height: GewerberTokens.space16),
                  CustomTextField(
                    controller: _emailController,
                    label: l10n.customerEmail,
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: GewerberTokens.space16),
                  CustomTextField(
                    controller: _phoneController,
                    label: l10n.customerPhone,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: GewerberTokens.space24),
                  Text(
                    l10n.onboardingAddressSection,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: GewerberTokens.space12),
                  CustomTextField(
                    controller: _streetController,
                    label: l10n.customerStreet,
                    icon: Icons.home_outlined,
                  ),
                  const SizedBox(height: GewerberTokens.space12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _zipController,
                          label: l10n.customerZip,
                        ),
                      ),
                      const SizedBox(width: GewerberTokens.space12),
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          controller: _cityController,
                          label: l10n.customerCity,
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
                          : Text(l10n.customerSave),
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
