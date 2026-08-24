import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// Full-screen blocking notice shown when the server reports that the
/// signed-in account no longer exists.
///
/// The only action is signing out locally so the router returns to the login
/// screen; the dialog cannot be dismissed otherwise.
class AccountDeletedDialog extends StatelessWidget {
  const AccountDeletedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: AlertDialog(
        icon: Icon(Icons.no_accounts_outlined, color: colors.error, size: 32),
        title: Text(l10n.accountDeletedTitle),
        content: Text(l10n.accountDeletedBody),
        actions: [
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<AuthCubit>().logOut();
            },
            child: Text(l10n.accountDeletedSignOut),
          ),
        ],
      ),
    );
  }
}
