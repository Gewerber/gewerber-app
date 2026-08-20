import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'gewerber_colors.dart';
import 'gewerber_tokens.dart';
import 'gewerber_typography.dart';

/// Builds the Gewerber Material 3 theme for both light and dark mode.
///
/// Colors derive from the Brand Book palette, radii and spacing follow
/// [GewerberTokens], and typography uses [GewerberTypography].
abstract final class GewerberTheme {
  GewerberTheme._();

  static ThemeData light() {
    final colorScheme = const ColorScheme.light(
      primary: GewerberColors.primary,
      onPrimary: GewerberColors.textInverse,
      primaryContainer: GewerberColors.primaryLight,
      onPrimaryContainer: GewerberColors.primaryDark,
      secondary: GewerberColors.accentDark,
      onSecondary: GewerberColors.textInverse,
      secondaryContainer: GewerberColors.accentLight,
      onSecondaryContainer: GewerberColors.accentDark,
      tertiary: GewerberColors.accent,
      onTertiary: GewerberColors.text,
      error: GewerberColors.error,
      onError: GewerberColors.textInverse,
      errorContainer: GewerberColors.errorLight,
      onErrorContainer: GewerberColors.errorDark,
      outline: GewerberColors.border,
      surface: GewerberColors.surface,
      onSurface: GewerberColors.text,
      surfaceContainerLowest: GewerberColors.surface,
      surfaceContainerLow: GewerberColors.background,
      surfaceContainerHighest: GewerberColors.border,
      onSurfaceVariant: GewerberColors.textSecondary,
    );

    return _build(colorScheme, isDark: false);
  }

  static ThemeData dark() {
    final colorScheme = const ColorScheme.dark(
      primary: Color(0xFF7BA7F0),
      onPrimary: Color(0xFF0A1E42),
      primaryContainer: Color(0xFF1A4AA3),
      onPrimaryContainer: Color(0xFFD1E1FA),
      secondary: Color(0xFF4CD4A9),
      onSecondary: Color(0xFF0A2B1F),
      secondaryContainer: Color(0xFF2DB387),
      onSecondaryContainer: Color(0xFFE8FAF3),
      tertiary: Color(0xFF4CD4A9),
      onTertiary: Color(0xFF0A2B1F),
      error: Color(0xFFF08080),
      onError: Color(0xFF3A0A0A),
      errorContainer: Color(0xFFC43A3A),
      onErrorContainer: Color(0xFFFDEAEA),
      outline: Color(0xFF2A3540),
      surface: Color(0xFF151A1F),
      onSurface: Color(0xFFE6EBF0),
      surfaceContainerLowest: Color(0xFF101417),
      surfaceContainerLow: Color(0xFF151A1F),
      surfaceContainerHighest: Color(0xFF1F2A33),
      onSurfaceVariant: Color(0xFFB6C0CA),
    );

    return _build(colorScheme, isDark: true);
  }

  static ThemeData _build(ColorScheme colorScheme, {required bool isDark}) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    final textTheme = GewerberTypography.text(colorScheme.onSurface);

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surfaceContainerLow,
      canvasColor: colorScheme.surface,
      dividerColor: colorScheme.outline.withValues(alpha: 0.6),
      splashFactory: InkSparkle.splashFactory,
      // Screen transitions: keep the platform feel on mobile, but no
      // animated page transitions on desktop/web.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: _NoTransitionsPageTransitionsBuilder(),
          TargetPlatform.macOS: _NoTransitionsPageTransitionsBuilder(),
          TargetPlatform.linux: _NoTransitionsPageTransitionsBuilder(),
        },
      ),
      // Buttons — 8px radius (Brand Book §8)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withValues(
            alpha: 0.12,
          ),
          disabledForegroundColor: colorScheme.onSurface.withValues(
            alpha: 0.38,
          ),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GewerberTokens.radiusButton),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GewerberTokens.radiusButton),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GewerberTokens.radiusButton),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GewerberTokens.radiusButton * 2),
        ),
      ),
      // Cards — 12px radius (Brand Book §8)
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GewerberTokens.radiusCard),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
        ),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      // Inputs — 8px radius
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GewerberTokens.radiusField),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GewerberTokens.radiusField),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GewerberTokens.radiusField),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GewerberTokens.radiusField),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GewerberTokens.radiusField),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GewerberTokens.radiusChip),
        ),
        side: BorderSide(color: colorScheme.outline),
        selectedColor: colorScheme.primaryContainer,
        labelStyle: textTheme.labelMedium!.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      // Navigation bar — calm, minimalistic
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium!.copyWith(
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium!.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GewerberTokens.radiusCard),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(GewerberTokens.radiusModal),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GewerberTokens.radiusModal),
        ),
        titleTextStyle: textTheme.titleLarge!.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium!.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Page transition that swaps screens instantly — used on desktop platforms
/// where animated route transitions feel out of place.
class _NoTransitionsPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
