import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/invoice_templates/invoice_template_cubit.dart';
import 'package:gewerber_app/application/invoice_templates/invoice_template_state.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/domain/entities/invoice_template.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/router/route_names.dart';

/// InvoiceTemplatesScreen — list of the active business's invoice templates.
class InvoiceTemplatesScreen extends StatefulWidget {
  const InvoiceTemplatesScreen({super.key});

  @override
  State<InvoiceTemplatesScreen> createState() => _InvoiceTemplatesScreenState();
}

class _InvoiceTemplatesScreenState extends State<InvoiceTemplatesScreen> {
  @override
  void initState() {
    super.initState();
    // The invoicing module does not preload the templates; make sure they are
    // present when this screen is opened.
    final cubit = context.read<InvoiceTemplateCubit>();
    if (cubit.state.status == InvoiceTemplateViewStatus.initial) {
      cubit.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<InvoiceTemplateCubit>().state;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.templatesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.templateNew),
        icon: const Icon(Icons.add),
        label: Text(l10n.templatesAdd),
      ),
      body: switch (state.status) {
        InvoiceTemplateViewStatus.initial ||
        InvoiceTemplateViewStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        InvoiceTemplateViewStatus.failure => Center(
          child: Text(l10n.templatesLoadError),
        ),
        InvoiceTemplateViewStatus.loaded when state.templates.isEmpty =>
          _EmptyState(),
        InvoiceTemplateViewStatus.loaded => ListView.separated(
          padding: const EdgeInsets.all(GewerberTokens.space16),
          itemCount: state.templates.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final template = state.templates[index];
            return _TemplateTile(
              template: template,
              onTap: () =>
                  context.push(RouteNames.templateEdit, extra: template),
            );
          },
        ),
      },
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({required this.template, required this.onTap});

  final InvoiceTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final preview = [
      template.headerText,
      template.footerText,
    ].whereType<String>().join(' · ');

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            Icons.description_outlined,
            color: colors.onSurfaceVariant,
          ),
        ),
        title: Text(template.name),
        subtitle: preview.isEmpty ? null : Text(preview, maxLines: 1),
        trailing: template.isDefault
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: GewerberTokens.space8,
                  vertical: GewerberTokens.space2,
                ),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(
                    GewerberTokens.radiusChip,
                  ),
                ),
                child: Text(
                  l10n.templateDefaultBadge,
                  style: TextStyle(color: colors.onPrimaryContainer),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
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
            Icon(Icons.description_outlined, size: 56, color: colors.outline),
            const SizedBox(height: GewerberTokens.space16),
            Text(l10n.templatesEmpty, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
