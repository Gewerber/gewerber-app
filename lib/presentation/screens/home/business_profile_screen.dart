import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/business_profile_form.dart';

/// BusinessProfileScreen — edit the active business's profile.
///
/// Thin route wrapper around [BusinessProfileForm] (shared with the desktop
/// settings master-detail pane).
class BusinessProfileScreen extends StatelessWidget {
  const BusinessProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).businessProfileTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: const BusinessProfileForm(),
          ),
        ),
      ),
    );
  }
}
