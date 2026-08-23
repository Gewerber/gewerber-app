import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/domain/entities/document.dart';

/// Picks a single file on the device and reads it into memory.
///
/// Abstracted so application-layer code (cubits) stays testable without
/// the platform channel.
abstract interface class FilePickerService {
  /// Opens the picker and returns the picked file, or `null` when the
  /// user cancelled.
  Future<PickedFileAttachment?> pickSingle({List<String>? allowedExtensions});
}

/// [FilePickerService] backed by `package:file_picker`.
@LazySingleton(as: FilePickerService)
class FilePickerServiceImpl implements FilePickerService {
  @override
  Future<PickedFileAttachment?> pickSingle({
    List<String>? allowedExtensions,
  }) async {
    final file = await FilePicker.pickFile(
      type: allowedExtensions == null ? FileType.any : FileType.custom,
      allowedExtensions: allowedExtensions,
    );
    if (file == null) return null;
    return PickedFileAttachment(
      fileName: file.name,
      bytes: await file.readAsBytes(),
      mimeType: _mimeTypeOf(file),
    );
  }

  /// Best-effort MIME type from the picked file; the web implementation
  /// exposes it through the underlying XFile.
  String? _mimeTypeOf(PlatformFile file) {
    if (!kIsWeb) return null;
    try {
      return file.xFile.mimeType;
    } catch (_) {
      return null;
    }
  }
}
