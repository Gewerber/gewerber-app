import 'package:gewerber_app/domain/entities/document.dart';

/// Contract for business-document storage operations (list, upload,
/// download) backed by the server's `document` endpoint.
abstract interface class DocumentRepository {
  /// Lists the documents of the active business, newest first.
  ///
  /// [kind], [relatedEntityType] and [relatedEntityId] narrow the result;
  /// [limit] and [offset] page through the server-side list.
  Future<List<BusinessDocument>> list({
    DocumentKind? kind,
    String? relatedEntityType,
    String? relatedEntityId,
    int? limit,
    int? offset,
  });

  /// Uploads [file] for the given [businessId] and returns the stored
  /// document's metadata.
  ///
  /// The server rejects files larger than [documentMaxSizeBytes]; callers
  /// validate the same limit client-side before uploading.
  Future<BusinessDocument> upload({
    required int businessId,
    required PickedFileAttachment file,
    DocumentKind kind = DocumentKind.attachment,
    String? relatedEntityType,
    String? relatedEntityId,
  });

  /// Downloads the bytes of the document.
  Future<DownloadedDocument> download(BusinessDocument document);
}
