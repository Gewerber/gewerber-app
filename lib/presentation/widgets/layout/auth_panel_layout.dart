import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gewerber_app/application/settings/app_settings_cubit.dart';
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
///
/// The content-pane header carries the appearance actions (language and
/// color-scheme switchers) so every pre-auth screen offers them through one
/// shared implementation; both act on the global [AppSettingsCubit], exactly
/// like the post-login settings screens.
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
                  const Spacer(),
                  const _AppearanceActions(),
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

/// Language and color-scheme switchers for the pre-auth screens.
///
/// Both menus act on the global [AppSettingsCubit] (the same state the
/// post-login settings screens use), so a choice made before signing in is
/// reflected everywhere and persisted.
class _AppearanceActions extends StatelessWidget {
  const _AppearanceActions();

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n(context);
    final state = context.watch<AppSettingsCubit>().state;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton<Locale?>(
          tooltip: l10n.languageTitle,
          icon: const Icon(Icons.language_outlined),
          onSelected: (locale) => locale == null
              ? context.read<AppSettingsCubit>().useSystemLocale()
              : context.read<AppSettingsCubit>().setLocale(locale),
          itemBuilder: (_) => [
            _languageItem(
              context,
              value: null,
              title: l10n.languageSystemDefault,
              selected: state.isActiveLocale(null),
            ),
            const PopupMenuDivider(),
            for (final (locale, name) in const [
              (Locale('en'), 'English'),
              (Locale('de'), 'Deutsch'),
              (Locale('ru'), 'Русский'),
              (Locale('tr'), 'Türkçe'),
            ])
              _languageItem(
                context,
                value: locale,
                title: name,
                selected: state.isActiveLocale(locale),
              ),
          ],
        ),
        PopupMenuButton<ThemeMode>(
          tooltip: l10n.themeTitle,
          icon: Icon(switch (state.themeMode) {
            ThemeMode.system => Icons.brightness_auto_outlined,
            ThemeMode.light => Icons.light_mode_outlined,
            ThemeMode.dark => Icons.dark_mode_outlined,
          }),
          onSelected: (mode) =>
              context.read<AppSettingsCubit>().setThemeMode(mode),
          itemBuilder: (_) => [
            _themeItem(
              context,
              mode: ThemeMode.system,
              icon: Icons.brightness_auto_outlined,
              title: l10n.themeSystem,
              selected: state.isSystemTheme,
            ),
            _themeItem(
              context,
              mode: ThemeMode.light,
              icon: Icons.light_mode_outlined,
              title: l10n.themeLight,
              selected: state.isLightTheme,
            ),
            _themeItem(
              context,
              mode: ThemeMode.dark,
              icon: Icons.dark_mode_outlined,
              title: l10n.themeDark,
              selected: state.isDarkTheme,
            ),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<Locale?> _languageItem(
    BuildContext context, {
    required Locale? value,
    required String title,
    required bool selected,
  }) {
    return PopupMenuItem<Locale?>(
      value: value,
      child: _MenuEntry(title: title, selected: selected),
    );
  }

  PopupMenuItem<ThemeMode> _themeItem(
    BuildContext context, {
    required ThemeMode mode,
    required IconData icon,
    required String title,
    required bool selected,
  }) {
    return PopupMenuItem<ThemeMode>(
      value: mode,
      child: _MenuEntry(title: title, icon: icon, selected: selected),
    );
  }
}

/// One selectable row inside an appearance menu (icon + label + check mark).
class _MenuEntry extends StatelessWidget {
  const _MenuEntry({required this.title, required this.selected, this.icon});

  final String title;
  final IconData? icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
            color: selected ? colors.primary : colors.onSurfaceVariant,
          ),
          const SizedBox(width: GewerberTokens.space12),
        ],
        Expanded(child: Text(title)),
        if (selected)
          Icon(Icons.check, size: 20, color: colors.primary)
        else
          Icon(Icons.radio_button_unchecked, size: 20, color: colors.outline),
      ],
    );
  }
}

AppLocalizations _l10n(BuildContext context) => AppLocalizations.of(context);
