import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/invoice_templates/invoice_template_cubit.dart';
import 'package:gewerber_app/application/invoice_templates/invoice_template_state.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/invoice_template.dart';
import 'package:gewerber_app/domain/repositories/invoice_template_repository.dart';

class _FakeInvoiceTemplateRepository implements InvoiceTemplateRepository {
  _FakeInvoiceTemplateRepository({
    List<InvoiceTemplate>? templates,
    this.failLoad = false,
    this.failSave = false,
  }) : _templates = List.of(templates ?? const []);

  final List<InvoiceTemplate> _templates;
  bool failLoad;
  bool failSave;

  @override
  Future<List<InvoiceTemplate>> list({int? limit, int? offset}) async {
    if (failLoad) throw const NetworkException();
    return List.unmodifiable(_templates);
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
    if (failSave) throw const NetworkException();
    // Mirror the server rule: at most one default per business.
    if (isDefault) {
      for (var i = 0; i < _templates.length; i++) {
        _templates[i] = _templates[i].copyWith(isDefault: false);
      }
    }
    final template = InvoiceTemplate(
      id: _templates.length + 1,
      name: name,
      isDefault: isDefault,
      headerText: headerText,
      footerText: footerText,
    );
    _templates.add(template);
    return template;
  }

  @override
  Future<InvoiceTemplate> update(InvoiceTemplate template) async {
    if (failSave) throw const NetworkException();
    final index = _templates.indexWhere((value) => value.id == template.id);
    if (index < 0) throw StateError('Unknown template ${template.id}');
    // Mirror the server rule: at most one default per business.
    if (template.isDefault) {
      for (var i = 0; i < _templates.length; i++) {
        if (_templates[i].id != template.id) {
          _templates[i] = _templates[i].copyWith(isDefault: false);
        }
      }
    }
    _templates[index] = template;
    return template;
  }
}

void main() {
  const template = InvoiceTemplate(id: 1, name: 'Standard');

  test('starts in the initial state', () {
    final cubit = InvoiceTemplateCubit(_FakeInvoiceTemplateRepository());

    expect(cubit.state.status, InvoiceTemplateViewStatus.initial);
    expect(cubit.state.templates, isEmpty);
  });

  test('load emits loading then loaded with the templates', () async {
    final cubit = InvoiceTemplateCubit(
      _FakeInvoiceTemplateRepository(templates: [template]),
    );
    final states = <InvoiceTemplateViewStatus>[];
    cubit.stream.listen((state) => states.add(state.status));

    await cubit.load();
    await Future<void>.delayed(Duration.zero);

    expect(states, [
      InvoiceTemplateViewStatus.loading,
      InvoiceTemplateViewStatus.loaded,
    ]);
    expect(cubit.state.templates, [template]);
  });

  test('load failure maps to a failure state', () async {
    final cubit = InvoiceTemplateCubit(
      _FakeInvoiceTemplateRepository(failLoad: true),
    );

    await cubit.load();

    expect(cubit.state.status, InvoiceTemplateViewStatus.failure);
    expect(cubit.state.failure, isA<NetworkFailure>());
  });

  test('create appends the template and returns true', () async {
    final cubit = InvoiceTemplateCubit(_FakeInvoiceTemplateRepository());

    final created = await cubit.create(name: 'Standard');

    expect(created, isTrue);
    expect(cubit.state.templates.single.name, 'Standard');
    expect(cubit.state.isSaving, isFalse);
  });

  test('create failure returns false and keeps the list unchanged', () async {
    final cubit = InvoiceTemplateCubit(
      _FakeInvoiceTemplateRepository(templates: [template], failSave: true),
    );
    await cubit.load();

    final created = await cubit.create(name: 'Broken');

    expect(created, isFalse);
    expect(cubit.state.templates.single.name, 'Standard');
    expect(cubit.state.isSaving, isFalse);
  });

  test('update replaces the matching template', () async {
    final cubit = InvoiceTemplateCubit(
      _FakeInvoiceTemplateRepository(templates: [template]),
    );
    await cubit.load();

    final updated = await cubit.update(
      const InvoiceTemplate(id: 1, name: 'Renamed'),
    );

    expect(updated, isTrue);
    expect(cubit.state.templates.single.name, 'Renamed');
  });

  test('making a template the default clears the flag on the others', () async {
    final other = const InvoiceTemplate(id: 2, name: 'Other', isDefault: true);
    final cubit = InvoiceTemplateCubit(
      _FakeInvoiceTemplateRepository(templates: [template, other]),
    );
    await cubit.load();

    await cubit.update(
      const InvoiceTemplate(id: 1, name: 'Standard', isDefault: true),
    );

    expect(cubit.state.templates[0].isDefault, isTrue);
    expect(cubit.state.templates[1].isDefault, isFalse);
  });

  test('update failure returns false and keeps the stored value', () async {
    final cubit = InvoiceTemplateCubit(
      _FakeInvoiceTemplateRepository(templates: [template], failSave: true),
    );
    await cubit.load();

    final updated = await cubit.update(
      const InvoiceTemplate(id: 1, name: 'Broken'),
    );

    expect(updated, isFalse);
    expect(cubit.state.templates.single.name, 'Standard');
  });

  test('reset returns to the initial state', () async {
    final cubit = InvoiceTemplateCubit(
      _FakeInvoiceTemplateRepository(templates: [template]),
    );
    await cubit.load();

    cubit.reset();

    expect(cubit.state.status, InvoiceTemplateViewStatus.initial);
    expect(cubit.state.templates, isEmpty);
  });

  group('resolveDefaultTemplate', () {
    test('returns the template marked as default', () async {
      final cubit = InvoiceTemplateCubit(
        _FakeInvoiceTemplateRepository(
          templates: [
            const InvoiceTemplate(id: 1, name: 'Standard'),
            const InvoiceTemplate(id: 2, name: 'Letterhead', isDefault: true),
          ],
        ),
      );

      final resolved = await cubit.resolveDefaultTemplate();

      expect(resolved?.id, 2);
      // The lookup must not touch the UI state.
      expect(cubit.state.status, InvoiceTemplateViewStatus.initial);
    });

    test('loads templates lazily when not loaded yet', () async {
      final repository = _FakeInvoiceTemplateRepository(
        templates: [
          const InvoiceTemplate(id: 5, name: 'Default', isDefault: true),
        ],
      );
      final cubit = InvoiceTemplateCubit(repository);

      final resolved = await cubit.resolveDefaultTemplate();

      expect(resolved?.id, 5);
    });

    test('returns null when no template is the default', () async {
      final cubit = InvoiceTemplateCubit(
        _FakeInvoiceTemplateRepository(templates: [template]),
      );

      expect(await cubit.resolveDefaultTemplate(), isNull);
    });

    test('returns null on repository failures instead of throwing', () async {
      final cubit = InvoiceTemplateCubit(
        _FakeInvoiceTemplateRepository(failLoad: true),
      );

      expect(await cubit.resolveDefaultTemplate(), isNull);
    });
  });
}
