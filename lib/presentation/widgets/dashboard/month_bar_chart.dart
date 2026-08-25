import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:gewerber_app/core/theme/gewerber_colors.dart';
import 'package:gewerber_app/core/theme/gewerber_tokens.dart';
import 'package:gewerber_app/core/utils/format.dart';
import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// Paired income/expense bar chart of the monthly trend.
///
/// Renders one pair of columns (income = primary blue, expense = accent
/// mint) per month with short month names underneath, and exposes a textual
/// summary for screen readers. Optionally shows a 6M/12M window switcher
/// above the plot when [onWindowChanged] is provided.
class MonthBarChart extends StatelessWidget {
  const MonthBarChart({
    super.key,
    required this.months,
    this.windowMonths,
    this.onWindowChanged,
  });

  /// Monthly totals, oldest first.
  final List<MonthlyFinancials> months;

  /// Currently selected window size; renders the switcher when
  /// [onWindowChanged] is set as well.
  final int? windowMonths;

  final ValueChanged<int>? onWindowChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onWindowChanged != null && windowMonths != null) ...[
          Align(
            alignment: Alignment.centerRight,
            child: _WindowSwitcher(
              windowMonths: windowMonths!,
              onWindowChanged: onWindowChanged!,
            ),
          ),
          const SizedBox(height: GewerberTokens.space8),
        ],
        Semantics(
          label: _semanticsSummary(context, locale),
          child: ExcludeSemantics(
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: CustomPaint(
                painter: _MonthBarChartPainter(
                  months: months,
                  monthLabels: [
                    for (final month in months)
                      DateFormat.MMM(locale).format(month.monthStart),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: GewerberTokens.space8),
        Row(
          children: [
            _LegendDot(color: GewerberColors.primary, label: l10n.reportIncome),
            const SizedBox(width: GewerberTokens.space12),
            _LegendDot(
              color: GewerberColors.accentDark,
              label: l10n.reportExpenses,
            ),
          ],
        ),
      ],
    );
  }

  /// Textual summary of the plotted data for assistive technologies.
  String _semanticsSummary(BuildContext context, String locale) {
    final l10n = AppLocalizations.of(context);
    if (months.isEmpty) return l10n.dashboardTrendsEmpty;
    return [
      for (final month in months)
        '${DateFormat.MMM(locale).format(month.monthStart)}: '
            '${l10n.reportIncome} ${formatCents(month.incomeCents)}, '
            '${l10n.reportExpenses} ${formatCents(month.expenseCents)}',
    ].join('; ');
  }
}

/// Small 6M / 12M segmented control above the chart. The labels are
/// language-neutral unit-style abbreviations ("M" for month).
class _WindowSwitcher extends StatelessWidget {
  const _WindowSwitcher({
    required this.windowMonths,
    required this.onWindowChanged,
  });

  final int windowMonths;
  final ValueChanged<int> onWindowChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<int>(
      showSelectedIcon: false,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      segments: const [
        ButtonSegment(value: 6, label: Text('6M')),
        ButtonSegment(value: 12, label: Text('12M')),
      ],
      selected: {windowMonths},
      onSelectionChanged: (selection) => onWindowChanged(selection.first),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: GewerberTokens.space4),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Paints paired rounded bars per month with a baseline and month labels.
class _MonthBarChartPainter extends CustomPainter {
  _MonthBarChartPainter({required this.months, required this.monthLabels});

  /// Monthly totals, oldest first.
  final List<MonthlyFinancials> months;

  /// Short display name per entry of [months], e.g. `Aug`.
  final List<String> monthLabels;

  static const double _pairGap = 3; // gap between the income/expense bars
  static const double _groupGap = 10; // gap between month groups
  static const double _labelHeight = 16;
  static const double _barRadius = 2.5;
  static const double _minVisibleBarHeight = 3;

  @override
  void paint(Canvas canvas, Size size) {
    if (months.isEmpty) return;

    final plotBottom = size.height - _labelHeight;
    final maxValue = months.fold<int>(0, (max, month) {
      return [
        max,
        month.incomeCents,
        month.expenseCents,
      ].reduce((a, b) => a > b ? a : b);
    });

    _paintBaseline(canvas, size.width, plotBottom);
    if (maxValue <= 0) return;

    final groupWidth =
        (size.width - _groupGap * (months.length - 1)) / months.length;
    final barWidth = ((groupWidth - _pairGap) / 2).clamp(4.0, 22.0);

    final incomePaint = Paint()..color = GewerberColors.primary;
    final expensePaint = Paint()..color = GewerberColors.accentDark;

    var x = 0.0;
    for (final (index, month) in months.indexed) {
      // Center the pair within its group slot so narrow bars stay centered
      // on wide layouts.
      final pairWidth = barWidth * 2 + _pairGap;
      final startX = x + (groupWidth - pairWidth) / 2;

      _drawBar(
        canvas,
        centerX: startX,
        width: barWidth,
        height: _barHeight(month.incomeCents, maxValue, plotBottom),
        bottom: plotBottom,
        paint: incomePaint,
      );
      _drawBar(
        canvas,
        centerX: startX + barWidth + _pairGap,
        width: barWidth,
        height: _barHeight(month.expenseCents, maxValue, plotBottom),
        bottom: plotBottom,
        paint: expensePaint,
      );

      _paintMonthLabel(canvas, monthLabels[index], x, groupWidth, plotBottom);

      x += groupWidth + _groupGap;
    }
  }

  /// Scaled bar height with a small visible stub for non-zero values so a
  /// quiet month stays recognizable.
  double _barHeight(int valueCents, int maxValue, double plotBottom) {
    if (valueCents <= 0) return 0;
    final scaled = plotBottom * valueCents / maxValue;
    return scaled.clamp(_minVisibleBarHeight, plotBottom);
  }

  void _drawBar(
    Canvas canvas, {
    required double centerX,
    required double width,
    required double height,
    required double bottom,
    required Paint paint,
  }) {
    if (height <= 0) return;
    final rect = Rect.fromLTWH(centerX, bottom - height, width, height);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(_barRadius),
        topRight: const Radius.circular(_barRadius),
      ),
      paint,
    );
  }

  void _paintBaseline(Canvas canvas, double width, double y) {
    final paint = Paint()
      ..color = GewerberColors.border
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, y), Offset(width, y), paint);
  }

  void _paintMonthLabel(
    Canvas canvas,
    String label,
    double groupStart,
    double groupWidth,
    double plotBottom,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 10,
          height: 1,
          color: GewerberColors.textSecondary,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout(maxWidth: groupWidth);
    textPainter.paint(
      canvas,
      Offset(groupStart + (groupWidth - textPainter.width) / 2, plotBottom + 5),
    );
  }

  @override
  bool shouldRepaint(_MonthBarChartPainter oldDelegate) =>
      oldDelegate.months != months || oldDelegate.monthLabels != monthLabels;
}
