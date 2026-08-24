import 'package:intl/intl.dart';

import 'package:gewerber_app/domain/entities/dashboard.dart';

/// Signed month-over-month change of the profit (e.g. `+12 %`, `-5 %`),
/// or `null` when it cannot be computed (fewer than two months or a zero
/// base month).
String? profitChangePercent(List<MonthlyFinancials> months, String locale) {
  if (months.length < 2) return null;
  final previous = months[months.length - 2].profitCents;
  final current = months.last.profitCents;
  // Undefined relative change when the base is zero.
  if (previous == 0) return null;

  final ratio = (current - previous) / previous.abs();
  final sign = ratio >= 0 ? '+' : '';
  return '$sign${NumberFormat.percentPattern(locale).format(ratio)}';
}
