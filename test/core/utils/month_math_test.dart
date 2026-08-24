import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/core/utils/month_math.dart';

void main() {
  group('monthStart', () {
    test('returns the first day of the month at midnight', () {
      final result = monthStart(DateTime(2026, 8, 24, 14, 30));
      expect(result, DateTime(2026, 8, 1));
    });
  });

  group('monthEnd', () {
    test('returns the last day of the month at end of day', () {
      final result = monthEnd(DateTime(2026, 8, 3));
      expect(result.day, 31);
      expect(result.hour, 23);
      expect(result.minute, 59);
    });

    test('handles short months and year boundaries', () {
      expect(monthEnd(DateTime(2026, 2, 10)).day, 28);
      expect(monthEnd(DateTime(2028, 2, 10)).day, 29); // leap year
      expect(monthEnd(DateTime(2026, 12, 5)).day, 31);
    });
  });

  group('monthRange', () {
    test('offset 0 covers the anchor month', () {
      final (start, end) = monthRange(DateTime(2026, 8, 24), 0);
      expect(start, DateTime(2026, 8, 1));
      expect(end.day, 31);
    });

    test('negative offsets step back across the year boundary', () {
      final (start, end) = monthRange(DateTime(2026, 1, 15), -1);
      expect(start, DateTime(2025, 12, 1));
      expect(end, DateTime(2025, 12, 31, 23, 59, 59, 999));

      final (janStart, _) = monthRange(DateTime(2026, 3, 2), -2);
      expect(janStart, DateTime(2026, 1, 1));
    });
  });

  group('lastNMonthStarts', () {
    test('returns count starts including the anchor month, oldest first', () {
      final starts = lastNMonthStarts(DateTime(2026, 8, 24), 6);
      expect(starts, hasLength(6));
      expect(starts.first, DateTime(2026, 3, 1));
      expect(starts.last, DateTime(2026, 8, 1));
    });

    test('wraps across years', () {
      final starts = lastNMonthStarts(DateTime(2026, 2, 1), 4);
      expect(starts.map((d) => '${d.year}-${d.month}'), [
        '2025-11',
        '2025-12',
        '2026-1',
        '2026-2',
      ]);
    });

    test('count of 1 yields only the anchor month', () {
      final starts = lastNMonthStarts(DateTime(2026, 8, 24), 1);
      expect(starts, [DateTime(2026, 8, 1)]);
    });
  });
}
