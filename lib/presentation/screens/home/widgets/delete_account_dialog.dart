import 'package:flutter/material.dart';

import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// Confirmation dialog for the irreversible account deletion.
///
/// Returns `true` when the user confirmed the deletion, `false` (or `null`
/// when dismissed) otherwise. The actual deletion is performed by the caller.
class DeleteAccountConfirmDialog extends StatelessWidget {
  const DeleteAccountConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: colors.error,
        size: GewerberTokens.space32,
      ),
      title: Text(l10n.accountDeleteDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.accountDeleteDialogIrreversible),
          const SizedBox(height: GewerberTokens.space16),
          Text(
            l10n.accountDeleteDialogWhatHappens,
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: GewerberTokens.space8),
          _Bullet(text: l10n.accountDeleteDialogBulletAccount),
          _Bullet(text: l10n.accountDeleteDialogBulletPersonal),
          _Bullet(text: l10n.accountDeleteDialogBulletRetention),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.accountDeleteConfirm),
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GewerberTokens.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: GewerberTokens.space2),
            child: Icon(Icons.circle, size: 6, color: colors.onSurfaceVariant),
          ),
          const SizedBox(width: GewerberTokens.space8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
