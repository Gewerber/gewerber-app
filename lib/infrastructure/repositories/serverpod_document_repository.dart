import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/document.dart';
import 'package:gewerber_app/domain/repositories/document_repository.dart';
import 'package:gewerber_app/infrastructure/datasources/remote/document_remote_data_source.dart';

/// Serverpod-backed [DocumentRepository].
@LazySingleton(as: DocumentRepository, env: [AppEnvironment.authLive])
class ServerpodDocumentRepository implements DocumentRepository {
  ServerpodDocumentRepository(this._dataSource);

  final DocumentRemoteDataSource _dataSource;

  @override
  Future<List<BusinessDocument>> list({
    DocumentKind? kind,
    String? relatedEntityType,
    String? relatedEntityId,
    int? limit,
    int? offset,
  }) {
    return _guard(
      () => _dataSource.list(
        kind: kind,
        relatedEntityType: relatedEntityType,
        relatedEntityId: relatedEntityId,
        limit: limit,
        offset: offset,
      ),
    );
  }

  @override
  Future<BusinessDocument> upload({
    required int businessId,
    required PickedFileAttachment file,
    DocumentKind kind = DocumentKind.attachment,
    String? relatedEntityType,
    String? relatedEntityId,
  }) {
    return _guard(
      () => _dataSource.upload(
        businessId: businessId,
        file: file,
        kind: kind,
        relatedEntityType: relatedEntityType,
        relatedEntityId: relatedEntityId,
      ),
    );
  }

  @override
  Future<DownloadedDocument> download(BusinessDocument document) {
    return _guard(() => _dataSource.download(document));
  }

  /// Runs [action] and rethrows [AppException]s, wrapping any other error as
  /// a [NetworkException].
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }
}
