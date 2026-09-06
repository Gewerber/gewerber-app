import 'package:flutter/material.dart';

/// Gewerber brand color palette.
///
/// Source: `.github/brand/colors/colors.dart` (Gewerber Brand Book v1.1
/// (contrast revision 2026-09)). Text/UI tokens meet WCAG AA (>= 4.5:1) on
/// both the white surface and the #F5F7FA background; see
/// `test/core/theme/contrast_test.dart`.
class GewerberColors {
  GewerberColors._();

  /// Primary brand color - Gewerber Blue.
  /// Trust, stability, clarity.
  static const Color primary = Color(0xFF2D6CDF);
  static const Color primaryHover = Color(0xFF1D5BC4);
  static const Color primaryLight = Color(0xFFE8F0FD);
  static const Color primaryDark = Color(0xFF1A4AA3);

  /// Accent color - Gewerber Mint.
  /// Freshness, modernity, friendliness.
  static const Color accent = Color(0xFF4CD4A9);
  static const Color accentHover = Color(0xFF38C496);
  static const Color accentLight = Color(0xFFE8FAF3);
  static const Color accentDark = Color(0xFF1D9570);

  /// Neutral colors.
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE1E5EB);

  /// Text colors.
  static const Color text = Color(0xFF1F2A33);
  static const Color textSecondary = Color(0xFF5A6A78);
  static const Color textMuted = Color(0xFF64707E);
  static const Color textInverse = Color(0xFFFFFFFF);

  /// Semantic colors.
  static const Color error = Color(0xFFCC3333);
  static const Color errorLight = Color(0xFFFDEAEA);
  static const Color errorDark = Color(0xFFB12222);

  static const Color success = Color(0xFF187F4F);
  static const Color successLight = Color(0xFFE8F7EE);
  static const Color successDark = Color(0xFF157347);

  static const Color warning = Color(0xFF996200);
  static const Color warningLight = Color(0xFFFFF4E6);
  static const Color warningDark = Color(0xFF7A4E00);

  static const Color info = Color(0xFF2D6CDF);
  static const Color infoLight = Color(0xFFE8F0FD);
  static const Color infoDark = Color(0xFF1A4AA3);

  /// MaterialColor swatches for ThemeData.
  static const MaterialColor primarySwatch =
      MaterialColor(0xFF2D6CDF, <int, Color>{
        50: Color(0xFFE8F0FD),
        100: Color(0xFFD1E1FA),
        200: Color(0xFFA3C3F5),
        300: Color(0xFF75A5F0),
        400: Color(0xFF4D88EB),
        500: Color(0xFF2D6CDF),
        600: Color(0xFF2862CE),
        700: Color(0xFF2257BD),
        800: Color(0xFF1D4DAB),
        900: Color(0xFF153A93),
      });

  static const MaterialColor accentSwatch =
      MaterialColor(0xFF4CD4A9, <int, Color>{
        50: Color(0xFFE8FAF3),
        100: Color(0xFFD1F5E7),
        200: Color(0xFFA3EBD0),
        300: Color(0xFF75E1B9),
        400: Color(0xFF4DD7A1),
        500: Color(0xFF4CD4A9),
        600: Color(0xFF43BF99),
        700: Color(0xFF39A986),
        800: Color(0xFF309474),
        900: Color(0xFF23745A),
      });

  static const MaterialColor errorSwatch =
      MaterialColor(0xFFCC3333, <int, Color>{
        50: Color(0xFFFDEAEA),
        100: Color(0xFFFBD5D5),
        200: Color(0xFFF7ABA8),
        300: Color(0xFFEF6A64),
        400: Color(0xFFE04A46),
        500: Color(0xFFCC3333),
        600: Color(0xFFC02C2C),
        700: Color(0xFFB42525),
        800: Color(0xFFA81E1E),
        900: Color(0xFF991515),
      });

  static const MaterialColor successSwatch =
      MaterialColor(0xFF187F4F, <int, Color>{
        50: Color(0xFFE8F7EE),
        100: Color(0xFFD1EFDD),
        200: Color(0xFFA3DFBC),
        300: Color(0xFF5CB885),
        400: Color(0xFF33A366),
        500: Color(0xFF187F4F),
        600: Color(0xFF16784A),
        700: Color(0xFF146F44),
        800: Color(0xFF12653D),
        900: Color(0xFF0F5234),
      });
}
