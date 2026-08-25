import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/infrastructure/services/file_picker_service.dart';

void main() {
  // The pure non-web MIME lookup is tested directly; the platform-conditional
  // in FilePickerServiceImpl._mimeTypeOf cannot be exercised without the
  // platform channel.
  group('FilePickerServiceImpl.mimeTypeFromNameAndPath', () {
    test('resolves known extensions from the file name', () {
      expect(
        FilePickerServiceImpl.mimeTypeFromNameAndPath(name: 'receipt.pdf'),
        'application/pdf',
      );
      expect(
        FilePickerServiceImpl.mimeTypeFromNameAndPath(name: 'logo.png'),
        'image/png',
      );
    });

    test('resolves extensions regardless of letter case', () {
      // package:mime lowercases the extension before table lookup.
      expect(
        FilePickerServiceImpl.mimeTypeFromNameAndPath(name: 'RECEIPT.PDF'),
        'application/pdf',
      );
    });

    test('resolves the extension after multiple dots in the name', () {
      // Only the segment after the last dot is treated as the extension.
      expect(
        FilePickerServiceImpl.mimeTypeFromNameAndPath(name: 'a.b.v2.pdf'),
        'application/pdf',
      );
    });

    test('falls back to the path when the name is omitted', () {
      expect(
        FilePickerServiceImpl.mimeTypeFromNameAndPath(
          path: '/tmp/receipts/invoice.pdf',
        ),
        'application/pdf',
      );
    });

    test('falls back to the path when the name yields no match', () {
      expect(
        FilePickerServiceImpl.mimeTypeFromNameAndPath(
          name: 'noext',
          path: '/tmp/receipts/invoice.pdf',
        ),
        'application/pdf',
      );
    });

    test('returns null for unknown extensions', () {
      expect(
        FilePickerServiceImpl.mimeTypeFromNameAndPath(
          name: 'archive.unknownext',
          path: '/tmp/archive.unknownext',
        ),
        isNull,
      );
    });

    test('returns null when both name and path are missing', () {
      expect(FilePickerServiceImpl.mimeTypeFromNameAndPath(), isNull);
      expect(FilePickerServiceImpl.mimeTypeFromNameAndPath(name: ''), isNull);
      expect(FilePickerServiceImpl.mimeTypeFromNameAndPath(path: ''), isNull);
    });
  });
}
