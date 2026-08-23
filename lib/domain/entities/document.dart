import 'package:equatable/equatable.dart';

/// Kind of a stored business document, mirroring the server's
/// `DocumentKind` enum.
enum DocumentKind {
  invoicePdf,
  receipt,
  logo,
  attachment,
  other;

  static DocumentKind fromName(String name) {
    return DocumentKind.values.firstWhere(
      (value) => value.name == name,
      orElse: () => DocumentKind.attachment,
    );
  }
}

/// Metadata of a file stored for the business (invoice PDFs, receipts,
/// logos, arbitrary attachments).
class BusinessDocument extends Equatable {
  const BusinessDocument({
    required this.id,
    required this.businessId,
    required this.fileName,
    required this.storagePath,
    this.kind = DocumentKind.attachment,
    this.mimeType,
    this.sizeBytes,
    this.relatedEntityType,
    this.relatedEntityId,
    this.createdAt,
  });

  /// Stable server-side identifier.
  final int id;

  /// Owning business (tenant) of the document.
  final int businessId;

  /// Original file name including the extension.
  final String fileName;
  final DocumentKind kind;
  final String? mimeType;

  /// Size in bytes, when reported by the server.
  final int? sizeBytes;

  /// Server-side storage path (opaque to the client).
  final String storagePath;

  /// What the document belongs to, e.g. `invoice` / `accounting_transaction`.
  final String? relatedEntityType;
  final String? relatedEntityId;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    businessId,
    fileName,
    kind,
    mimeType,
    sizeBytes,
    storagePath,
    relatedEntityType,
    relatedEntityId,
    createdAt,
  ];
}

/// A file picked on the device, ready to be uploaded.
class PickedFileAttachment extends Equatable {
  const PickedFileAttachment({
    required this.fileName,
    required this.bytes,
    this.mimeType,
  });

  final String fileName;
  final String? mimeType;
  final List<int> bytes;

  int get sizeBytes => bytes.length;

  @override
  List<Object?> get props => [fileName, mimeType, sizeBytes];
}

/// Bytes of a downloaded document together with its file name, ready to
/// be handed to the platform's save/download mechanism.
class DownloadedDocument extends Equatable {
  const DownloadedDocument({
    required this.documentId,
    required this.fileName,
    required this.bytes,
  });

  final int documentId;
  final String fileName;
  final List<int> bytes;

  @override
  List<Object?> get props => [documentId, fileName, bytes.length];
}

/// Uploads larger than this are rejected by the server; the client
/// validates the same limit before even picking/uploading.
const int documentMaxSizeBytes = 512 * 1024;
