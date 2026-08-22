import 'package:flutter/material.dart';

import 'package:gewerber_app/presentation/screens/home/widgets/about_content.dart';

/// AboutScreen — version, licenses and legal information.
///
/// Thin route wrapper around [AboutContent] (shared with the desktop settings
/// master-detail pane).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AboutContent();
  }
}
