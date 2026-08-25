import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/presentation/widgets/dashboard/profit_change.dart';

// Locale pinned to `en` so the percent formatting is deterministic.
void main() {
  MonthlyFinancials month(int monthNumber, int incomeCents, int expenseCents) =>
      MonthlyFinancials(
        monthStart: DateTime(2026, monthNumber),
        incomeCents: incomeCents,
        expenseCents: expenseCents,
      );

  group('profitChangePercent', () {
    test('returns null with fewer than two months', () {
      expect(profitChangePercent([month(5, 100000, 60000)], 'en'), isNull);
    });

    test('returns null when the base month has zero profit', () {
      final months = [month(5, 60000, 60000), month(6, 100000, 60000)];
      expect(profitChangePercent(months, 'en'), isNull);
    });

    test('prefixes an increase with a plus sign', () {
      // Profit rises from 40 000 to 70 000 cents (+75 %).
      final months = [month(5, 100000, 60000), month(6, 120000, 50000)];
      expect(profitChangePercent(months, 'en'), '+75%');
    });

    test('keeps the minus sign of a decrease', () {
      // Profit falls from 50 000 to 45 000 cents (-10 %).
      final months = [month(5, 100000, 50000), month(6, 100000, 55000)];
      expect(profitChangePercent(months, 'en'), '-10%');
    });

    test('renders a zero change unsigned and neutral-ready', () {
      // Profit stays at 100 000 cents.
      final months = [month(5, 150000, 50000), month(6, 160000, 60000)];
      expect(profitChangePercent(months, 'en'), '0%');
    });
  });

  group('changeTone', () {
    test('classifies formatted changes by sign', () {
      expect(changeTone('+12%'), ChangeTone.positive);
      expect(changeTone('-5%'), ChangeTone.negative);
      expect(changeTone('0%'), ChangeTone.neutral);
    });
  });
}
