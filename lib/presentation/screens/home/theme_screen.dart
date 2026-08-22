import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/theme_selector.dart';

/// ThemeScreen — pick between system, light and dark appearance.
///
/// Thin route wrapper around [ThemeSelector] (shared with the desktop settings
/// master-detail pane).
class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).themeTitle)),
      body: const ThemeSelector(),
    );
  }
}
