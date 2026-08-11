import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/module_placeholder.dart';

/// LanguageScreen — future language picker stub (EN/DE/RU/TR).
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ModulePlaceholder(
      icon: Icons.language_outlined,
      title: l10n.languageTitle,
      subtitle: l10n.moduleComingSoonSubtitle,
    );
  }
}
