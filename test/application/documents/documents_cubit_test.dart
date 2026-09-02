import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/application/documents/documents_cubit.dart';
import 'package:gewerber_app/application/documents/documents_state.dart';
import 'package:gewerber_app/core/errors/failures.dart';
import 'package:gewerber_app/core/errors/exceptions.dart';
import 'package:gewerber_app/domain/entities/document.dart';
import 'package:gewerber_app/domain/repositories/document_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_document_repository.dart';
import 'package:gewerber_app/infrastructure/services/file_picker_service.dart';

class _FakeFilePickerService implements FilePickerService {
  _FakeFilePickerService({this.result});

  PickedFileAttachment? result;
  int callCount = 0;

  @override
  Future<PickedFileAttachment?> pickSingle({
    List<String>? allowedExtensions,
  }) async {
    callCount++;
    return result;
  }
}

void main() {
  test('starts in the initial state', () {
    final cubit = DocumentsCubit(
      MockDocumentRepository(),
      _FakeFilePickerService(),
    );

    expect(cubit.state.status, DocumentsViewStatus.initial);
    expect(cubit.state.documents, isEmpty);
  });

  test('load populates the document list', () async {
    final repository = MockDocumentRepository();
    await repository.upload(
      businessId: 1,
      file: const PickedFileAttachment(
        fileName: 'receipt.pdf',
        bytes: [1, 2, 3],
      ),
      kind: DocumentKind.receipt,
    );
    final cubit = DocumentsCubit(repository, _FakeFilePickerService());

    await cubit.load();

    expect(cubit.state.status, DocumentsViewStatus.loaded);
    expect(cubit.state.documents.single.fileName, 'receipt.pdf');
  });

  test('upload stores the document and prepends it to the list', () async {
    final repository = MockDocumentRepository();
    final cubit = DocumentsCubit(repository, _FakeFilePickerService());
    await cubit.load();
    await repository.upload(
      businessId: 1,
      file: const PickedFileAttachment(fileName: 'old.png', bytes: [1]),
    );
    await cubit.load();

    final uploaded = await cubit.upload(
      businessId: 1,
      file: PickedFileAttachment(fileName: 'new.pdf', bytes: [9, 9]),
      kind: DocumentKind.attachment,
    );

    expect(uploaded, isNotNull);
    expect(uploaded!.fileName, 'new.pdf');
    // Newest first.
    expect(cubit.state.documents.first.fileName, 'new.pdf');
    expect(cubit.state.isUploading, isFalse);
  });

  test(
    'upload failure keeps the state consistent and reports no document',
    () async {
      final repository = MockDocumentRepository();
      final cubit = DocumentsCubit(repository, _FakeFilePickerService());

      // The mock rejects files above the shared size limit.
      final uploaded = await cubit.upload(
        businessId: 1,
        file: PickedFileAttachment(
          fileName: 'huge.bin',
          bytes: List.filled(documentMaxSizeBytes + 1, 0),
        ),
      );

      expect(uploaded, isNull);
      expect(cubit.state.isUploading, isFalse);
      // The mapped failure is exposed for the UI to surface.
      expect(cubit.state.failure, isA<NetworkFailure>());
    },
  );

  test('pickFile delegates to the picker service without uploading', () async {
    final repository = MockDocumentRepository();
    final picker = _FakeFilePickerService(
      result: const PickedFileAttachment(fileName: 'picked.jpg', bytes: [7]),
    );
    final cubit = DocumentsCubit(repository, picker);

    final picked = await cubit.pickFile();

    expect(picker.callCount, 1);
    expect(picked?.fileName, 'picked.jpg');
    // Nothing leaked into the list.
    expect(repository.list().then((value) => value.length), completion(0));
  });

  test('pickFile returns null when the user cancels', () async {
    final cubit = DocumentsCubit(
      MockDocumentRepository(),
      _FakeFilePickerService(result: null),
    );

    expect(await cubit.pickFile(), isNull);
  });

  test('download returns the stored bytes', () async {
    final repository = MockDocumentRepository();
    final document = await repository.upload(
      businessId: 1,
      file: const PickedFileAttachment(fileName: 'a.txt', bytes: [5, 6]),
    );
    final cubit = DocumentsCubit(repository, _FakeFilePickerService());

    final downloaded = await cubit.download(document);

    expect(downloaded?.bytes, [5, 6]);
    expect(downloaded?.fileName, 'a.txt');
  });

  test('load failure maps to a failure state', () async {
    final cubit = DocumentsCubit(
      _FailingRepository(),
      _FakeFilePickerService(),
    );

    await cubit.load();

    expect(cubit.state.status, DocumentsViewStatus.failure);
    expect(cubit.state.failure, isA<NetworkFailure>());
  });
}

class _FailingRepository implements DocumentRepository {
  @override
  Future<List<BusinessDocument>> list({
    DocumentKind? kind,
    String? relatedEntityType,
    String? relatedEntityId,
    int? limit,
    int? offset,
  }) async => throw const NetworkException('offline');

  @override
  Future<BusinessDocument?> get(int documentId) => throw UnimplementedError();

  @override
  Future<BusinessDocument> upload({
    required int businessId,
    required PickedFileAttachment file,
    DocumentKind kind = DocumentKind.attachment,
    String? relatedEntityType,
    String? relatedEntityId,
  }) => throw UnimplementedError();

  @override
  Future<DownloadedDocument> download(BusinessDocument document) =>
      throw UnimplementedError();

  @override
  Future<void> delete(int documentId) => throw UnimplementedError();
}
