import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/core/theme/gewerber_colors.dart';

/// WCAG 2.1 relative luminance of an sRGB color.
///
/// Each 8-bit channel is normalized to [0, 1] and linearized
/// (gamma expansion), then combined per the WCAG coefficients
/// `L = 0.2126 R + 0.7152 G + 0.0722 B`.
double relativeLuminance(Color color) {
  double linearize(int channel) {
    final s = channel / 255.0;
    return s <= 0.04045
        ? s / 12.92
        : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = linearize((color.r * 255.0).round());
  final g = linearize((color.g * 255.0).round());
  final b = linearize((color.b * 255.0).round());
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// WCAG 2.1 contrast ratio between two opaque colors:
/// `(L_lighter + 0.05) / (L_darker + 0.05)`, range 1.0 – 21.0.
double contrastRatio(Color a, Color b) {
  final la = relativeLuminance(a);
  final lb = relativeLuminance(b);
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

/// The two light surfaces text/UI colors must work on:
/// the white card surface and the app background.
const List<({String name, Color color})> lightSurfaces = [
  (name: 'surface #FFFFFF', color: Color(0xFFFFFFFF)),
  (name: 'background #F5F7FA', color: Color(0xFFF5F7FA)),
];

/// Asserts [color] reaches at least [minRatio] against every light surface.
void expectContrastOnLightSurfaces(String label, Color color, double minRatio) {
  for (final surface in lightSurfaces) {
    final ratio = contrastRatio(color, surface.color);
    expect(
      ratio,
      greaterThanOrEqualTo(minRatio),
      reason:
          '$label on ${surface.name}: contrast '
          '${ratio.toStringAsFixed(2)}:1 is below the required '
          '${minRatio.toStringAsFixed(1)}:1',
    );
  }
}

void main() {
  group('WCAG contrast specification (Brand Book v1.1)', () {
    // Text tokens: WCAG AA normal text requires >= 4.5:1.

    test('success passes AA as text (trend badges "+x %")', () {
      expectContrastOnLightSurfaces('success', GewerberColors.success, 4.5);
    });

    test('warning passes AA as text (warning messages)', () {
      expectContrastOnLightSurfaces('warning', GewerberColors.warning, 4.5);
    });

    test('textMuted passes AA as secondary text', () {
      expectContrastOnLightSurfaces('textMuted', GewerberColors.textMuted, 4.5);
    });

    test('error passes AA as error text', () {
      expectContrastOnLightSurfaces('error', GewerberColors.error, 4.5);
    });

    // UI graphics (expense bars, accent strips): WCAG AA non-text requires
    // >= 3:1.
    test('accentDark passes AA as UI graphics', () {
      expectContrastOnLightSurfaces(
        'accentDark',
        GewerberColors.accentDark,
        3.0,
      );
    });

    // Regression protection: these tokens already pass and must keep passing.
    test('textSecondary passes AA as text', () {
      expectContrastOnLightSurfaces(
        'textSecondary',
        GewerberColors.textSecondary,
        4.5,
      );
    });

    test('text passes AA as text', () {
      expectContrastOnLightSurfaces('text', GewerberColors.text, 4.5);
    });

    test('primary passes AA as text', () {
      expectContrastOnLightSurfaces('primary', GewerberColors.primary, 4.5);
    });
  });
}
