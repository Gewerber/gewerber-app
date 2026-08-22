import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/language_selector.dart';

/// LanguageScreen — pick the app language.
///
/// Thin route wrapper around [LanguageSelector] (shared with the desktop
/// settings master-detail pane).
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).languageTitle)),
      body: const LanguageSelector(),
    );
  }
}
