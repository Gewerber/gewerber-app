import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/invoice_templates/invoice_template_cubit.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/invoice_template.dart';
import 'package:gewerber_app/domain/repositories/invoice_template_repository.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/invoice_templates_screen.dart';

class _FailingRepository implements InvoiceTemplateRepository {
  @override
  Future<List<InvoiceTemplate>> list({int? limit, int? offset}) async {
    throw const NetworkException();
  }

  @override
  Future<InvoiceTemplate> get(int templateId) async {
    throw const NetworkException();
  }

  @override
  Future<InvoiceTemplate> create({
    required String name,
    bool isDefault = false,
    String? headerText,
    String? footerText,
  }) async {
    throw const NetworkException();
  }

  @override
  Future<InvoiceTemplate> update(InvoiceTemplate template) async {
    throw const NetworkException();
  }
}

class _StaticRepository implements InvoiceTemplateRepository {
  _StaticRepository(List<InvoiceTemplate> templates)
    : _templates = List.of(templates);

  final List<InvoiceTemplate> _templates;

  @override
  Future<List<InvoiceTemplate>> list({int? limit, int? offset}) async =>
      List.unmodifiable(_templates);

  @override
  Future<InvoiceTemplate> get(int templateId) async => _templates.first;

  @override
  Future<InvoiceTemplate> create({
    required String name,
    bool isDefault = false,
    String? headerText,
    String? footerText,
  }) async => throw UnimplementedError();

  @override
  Future<InvoiceTemplate> update(InvoiceTemplate template) async =>
      throw UnimplementedError();
}

Future<void> pumpScreen(WidgetTester tester, InvoiceTemplateCubit cubit) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<InvoiceTemplateCubit>.value(
        value: cubit,
        child: const InvoiceTemplatesScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the load error when the templates cannot be fetched', (
    tester,
  ) async {
    await pumpScreen(tester, InvoiceTemplateCubit(_FailingRepository()));

    expect(
      find.text("We couldn't load the templates. Please try again."),
      findsOneWidget,
    );
  });

  testWidgets('renders saved templates with the default badge', (tester) async {
    final cubit = InvoiceTemplateCubit(
      _StaticRepository([
        const InvoiceTemplate(id: 1, name: 'Standard'),
        const InvoiceTemplate(id: 2, name: 'Letterhead', isDefault: true),
      ]),
    );

    await pumpScreen(tester, cubit);

    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('Letterhead'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);
  });
}
