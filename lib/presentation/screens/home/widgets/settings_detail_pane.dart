import 'package:flutter/material.dart';

import 'package:gewerber_app/presentation/screens/home/settings_master_detail.dart'
    show SettingsSection;
import 'package:gewerber_app/presentation/screens/home/widgets/about_content.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/business_profile_form.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/business_settings_form.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/guidance_index.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/language_selector.dart'
    show LanguageSelector;
import 'package:gewerber_app/presentation/screens/home/widgets/profile_form.dart';
import 'package:gewerber_app/presentation/screens/home/widgets/theme_selector.dart';

/// SettingsDetailPane — detail pane for settings master-detail layout.
class SettingsDetailPane extends StatelessWidget {
  const SettingsDetailPane({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _buildDetailContent(context),
    );
  }

  Widget _buildDetailContent(BuildContext context) {
    final section = selectedIndex < SettingsSection.values.length
        ? SettingsSection.values[selectedIndex]
        : null;
    return switch (section) {
      SettingsSection.profile => const _DetailContainer(
        key: ValueKey('profile'),
        child: ProfileForm(),
      ),
      SettingsSection.businessProfile => const _DetailContainer(
        key: ValueKey('business_profile'),
        child: BusinessProfileForm(),
      ),
      SettingsSection.businessSettings => const _DetailContainer(
        key: ValueKey('business_settings'),
        child: BusinessSettingsForm(),
      ),
      SettingsSection.language => const _DetailContainer(
        key: ValueKey('language'),
        child: LanguageSelector(),
      ),
      SettingsSection.theme => const _DetailContainer(
        key: ValueKey('theme'),
        child: ThemeSelector(),
      ),
      SettingsSection.guides => const _DetailContainer(
        key: ValueKey('guides'),
        child: GuidanceIndex(),
      ),
      SettingsSection.about => const _DetailContainer(
        key: ValueKey('about'),
        child: AboutContent(),
      ),
      // Sign-out index or anything out of range.
      null => const _DetailContainer(
        key: ValueKey('default'),
        child: ProfileForm(),
      ),
    };
  }
}

class _DetailContainer extends StatelessWidget {
  const _DetailContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Padding(padding: const EdgeInsets.all(24), child: child),
    );
  }
}
