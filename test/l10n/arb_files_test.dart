import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guard test for the ARB localization files.
///
/// Prevents regressions like the ones the ARB Editor plugin reports:
/// * "Metadata for an undefined key" — an `@key` block without a matching
///   message `key`.
/// * Placeholders (`{name}`) used in a message without being declared in the
///   message metadata with a `type` (String / int / double / num / DateTime).
///
/// Rules enforced (per https://docs.flutter.dev/ui/internationalization):
/// 1. The template file (`app_en.arb`) defines all message keys.
/// 2. Every `@key` metadata must reference an existing message key.
/// 3. Every placeholder `{name}` in a message must be declared in the
///    metadata of that message with a valid `type`.
/// 4. The only allowed top-level (`@@`) attribute is `@@locale`.
/// 5. Translation files (de/ru/tr) must not define their own metadata blocks;
///    they inherit metadata from the template.

const templateFileName = 'app_en.arb';
const translationFileNames = ['app_de.arb', 'app_ru.arb', 'app_tr.arb'];

const validPlaceholderTypes = {'String', 'int', 'double', 'num', 'DateTime'};

// Matches `{email}` and `{count, plural, ...}` — captures the placeholder name.
final placeholderRegex = RegExp(r'\{([a-zA-Z_][a-zA-Z0-9_]*)(?:[,\}])');

String arbPath(String fileName) =>
    '${Directory.current.path}/lib/l10n/$fileName';

void main() {
  group('ARB localization files', () {
    test('template defines valid metadata for every message', () {
      final arb = _loadArb(templateFileName);
      final messages = _messageKeys(arb);
      final metadataKeys = _metadataKeys(arb);

      // Rule 2: every @key references an existing message.
      for (final metadataKey in metadataKeys) {
        expect(
          messages,
          contains(metadataKey),
          reason:
              'Metadata "@$metadataKey" has no message key "$metadataKey". '
              'Add a message with that key, or remove the metadata block.',
        );
      }

      // Rule 3: every placeholder in a message is declared with a type.
      for (final key in messages) {
        final value = arb[key] as String;
        final placeholders = placeholderRegex
            .allMatches(value)
            .map((match) => match.group(1)!)
            .toList();
        if (placeholders.isEmpty) {
          continue;
        }

        final metadata = arb['@$key'];
        expect(
          metadata,
          isNotNull,
          reason:
              'Message "$key" uses placeholder(s) ${placeholders.join(', ')} '
              'but has no metadata block "@$key". Add one with a "placeholders" '
              'section declaring each placeholder and its type.',
        );

        final declaredPlaceholders =
            ((metadata as Map<String, dynamic>)['placeholders']
                as Map<String, dynamic>? ??
            const {});
        for (final placeholder in placeholders) {
          final placeholderMetadata = declaredPlaceholders[placeholder];
          expect(
            placeholderMetadata,
            isNotNull,
            reason:
                'Placeholder "$placeholder" in message "$key" is not '
                'declared in "@$key.placeholders".',
          );

          final type = (placeholderMetadata as Map<String, dynamic>)['type'];
          expect(
            validPlaceholderTypes,
            contains(type),
            reason:
                'Placeholder "$placeholder" in message "$key" must declare '
                'a valid "type" (one of ${validPlaceholderTypes.join(', ')}), '
                'got: $type.',
          );
        }
      }

      // Rule 4: the only allowed @@ attribute is @@locale.
      for (final key in arb.keys) {
        if (key.startsWith('@@')) {
          expect(
            key,
            '@@locale',
            reason:
                '"$key" is not a valid ARB resource attribute. '
                'Only "@@locale" is allowed.',
          );
        }
      }
    });

    test('translation files contain messages but no metadata blocks', () {
      for (final fileName in translationFileNames) {
        final arb = _loadArb(fileName);
        final metadataKeys = _metadataKeys(arb);
        expect(
          metadataKeys,
          isEmpty,
          reason:
              '$fileName must not define metadata (inherited from '
              'template). Remove: ${metadataKeys.map((k) => '@$k').join(', ')}',
        );

        // Translation files must only use @@locale as the top-level attribute.
        for (final key in arb.keys) {
          if (key.startsWith('@@')) {
            expect(
              key,
              '@@locale',
              reason:
                  '"$key" in $fileName is not a valid ARB resource '
                  'attribute.',
            );
          }
        }
      }
    });

    test('template and translation files use the same message keys', () {
      final templateMessages = _messageKeys(_loadArb(templateFileName));
      for (final fileName in translationFileNames) {
        final messages = _messageKeys(_loadArb(fileName));
        expect(
          messages,
          orderedEquals(templateMessages),
          reason:
              '$fileName must contain exactly the same message keys '
              '(same order) as $templateFileName.',
        );
      }
    });
  });
}

Map<String, dynamic> _loadArb(String fileName) {
  final file = File(arbPath(fileName));
  expect(
    file.existsSync(),
    isTrue,
    reason: 'Expected ARB file not found: ${file.path}',
  );
  final content = file.readAsStringSync();
  return json.decode(content) as Map<String, dynamic>;
}

List<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((key) => !key.startsWith('@')).toList(growable: false);

List<String> _metadataKeys(Map<String, dynamic> arb) => arb.keys
    .where((key) => key.startsWith('@') && !key.startsWith('@@'))
    .map((key) => key.substring(1))
    .toList(growable: false);
