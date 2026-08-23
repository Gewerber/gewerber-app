import 'package:equatable/equatable.dart';

import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/invoice_template.dart';

/// Loading state of the invoice-template list.
enum InvoiceTemplateViewStatus { initial, loading, loaded, failure }

/// Immutable invoice-template state.
class InvoiceTemplateState extends Equatable {
  const InvoiceTemplateState({
    this.status = InvoiceTemplateViewStatus.initial,
    this.templates = const [],
    this.isSaving = false,
    this.failure,
  });

  final InvoiceTemplateViewStatus status;
  final List<InvoiceTemplate> templates;

  /// Whether a create/update request is currently in flight.
  final bool isSaving;

  final Failure? failure;

  bool get isLoading => status == InvoiceTemplateViewStatus.loading;

  InvoiceTemplateState copyWith({
    InvoiceTemplateViewStatus? status,
    List<InvoiceTemplate>? templates,
    bool? isSaving,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return InvoiceTemplateState(
      status: status ?? this.status,
      templates: templates ?? this.templates,
      isSaving: isSaving ?? this.isSaving,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, templates, isSaving, failure];
}
