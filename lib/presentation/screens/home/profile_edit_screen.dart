import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/profile_form.dart';

/// ProfileEditScreen — edit the signed-in user's profile.
///
/// Thin route wrapper around [ProfileForm] (shared with the desktop settings
/// master-detail pane).
class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).profileTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: const ProfileForm(),
          ),
        ),
      ),
    );
  }
}
