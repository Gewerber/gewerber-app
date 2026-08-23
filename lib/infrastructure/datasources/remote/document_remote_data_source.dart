import 'dart:typed_data';

import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/document.dart';
import 'package:gewerber_app/infrastructure/core/serverpod_client_factory.dart';
import 'package:gewerber_app/infrastructure/mappers/document_mapper.dart';

/// Transport-level document calls against the Serverpod backend.
///
/// Every serverpod exception is translated into an [AppException] so higher
/// layers stay free of transport details.
@LazySingleton(env: [AppEnvironment.authLive])
class DocumentRemoteDataSource {
  DocumentRemoteDataSource(this._clientFactory, this._mapper);

  final ServerpodClientFactory _clientFactory;
  final DocumentMapper _mapper;

  sdk.Client get _client => _clientFactory.client;

  Future<List<BusinessDocument>> list({
    DocumentKind? kind,
    String? relatedEntityType,
    String? relatedEntityId,
    int? limit,
    int? offset,
  }) async {
    try {
      final models = await _client.document.list(
        kind: kind == null ? null : _mapper.toProtocolKind(kind),
        relatedEntityType: relatedEntityType,
        relatedEntityId: relatedEntityId,
        limit: limit,
        offset: offset,
      );
      return models.map(_mapper.fromModel).toList();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<BusinessDocument> upload({
    required int businessId,
    required PickedFileAttachment file,
    DocumentKind kind = DocumentKind.attachment,
    String? relatedEntityType,
    String? relatedEntityId,
  }) async {
    try {
      final model = await _client.document.upload(
        sdk.UploadDocumentRequest(
          businessId: businessId,
          kind: _mapper.toProtocolKind(kind),
          fileName: file.fileName,
          mimeType: file.mimeType,
          data: ByteData.sublistView(Uint8List.fromList(file.bytes)),
          relatedEntityType: relatedEntityType,
          relatedEntityId: relatedEntityId,
        ),
      );
      return _mapper.fromModel(model);
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }

  Future<DownloadedDocument> download(BusinessDocument document) async {
    try {
      final data = await _client.document.download(document.id);
      return DownloadedDocument(
        documentId: document.id,
        fileName: document.fileName,
        bytes: data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
    } on sdk.NotFoundException {
      throw const NotFoundException();
    } on sdk.ServerpodClientException {
      throw const NetworkException();
    }
  }
}
