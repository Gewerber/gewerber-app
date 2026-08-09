import 'package:flutter/material.dart';

/// Gewerber brand color palette.
///
/// Source: `.github/brand/colors/colors.dart` (Gewerber Brand Book v1.0).
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
  static const Color accentDark = Color(0xFF2DB387);

  /// Neutral colors.
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE1E5EB);

  /// Text colors.
  static const Color text = Color(0xFF1F2A33);
  static const Color textSecondary = Color(0xFF5A6A78);
  static const Color textMuted = Color(0xFF9AA5B1);
  static const Color textInverse = Color(0xFFFFFFFF);

  /// Semantic colors.
  static const Color error = Color(0xFFE54848);
  static const Color errorLight = Color(0xFFFDEAEA);
  static const Color errorDark = Color(0xFFC43A3A);

  static const Color success = Color(0xFF3BB273);
  static const Color successLight = Color(0xFFE8F7EE);
  static const Color successDark = Color(0xFF2D8F5A);

  static const Color warning = Color(0xFFF5A623);
  static const Color warningLight = Color(0xFFFFF4E6);
  static const Color warningDark = Color(0xFFD48F1A);

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
      MaterialColor(0xFFE54848, <int, Color>{
        50: Color(0xFFFDEAEA),
        100: Color(0xFFFBD5D5),
        200: Color(0xFFF7ABA8),
        300: Color(0xFFF3807B),
        400: Color(0xFFEE554E),
        500: Color(0xFFE54848),
        600: Color(0xFFD93D3D),
        700: Color(0xFFCC3030),
        800: Color(0xFFBF2525),
        900: Color(0xFFAD1212),
      });

  static const MaterialColor successSwatch =
      MaterialColor(0xFF3BB273, <int, Color>{
        50: Color(0xFFE8F7EE),
        100: Color(0xFFD1EFDD),
        200: Color(0xFFA3DFBC),
        300: Color(0xFF75CF9B),
        400: Color(0xFF4DC07A),
        500: Color(0xFF3BB273),
        600: Color(0xFF35A069),
        700: Color(0xFF2D8C5C),
        800: Color(0xFF267950),
        900: Color(0xFF1B5D3E),
      });
}
