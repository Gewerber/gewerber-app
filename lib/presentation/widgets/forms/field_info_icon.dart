import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/widgets/forms/field_info_sheet.dart';

/// Small info icon rendered next to a form-field label to surface a hint.
///
/// Part of the field-hint system that explains German tax terminology
/// (e.g. USt-IdNr., Kleinunternehmer §19) inline where it is asked for.
///
/// The icon always carries a tooltip ([semanticLabel] ?? [infoText]), which
/// closes the common a11y gap of an unlabeled icon button. The tooltip is
/// tap-triggered, so touch users get the short hint on tap while desktop
/// hover works out of the box. When [longInfoText] is set, a tap additionally
/// opens an adaptive explanation sheet via [showFieldInfoSheet].
class FieldInfoIcon extends StatelessWidget {
  const FieldInfoIcon({
    super.key,
    required this.infoText,
    this.longInfoText,
    this.semanticLabel,
    this.sheetTitle,
    this.color,
    this.onLongInfoRequested,
  });

  /// Short hint text; also used as the tooltip and, unless [sheetTitle] is
  /// given, as the detail-sheet title.
  final String infoText;

  /// Optional extended explanation. When set, a tap opens the info sheet.
  final String? longInfoText;

  /// Tooltip and semantics label; falls back to [infoText].
  final String? semanticLabel;

  /// Optional title for the detail sheet; defaults to [infoText].
  final String? sheetTitle;

  /// Icon tint; defaults to the theme's primary color (contrast 4.86:1).
  final Color? color;

  /// Called from the sheet's "more" action to request further details.
  final VoidCallback? onLongInfoRequested;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = semanticLabel ?? infoText;
    final hasSheet = longInfoText != null;

    return Semantics(
      // The Tooltip's own semantics would leave the button unnamed for
      // screen readers (it only sets the `tooltip` property), so the
      // accessible name and description are provided explicitly here.
      label: label,
      tooltip: label,
      button: true,
      child: Tooltip(
        message: label,
        // Tap reveals the hint for touch users, hover for pointer users.
        // When a detail sheet is present the tap opens it and the modal
        // barrier dismisses the tooltip, so the two never stack.
        triggerMode: TooltipTriggerMode.tap,
        child: IconButton(
          onPressed: () {
            if (!hasSheet) return;
            showFieldInfoSheet<void>(
              context: context,
              title: sheetTitle ?? infoText,
              body: infoText,
              longBody: longInfoText,
              // The trailing "more" action deep-links into the guidance
              // system; its label comes from l10n so callers don't have to
              // pass it through every layer.
              onMoreRequested: onLongInfoRequested,
              moreLabel: onLongInfoRequested != null
                  ? AppLocalizations.of(context).fieldInfoMore
                  : null,
            );
          },
          icon: const Icon(Icons.info_outline),
          color: color ?? theme.colorScheme.primary,
          iconSize: 20,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
      ),
    );
  }
}
