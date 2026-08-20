import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/presentation/widgets/brand/brand_logo.dart';

/// Desktop breakpoint above which the two-column brand + form layout applies.
const double _authBreakpoint = 900;

/// Responsive scaffold for authentication screens.
///
/// On wide windows a two-column layout is used: a calm brand panel
/// (gradient, tagline, trust points) on the left and the [child] — usually
/// the auth card — centered on the right. Below the breakpoint the screens
/// stack with the brand header on top.
class AuthPanelLayout extends StatelessWidget {
  const AuthPanelLayout({
    super.key,
    this.showBackButton = true,
    this.onBack,
    required this.child,
  });

  /// Whether a back button is shown (mobile layout only).
  final bool showBackButton;

  /// Optional custom action for the header back button — used by multi-step
  /// flows to step back within the flow instead of popping the route.
  final VoidCallback? onBack;

  /// The form content to render.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= _authBreakpoint;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (wide)
                _BrandPanel(
                  tagline: _l10n(context).tagline,
                  trustPoints: [
                    _TrustPoint(Icons.bolt, _l10n(context).panelTrustCreate),
                    _TrustPoint(
                      Icons.description_outlined,
                      _l10n(context).panelTrustInvoices,
                    ),
                    _TrustPoint(
                      Icons.gavel_outlined,
                      _l10n(context).panelTrustTax,
                    ),
                    _TrustPoint(
                      Icons.code,
                      _l10n(context).panelTrustOpenSource,
                    ),
                  ],
                ),
              Expanded(
                child: _ContentPane(
                  showBackButton: showBackButton,
                  onBack: onBack,
                  child: child,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ContentPane extends StatelessWidget {
  const _ContentPane({
    required this.child,
    required this.showBackButton,
    this.onBack,
  });

  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colors.surfaceContainerLow,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(GewerberTokens.space16),
              child: Row(
                children: [
                  if (showBackButton && (onBack != null || context.canPop()))
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: _l10n(context).commonBack,
                      onPressed: onBack ?? () => context.pop(),
                    ),
                  const _BrandMark(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(GewerberTokens.space24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.tagline, required this.trustPoints});

  final String tagline;
  final List<_TrustPoint> trustPoints;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              GewerberColors.primaryDark,
              GewerberColors.primary,
              GewerberColors.accentDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: GewerberTokens.space48,
              vertical: GewerberTokens.space64,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _BrandMark(inverse: true, foreground: Colors.white),
                const SizedBox(height: GewerberTokens.space40),
                Text(
                  tagline,
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: GewerberTokens.space32),
                for (final point in trustPoints) ...[
                  _TrustRow(point),
                  const SizedBox(height: GewerberTokens.space12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustPoint {
  const _TrustPoint(this.icon, this.text);

  final IconData icon;
  final String text;
}

class _TrustRow extends StatelessWidget {
  const _TrustRow(this.point);

  final _TrustPoint point;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(point.icon, size: 20, color: Colors.white),
        const SizedBox(width: GewerberTokens.space12),
        Expanded(
          child: Text(
            point.text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ),
      ],
    );
  }
}

/// Small brand logo used in headers and panels.
class _BrandMark extends StatelessWidget {
  const _BrandMark({this.inverse = false, this.foreground});

  final bool inverse;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final foreground = this.foreground ?? (inverse ? colors.onPrimary : null);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandLogo(size: 32, color: foreground),
        const SizedBox(width: GewerberTokens.space8),
        Text(
          'Gewerber',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: foreground ?? colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

AppLocalizations _l10n(BuildContext context) => AppLocalizations.of(context);
