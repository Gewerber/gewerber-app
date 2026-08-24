import 'package:equatable/equatable.dart';

import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/document.dart';

/// View status of the business documents list.
enum DocumentsViewStatus { initial, loading, loaded, failure }

/// State of the documents overview (list + upload + download).
class DocumentsState extends Equatable {
  const DocumentsState({
    this.status = DocumentsViewStatus.initial,
    this.failure,
    this.documents = const [],
    this.isUploading = false,
  });

  final DocumentsViewStatus status;
  final Failure? failure;
  final List<BusinessDocument> documents;

  /// Whether an upload is currently in flight.
  final bool isUploading;

  bool get isLoading => status == DocumentsViewStatus.loading;

  DocumentsState copyWith({
    DocumentsViewStatus? status,
    Failure? failure,
    List<BusinessDocument>? documents,
    bool? isUploading,
    bool clearFailure = false,
  }) {
    return DocumentsState(
      status: status ?? this.status,
      failure: clearFailure ? null : (failure ?? this.failure),
      documents: documents ?? this.documents,
      isUploading: isUploading ?? this.isUploading,
    );
  }

  @override
  List<Object?> get props => [status, failure, documents, isUploading];
}
