import 'package:flutter/material.dart';

import 'package:gewerber_app/presentation/widgets/forms/field_info_icon.dart';

/// A form-field label with an optional inline info icon.
///
/// Use this for controls that have no built-in label slot — such as
/// [DropdownButtonFormField] when the label is rendered above the control,
/// [SwitchListTile], or [SegmentedButton] — so they can participate in the
/// field-hint system the same way [CustomTextField] does via its decoration.
///
/// The [label] text and the [FieldInfoIcon] sit on one line. When [infoText]
/// is null the widget renders just the label text. No extra semantics node is
/// added — the plain [Text] already announces itself and the icon carries its
/// own accessible name, avoiding double announcements.
class FieldLabel extends StatelessWidget {
  const FieldLabel({
    super.key,
    required this.label,
    this.infoText,
    this.longInfoText,
    this.semanticLabel,
  });

  /// The visible field label text.
  final String label;

  /// Short hint text for the info icon; when null no icon is shown.
  final String? infoText;

  /// Optional extended explanation surfaced by the info icon's detail sheet.
  final String? longInfoText;

  /// Tooltip and semantics label for the info icon; falls back to [infoText].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Flexible so long localized labels wrap instead of overflowing on
        // narrow screens; the info icon always keeps its space.
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (infoText != null) ...[
          const SizedBox(width: 4),
          FieldInfoIcon(
            infoText: infoText!,
            longInfoText: longInfoText,
            semanticLabel: semanticLabel,
          ),
        ],
      ],
    );
  }
}
