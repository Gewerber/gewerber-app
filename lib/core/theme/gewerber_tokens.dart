import 'package:flutter/animation.dart';

/// Shared design tokens that are reused across the Gewerber theme.
///
/// Source: Gewerber Brand Book v1.0.
abstract final class GewerberTokens {
  GewerberTokens._();

  // Spacing — 4px grid, components follow 8/12/16/24 rules.
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;

  /// Corner radius — buttons 8px, cards 12px, modals 16px.
  static const double radiusButton = 8;
  static const double radiusCard = 12;
  static const double radiusModal = 16;
  static const double radiusChip = 8;
  static const double radiusField = 8;

  /// Iconography — consistent 24px grid, 2px stroke.
  static const double iconGrid = 24;

  // Motion — durations in ms, curves matched to Material 3 feel.
  /// Hover/press feedback.
  static const Duration motionFast = Duration(milliseconds: 120);

  /// Chips, small reveals.
  static const Duration motionBase = Duration(milliseconds: 200);

  /// Sheets, dialogs, page-level transitions.
  static const Duration motionSlow = Duration(milliseconds: 300);

  static const Curve motionCurve = Curves.easeOutCubic;

  // Elevation — cards rest at 0 (bordered), hover +2, overlay +4.
  static const double elevationRest = 0;
  static const double elevationHover = 2;
  static const double elevationOverlay = 4;

  // Layout breakpoints — logical px.
  /// Phone → master-detail switches.
  static const double breakpointCompact = 600;

  /// Bottom nav → navigation rail, sheets → dialogs.
  static const double breakpointMedium = 900;

  /// Rail → extended rail.
  static const double breakpointExpanded = 1400;

  // Touch targets.
  static const double minTouchTarget = 48;
}
