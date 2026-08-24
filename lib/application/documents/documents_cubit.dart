import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/application/documents/documents_state.dart';
import 'package:gewerber_app/core/errors/error_handler.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/domain/entities/document.dart';
import 'package:gewerber_app/domain/repositories/document_repository.dart';
import 'package:gewerber_app/infrastructure/services/file_picker_service.dart';

/// Owns the business documents: list, upload (via the device file picker)
/// and download. Also serves the receipt-attachment flow of the accounting
/// module.
@LazySingleton()
class DocumentsCubit extends Cubit<DocumentsState> {
  DocumentsCubit(this._repository, this._pickerService)
    : super(const DocumentsState());

  final DocumentRepository _repository;
  final FilePickerService _pickerService;

  /// Loads the documents of the active business.
  Future<void> load({DocumentKind? kind}) async {
    if (state.isLoading) return;
    emit(
      state.copyWith(status: DocumentsViewStatus.loading, clearFailure: true),
    );
    try {
      final documents = await _repository.list(limit: 100);
      if (isClosed) return;
      final visible = kind == null
          ? documents
          : documents.where((document) => document.kind == kind).toList();
      emit(
        DocumentsState(status: DocumentsViewStatus.loaded, documents: visible),
      );
    } on AppException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: DocumentsViewStatus.failure,
          failure: mapAppException(e),
        ),
      );
    } on Exception {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: DocumentsViewStatus.failure,
          failure: const NetworkFailure(),
        ),
      );
    }
  }

  /// Fetches a single document by id, or `null` when it does not exist or
  /// the lookup fails. Used to resolve e.g. the file name of a receipt
  /// attached to a transaction.
  Future<BusinessDocument?> getById(int documentId) async {
    try {
      return await _repository.get(documentId);
    } on Exception {
      return null;
    }
  }

  /// Opens the device file picker and returns the picked file without
  /// uploading it. Callers decide whether to keep (receipt attachment) or
  /// upload ([upload]) the result.
  Future<PickedFileAttachment?> pickFile({List<String>? allowedExtensions}) {
    return _pickerService.pickSingle(allowedExtensions: allowedExtensions);
  }

  /// Uploads [file] for the active business and prepends the resulting
  /// document to the list.
  ///
  /// Returns the stored document, or `null` on failure (the mapped
  /// [Failure] is exposed via the state).
  Future<BusinessDocument?> upload({
    required int businessId,
    required PickedFileAttachment file,
    DocumentKind kind = DocumentKind.attachment,
    String? relatedEntityType,
    String? relatedEntityId,
  }) async {
    if (state.isUploading) return null;
    emit(state.copyWith(isUploading: true, clearFailure: true));
    try {
      final document = await _repository.upload(
        businessId: businessId,
        file: file,
        kind: kind,
        relatedEntityType: relatedEntityType,
        relatedEntityId: relatedEntityId,
      );
      if (!isClosed) {
        emit(
          state.copyWith(
            isUploading: false,
            status: DocumentsViewStatus.loaded,
            documents: [document, ...state.documents],
          ),
        );
      }
      return document;
    } on AppException catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isUploading: false, failure: mapAppException(e)));
      }
      return null;
    } on Exception {
      if (!isClosed) {
        emit(state.copyWith(isUploading: false));
      }
      return null;
    }
  }

  /// Downloads the bytes of [document]. Returns `null` on failure.
  Future<DownloadedDocument?> download(BusinessDocument document) async {
    try {
      return await _repository.download(document);
    } on Exception {
      return null;
    }
  }
}
