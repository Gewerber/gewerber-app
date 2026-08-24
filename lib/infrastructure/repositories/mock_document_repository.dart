import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/document.dart';
import 'package:gewerber_app/domain/repositories/document_repository.dart';

/// In-memory [DocumentRepository] backing the demo experience and the
/// widget tests. Data lives for the app session only.
@LazySingleton(as: DocumentRepository, env: [AppEnvironment.authMock])
class MockDocumentRepository implements DocumentRepository {
  final List<BusinessDocument> _documents = [];
  final Map<int, List<int>> _bytesById = {};
  int _nextId = 1;

  /// Clears all stored documents (used by tests to isolate scenarios).
  void reset() {
    _documents.clear();
    _bytesById.clear();
    _nextId = 1;
  }

  @override
  Future<BusinessDocument?> get(int documentId) async {
    for (final document in _documents) {
      if (document.id == documentId) return document;
    }
    return null;
  }

  @override
  Future<List<BusinessDocument>> list({
    DocumentKind? kind,
    String? relatedEntityType,
    String? relatedEntityId,
    int? limit,
    int? offset,
  }) async {
    final result =
        _documents
            .where(
              (document) =>
                  (kind == null || document.kind == kind) &&
                  (relatedEntityType == null ||
                      document.relatedEntityType == relatedEntityType) &&
                  (relatedEntityId == null ||
                      document.relatedEntityId == relatedEntityId),
            )
            .toList()
          ..sort(
            (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
              a.createdAt ?? DateTime.now(),
            ),
          );
    final start = offset ?? 0;
    return result.skip(start).take(limit ?? result.length).toList();
  }

  @override
  Future<BusinessDocument> upload({
    required int businessId,
    required PickedFileAttachment file,
    DocumentKind kind = DocumentKind.attachment,
    String? relatedEntityType,
    String? relatedEntityId,
  }) async {
    if (file.sizeBytes > documentMaxSizeBytes) {
      // Mirror the server-side rejection of oversized files.
      throw const NetworkException('File exceeds the upload size limit');
    }
    final document = BusinessDocument(
      id: _nextId++,
      businessId: businessId,
      fileName: file.fileName,
      kind: kind,
      mimeType: file.mimeType,
      sizeBytes: file.sizeBytes,
      storagePath: 'mock/${file.fileName}',
      relatedEntityType: relatedEntityType,
      relatedEntityId: relatedEntityId,
      createdAt: DateTime.now(),
    );
    _documents.add(document);
    _bytesById[document.id] = List<int>.from(file.bytes);
    return document;
  }

  @override
  Future<DownloadedDocument> download(BusinessDocument document) async {
    final bytes = _bytesById[document.id];
    if (bytes == null) throw StateError('Unknown document ${document.id}');
    return DownloadedDocument(
      documentId: document.id,
      fileName: document.fileName,
      bytes: bytes,
    );
  }
}
