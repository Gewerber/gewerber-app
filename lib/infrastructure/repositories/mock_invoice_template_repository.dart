import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/domain/entities/invoice_template.dart';
import 'package:gewerber_app/domain/repositories/invoice_template_repository.dart';

/// In-memory [InvoiceTemplateRepository] backing the demo experience and the
/// widget tests. Data lives for the app session only.
@LazySingleton(as: InvoiceTemplateRepository, env: [AppEnvironment.authMock])
class MockInvoiceTemplateRepository implements InvoiceTemplateRepository {
  final List<InvoiceTemplate> _templates = [];
  int _nextId = 1;

  /// Clears all stored templates (used by tests to isolate scenarios).
  void reset() {
    _templates.clear();
    _nextId = 1;
  }

  @override
  Future<List<InvoiceTemplate>> list({int? limit, int? offset}) async {
    final start = offset ?? 0;
    return _templates.skip(start).take(limit ?? _templates.length).toList();
  }

  @override
  Future<InvoiceTemplate> get(int templateId) async {
    return _templates.firstWhere((template) => template.id == templateId);
  }

  @override
  Future<InvoiceTemplate> create({
    required String name,
    bool isDefault = false,
    String? headerText,
    String? footerText,
  }) async {
    final template = InvoiceTemplate(
      id: _nextId++,
      name: name,
      isDefault: isDefault,
      headerText: headerText,
      footerText: footerText,
    );
    // Mirror the server rule: at most one default per business.
    if (isDefault) {
      _clearDefaultsExcept(template.id);
    }
    _templates.add(template);
    return template;
  }

  @override
  Future<InvoiceTemplate> update(InvoiceTemplate template) async {
    final index = _templates.indexWhere((value) => value.id == template.id);
    if (index < 0) {
      throw StateError('Unknown invoice template ${template.id}');
    }
    // Mirror the server rule: at most one default per business.
    if (template.isDefault) {
      _clearDefaultsExcept(template.id);
    }
    _templates[index] = template;
    return template;
  }

  void _clearDefaultsExcept(int templateId) {
    for (var i = 0; i < _templates.length; i++) {
      final current = _templates[i];
      if (current.id != templateId && current.isDefault) {
        _templates[i] = InvoiceTemplate(
          id: current.id,
          name: current.name,
          headerText: current.headerText,
          footerText: current.footerText,
          logoDocumentId: current.logoDocumentId,
        );
      }
    }
  }
}
