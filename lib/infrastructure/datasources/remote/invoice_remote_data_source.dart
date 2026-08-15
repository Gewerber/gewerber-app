import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/invoice.dart';
import 'package:gewerber_app/infrastructure/core/serverpod_client_factory.dart';
import 'package:gewerber_app/infrastructure/mappers/invoice_mapper.dart';

/// Transport-level invoice calls against the Serverpod backend.
///
/// Every serverpod exception is translated into an [AppException] so higher
/// layers stay free of transport details.
@LazySingleton(env: [AppEnvironment.authLive])
class InvoiceRemoteDataSource {
  InvoiceRemoteDataSource(this._clientFactory, this._mapper);

  final ServerpodClientFactory _clientFactory;
  final InvoiceMapper _mapper;

  sdk.Client get _client => _clientFactory.client;

  Future<List<Invoice>> list({
    InvoiceStatus? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final models = await _client.invoice.list(
        status: status == null ? null : _mapper.toProtocolStatus(status),
        limit: limit,
        offset: offset,
      );
      return models.map(_mapper.fromModel).toList();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<({Invoice invoice, List<InvoiceItem> items})> get(
    int invoiceId,
  ) async {
    try {
      final invoice = await _client.invoice.get(invoiceId);
      final items = await _client.invoice.getItems(invoiceId);
      return (
        invoice: _mapper.fromModel(invoice),
        items: items.map(_mapper.itemFromModel).toList(),
      );
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<Invoice> create({
    required List<InvoiceItem> items,
    int? customerId,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? serviceDateFrom,
    DateTime? serviceDateTo,
    String? notes,
  }) async {
    try {
      final model = await _client.invoice.create(
        sdk.CreateInvoiceRequest(
          customerId: customerId,
          issueDate: issueDate,
          dueDate: dueDate,
          serviceDateFrom: serviceDateFrom,
          serviceDateTo: serviceDateTo,
          notes: notes,
          items: items.map(_mapper.toItemRequest).toList(),
        ),
      );
      return _mapper.fromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<Invoice> update(
    Invoice invoice, {
    required List<InvoiceItem> items,
  }) async {
    try {
      final model = await _client.invoice.update(
        sdk.UpdateInvoiceRequest(
          invoiceId: invoice.id,
          customerId: invoice.customerId,
          issueDate: invoice.issueDate,
          dueDate: invoice.dueDate,
          serviceDateFrom: invoice.serviceDateFrom,
          serviceDateTo: invoice.serviceDateTo,
          paymentTermsDays: 14,
          notes: invoice.notes,
          items: items.map(_mapper.toItemRequest).toList(),
        ),
      );
      return _mapper.fromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<void> delete(int invoiceId) async {
    try {
      await _client.invoice.delete(invoiceId);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }
}
