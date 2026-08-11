import 'package:flutter/material.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/module_placeholder.dart';

/// BusinessProfileScreen — future business profile form stub (name, address,
/// Kleinunternehmer §19 toggle).
class BusinessProfileScreen extends StatelessWidget {
  const BusinessProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ModulePlaceholder(
      icon: Icons.storefront_outlined,
      title: l10n.businessProfileTitle,
      subtitle: l10n.businessProfileSubtitle,
    );
  }
}
