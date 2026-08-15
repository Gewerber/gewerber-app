import 'package:equatable/equatable.dart';

import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';

/// Loading state of the invoice list.
enum InvoiceViewStatus { initial, loading, loaded, failure }

/// Immutable invoice state.
class InvoiceState extends Equatable {
  const InvoiceState({
    this.status = InvoiceViewStatus.initial,
    this.invoices = const [],
    this.failure,
  });

  final InvoiceViewStatus status;
  final List<Invoice> invoices;
  final Failure? failure;

  bool get isLoading => status == InvoiceViewStatus.loading;

  InvoiceState copyWith({
    InvoiceViewStatus? status,
    List<Invoice>? invoices,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return InvoiceState(
      status: status ?? this.status,
      invoices: invoices ?? this.invoices,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, invoices, failure];
}
