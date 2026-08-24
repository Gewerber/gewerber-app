import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/invoice_templates/invoice_template_state.dart';
import 'package:gewerber_app/core/errors/error_handler.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/invoice_template.dart';
import 'package:gewerber_app/domain/repositories/invoice_template_repository.dart';

/// Owns the invoice templates of the active business.
@LazySingleton()
class InvoiceTemplateCubit extends Cubit<InvoiceTemplateState> {
  InvoiceTemplateCubit(this._repository) : super(const InvoiceTemplateState());

  final InvoiceTemplateRepository _repository;

  /// Loads the invoice templates.
  Future<void> load() async {
    if (state.isLoading) return;
    emit(
      state.copyWith(
        status: InvoiceTemplateViewStatus.loading,
        clearFailure: true,
      ),
    );
    try {
      final templates = await _repository.list();
      if (isClosed) return;
      emit(
        InvoiceTemplateState(
          status: InvoiceTemplateViewStatus.loaded,
          templates: templates,
        ),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: InvoiceTemplateViewStatus.failure,
          failure: mapAppException(e),
        ),
      );
    } on Exception {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: InvoiceTemplateViewStatus.failure,
          failure: const NetworkFailure(),
        ),
      );
    }
  }

  /// Creates a template for the active business.
  ///
  /// Returns `true` on success.
  Future<bool> create({
    required String name,
    bool isDefault = false,
    String? headerText,
    String? footerText,
  }) async {
    emit(state.copyWith(isSaving: true, clearFailure: true));
    try {
      final template = await _repository.create(
        name: name,
        isDefault: isDefault,
        headerText: headerText,
        footerText: footerText,
      );
      if (!isClosed) emit(_saved(template));
      return true;
    } on Exception {
      if (!isClosed) emit(state.copyWith(isSaving: false));
      return false;
    }
  }

  /// Updates an existing template.
  ///
  /// Returns `true` on success.
  Future<bool> update(InvoiceTemplate template) async {
    emit(state.copyWith(isSaving: true, clearFailure: true));
    try {
      final updated = await _repository.update(template);
      if (!isClosed) emit(_saved(updated));
      return true;
    } on Exception {
      if (!isClosed) emit(state.copyWith(isSaving: false));
      return false;
    }
  }

  /// Applies a saved template to the list.
  ///
  /// Mirrors the server rule that at most one template per business carries
  /// the default flag.
  InvoiceTemplateState _saved(InvoiceTemplate saved) {
    final templates = <InvoiceTemplate>[];
    var replaced = false;
    for (final current in state.templates) {
      if (current.id == saved.id) {
        templates.add(saved);
        replaced = true;
      } else if (saved.isDefault && current.isDefault) {
        templates.add(current.copyWith(isDefault: false));
      } else {
        templates.add(current);
      }
    }
    if (!replaced) templates.add(saved);
    return InvoiceTemplateState(
      status: InvoiceTemplateViewStatus.loaded,
      templates: templates,
    );
  }

  /// Resolves the business's default template without touching the UI
  /// state.
  ///
  /// Used as best-effort prefill for new invoices: returns `null` when no
  /// template is marked as default or the lookup fails, so a template error
  /// never blocks invoice creation.
  Future<InvoiceTemplate?> resolveDefaultTemplate() async {
    var templates = state.templates;
    if (state.status != InvoiceTemplateViewStatus.loaded) {
      try {
        templates = await _repository.list();
      } on Exception {
        return null;
      }
    }
    for (final template in templates) {
      if (template.isDefault) return template;
    }
    return null;
  }

  /// Resets to the initial state.
  void reset() {
    emit(const InvoiceTemplateState());
  }
}
