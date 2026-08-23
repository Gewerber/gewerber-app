import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/invoice_templates/invoice_template_cubit.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/domain/entities/invoice_template.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/widgets/forms/custom_text_field.dart';

/// InvoiceTemplateEditScreen — create or edit an invoice template.
class InvoiceTemplateEditScreen extends StatefulWidget {
  const InvoiceTemplateEditScreen({super.key, this.template});

  /// The template being edited, or `null` to create a new one.
  final InvoiceTemplate? template;

  @override
  State<InvoiceTemplateEditScreen> createState() =>
      _InvoiceTemplateEditScreenState();
}

class _InvoiceTemplateEditScreenState extends State<InvoiceTemplateEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _headerController;
  late final TextEditingController _footerController;
  late bool _isDefault;
  bool _isSaving = false;

  bool get _isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    final template = widget.template;
    _nameController = TextEditingController(text: template?.name ?? '');
    _headerController = TextEditingController(text: template?.headerText ?? '');
    _footerController = TextEditingController(text: template?.footerText ?? '');
    _isDefault = template?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headerController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  String? _opt(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final l10n = AppLocalizations.of(context);
    final cubit = context.read<InvoiceTemplateCubit>();
    setState(() => _isSaving = true);

    final saved = _isEditing
        ? await cubit.update(
            InvoiceTemplate(
              id: widget.template!.id,
              name: _nameController.text.trim(),
              isDefault: _isDefault,
              headerText: _opt(_headerController),
              footerText: _opt(_footerController),
              logoDocumentId: widget.template!.logoDocumentId,
            ),
          )
        : await cubit.create(
            name: _nameController.text.trim(),
            isDefault: _isDefault,
            headerText: _opt(_headerController),
            footerText: _opt(_footerController),
          );

    if (!mounted) return;
    setState(() => _isSaving = false);
    if (saved) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.templateSaved)));
      context.pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.templateSaveError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.templateEditTitle : l10n.templateNewTitle,
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
                      labelText: l10n.templateName,
                      prefixIcon: const Icon(Icons.description_outlined),
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
                    controller: _headerController,
                    label: l10n.templateHeader,
                    icon: Icons.align_horizontal_left_outlined,
                  ),
                  const SizedBox(height: GewerberTokens.space16),
                  CustomTextField(
                    controller: _footerController,
                    label: l10n.templateFooter,
                    icon: Icons.align_horizontal_right_outlined,
                  ),
                  const SizedBox(height: GewerberTokens.space8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.templateIsDefault),
                    subtitle: Text(l10n.templateIsDefaultHint),
                    value: _isDefault,
                    onChanged: (value) => setState(() => _isDefault = value),
                  ),
                  const SizedBox(height: GewerberTokens.space24),
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
                          : Text(l10n.templateSave),
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
