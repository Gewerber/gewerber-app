import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'gewerber_colors.dart';

/// Typography for Gewerber, based on the Brand Book.
///
/// Primary font: Inter. Secondary (mono): Roboto Mono.
/// Both are loaded at runtime via [GoogleFonts] (falls back gracefully to the
/// default font when offline). Weights follow the Brand Book: 400 regular,
/// 500 medium, 600 semibold, 700 bold.
class GewerberTypography {
  GewerberTypography._();

  static TextTheme text([Color? body]) {
    final color = body ?? GewerberColors.text;

    return GoogleFonts.interTextTheme(
      const TextTheme(
        // Display
        displayLarge: TextStyle(
          fontSize: 60,
          height: 1.1,
          letterSpacing: -0.02,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          height: 1.2,
          letterSpacing: -0.01,
        ),
        displaySmall: TextStyle(
          fontSize: 30,
          height: 1.3,
          letterSpacing: 0,
          fontWeight: FontWeight.w600,
        ),
        // Headlines
        headlineLarge: TextStyle(
          fontSize: 24,
          height: 1.4,
          letterSpacing: 0,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          height: 1.4,
          letterSpacing: 0,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          height: 1.5,
          letterSpacing: 0,
          fontWeight: FontWeight.w600,
        ),
        // Titles
        titleLarge: TextStyle(
          fontSize: 18,
          height: 1.5,
          letterSpacing: 0,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          height: 1.5,
          letterSpacing: 0.01,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          height: 1.5,
          letterSpacing: 0.01,
          fontWeight: FontWeight.w500,
        ),
        // Body
        bodyLarge: TextStyle(fontSize: 18, height: 1.6, letterSpacing: 0),
        bodyMedium: TextStyle(fontSize: 16, height: 1.6, letterSpacing: 0),
        bodySmall: TextStyle(fontSize: 14, height: 1.5, letterSpacing: 0.01),
        // Labels
        labelLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          letterSpacing: 0.01,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          letterSpacing: 0.02,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          height: 1.5,
          letterSpacing: 0.03,
          fontWeight: FontWeight.w500,
        ),
      ),
    ).apply(bodyColor: color, displayColor: color);
  }

  /// Monospace style for numbers, invoices and technical data.
  static TextStyle mono({
    double fontSize = 14,
    FontWeight weight = FontWeight.w400,
    double height = 1.5,
  }) {
    return GoogleFonts.robotoMono(
      fontWeight: weight,
      fontSize: fontSize,
      height: height,
      letterSpacing: 0,
    );
  }
}
