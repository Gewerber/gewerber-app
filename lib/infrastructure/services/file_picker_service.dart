import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:mime/mime.dart';

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

  /// Best-effort MIME type from the picked file.
  ///
  /// On web the underlying XFile carries the MIME type reported by the
  /// browser; on all other platforms it is derived from the file name
  /// (falling back to the full path) via `package:mime`.
  String? _mimeTypeOf(PlatformFile file) {
    if (kIsWeb) {
      try {
        return file.xFile.mimeType;
      } catch (_) {
        return null;
      }
    }
    return mimeTypeFromNameAndPath(name: file.name, path: file.path);
  }

  /// Pure MIME lookup for non-web platforms: resolves the type from the
  /// file name first, then from the path as a fallback. Exposed for unit
  /// testing — the platform-conditional in [_mimeTypeOf] cannot be tested
  /// without the platform channel.
  @visibleForTesting
  static String? mimeTypeFromNameAndPath({String? name, String? path}) {
    if (name != null && name.isNotEmpty) {
      final fromName = lookupMimeType(name);
      if (fromName != null) return fromName;
    }
    if (path != null && path.isNotEmpty) {
      return lookupMimeType(path);
    }
    return null;
  }
}
