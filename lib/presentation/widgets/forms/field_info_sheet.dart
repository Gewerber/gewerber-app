import 'package:flutter/material.dart';

import 'package:gewerber_app/core/theme/gewerber_tokens.dart';

/// Shows an adaptive explanation sheet for a form field.
///
/// On narrow screens (< 900 logical px) a scroll-controlled modal bottom sheet
/// with a drag handle is used; on wide screens a centered dialog. Both are
/// dismissible via the barrier and Esc.
///
/// [body] holds the short hint text, [longBody] the optional extended
/// explanation rendered below it in a muted color. When [onMoreRequested] is
/// provided a trailing text button labelled [moreLabel] is shown, which closes
/// the sheet and invokes the callback.
Future<T?> showFieldInfoSheet<T>({
  required BuildContext context,
  required String title,
  required String body,
  String? longBody,
  VoidCallback? onMoreRequested,
  String? moreLabel,
}) {
  final isWide =
      MediaQuery.sizeOf(context).width >= GewerberTokens.breakpointMedium;

  if (isWide) {
    return showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(GewerberTokens.radiusCard),
          ),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: _FieldInfoContent(
            titleStyle: Theme.of(context).textTheme.titleLarge,
            padding: EdgeInsets.zero,
            title: title,
            body: body,
            longBody: longBody,
            onMoreRequested: onMoreRequested,
            moreLabel: moreLabel,
          ),
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(GewerberTokens.radiusCard),
      ),
    ),
    builder: (context) => _FieldInfoContent(
      titleStyle: Theme.of(context).textTheme.titleMedium,
      padding: const EdgeInsets.fromLTRB(
        GewerberTokens.space24,
        0,
        GewerberTokens.space24,
        GewerberTokens.space24,
      ),
      title: title,
      body: body,
      longBody: longBody,
      onMoreRequested: onMoreRequested,
      moreLabel: moreLabel,
    ),
  );
}

/// Shared title / body / long-body layout for the sheet and dialog variants.
class _FieldInfoContent extends StatelessWidget {
  const _FieldInfoContent({
    required this.titleStyle,
    required this.padding,
    required this.title,
    required this.body,
    required this.longBody,
    required this.onMoreRequested,
    required this.moreLabel,
  });

  final TextStyle? titleStyle;
  final EdgeInsetsGeometry padding;
  final String title;
  final String body;
  final String? longBody;
  final VoidCallback? onMoreRequested;
  final String? moreLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(title, style: titleStyle)),
          const SizedBox(height: GewerberTokens.space16),
          Text(
            body,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurface),
          ),
          if (longBody != null) ...[
            const SizedBox(height: GewerberTokens.space12),
            Text(
              longBody!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
          if (onMoreRequested != null && moreLabel != null) ...[
            const SizedBox(height: GewerberTokens.space8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onMoreRequested!();
                },
                icon: const Icon(Icons.arrow_forward_outlined, size: 18),
                label: Text(moreLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
