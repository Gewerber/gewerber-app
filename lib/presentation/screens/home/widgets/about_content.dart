import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gewerber_app/core/config/app_info.dart';
import 'package:gewerber_app/core/theme/gewerber_tokens.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/widgets/brand/brand_logo.dart';

/// AboutContent — app version, legal links and open-source licenses.
///
/// Shared between the mobile [AboutScreen] route and the desktop settings
/// master-detail pane.
class AboutContent extends StatelessWidget {
  const AboutContent({super.key});

  Future<void> _open(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Exception {
      // Opening the browser can fail (e.g. blocked popups); nothing sensible
      // to do about it here.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(GewerberTokens.space16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(GewerberTokens.space24),
            child: Column(
              children: [
                const BrandLogo(size: 56),
                const SizedBox(height: GewerberTokens.space12),
                Text(
                  l10n.aboutTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: GewerberTokens.space8),
                Text(
                  l10n.aboutSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: GewerberTokens.space12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GewerberTokens.space8,
                    vertical: GewerberTokens.space4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      GewerberTokens.radiusChip,
                    ),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Text(
                    '${l10n.aboutVersionLabel} ${AppInfo.version}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: GewerberTokens.space12),
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.aboutWebsite),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => _open(AppInfo.website),
              ),
              Divider(height: 1, color: colors.outlineVariant),
              ListTile(
                leading: const Icon(Icons.receipt_outlined),
                title: Text(l10n.aboutImprint),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => _open(AppInfo.imprint),
              ),
              Divider(height: 1, color: colors.outlineVariant),
              ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: Text(l10n.aboutPrivacy),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => _open(AppInfo.privacy),
              ),
              Divider(height: 1, color: colors.outlineVariant),
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: Text(l10n.aboutLicenses),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Gewerber',
                  applicationVersion: AppInfo.version,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
