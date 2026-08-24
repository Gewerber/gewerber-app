import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/invoice_template.dart';
import 'package:gewerber_app/infrastructure/core/serverpod_client_factory.dart';

/// Transport-level invoice-template calls against the Serverpod backend.
///
/// Every serverpod exception is translated into an [AppException] so higher
/// layers stay free of transport details.
@LazySingleton(env: [AppEnvironment.authLive])
class InvoiceTemplateRemoteDataSource {
  InvoiceTemplateRemoteDataSource(this._clientFactory);

  final ServerpodClientFactory _clientFactory;

  sdk.Client get _client => _clientFactory.client;

  Future<List<InvoiceTemplate>> list({int? limit, int? offset}) async {
    try {
      final models = await _client.invoiceTemplate.list(
        limit: limit,
        offset: offset,
      );
      return models.map(_fromModel).toList();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<InvoiceTemplate> get(int templateId) async {
    try {
      final model = await _client.invoiceTemplate.get(templateId);
      return _fromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<InvoiceTemplate> create({
    required String name,
    bool isDefault = false,
    String? headerText,
    String? footerText,
  }) async {
    try {
      final model = await _client.invoiceTemplate.create(
        sdk.CreateInvoiceTemplateRequest(
          name: name,
          isDefault: isDefault,
          headerText: headerText,
          footerText: footerText,
        ),
      );
      return _fromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<InvoiceTemplate> update(InvoiceTemplate template) async {
    try {
      final model = await _client.invoiceTemplate.update(
        sdk.UpdateInvoiceTemplateRequest(
          templateId: template.id,
          name: template.name,
          isDefault: template.isDefault,
          headerText: template.headerText,
          footerText: template.footerText,
          logoDocumentId: template.logoDocumentId,
        ),
      );
      return _fromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  InvoiceTemplate _fromModel(sdk.InvoiceTemplate model) {
    return InvoiceTemplate(
      id: model.id ?? -1,
      name: model.name,
      isDefault: model.isDefault,
      headerText: model.headerText,
      footerText: model.footerText,
      logoDocumentId: model.logoDocumentId,
    );
  }
}
