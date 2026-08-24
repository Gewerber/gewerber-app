import 'package:flutter_test/flutter_test.dart';

import 'package:gewerber_app/domain/entities/dashboard.dart';
import 'package:gewerber_app/domain/repositories/dashboard_repository.dart';
import 'package:gewerber_app/infrastructure/repositories/mock_dashboard_repository.dart';

void main() {
  final repository = MockDashboardRepository();

  test('produces identical summaries for the same anchor', () async {
    final anchor = DateTime(2026, 8, 24, 9, 30);
    final first = await repository.summary(months: 6, anchor: anchor);
    final second = await repository.summary(months: 6, anchor: anchor);

    expect(first.months, second.months);
    expect(first.activity, second.activity);
    expect(first.receivables, second.receivables);
    expect(first.generatedAt, second.generatedAt);
  });

  test('shifts the trend window with the anchor', () async {
    final august = await repository.monthlyFinancials(
      months: 2,
      anchor: DateTime(2026, 8, 24),
    );
    final january = await repository.monthlyFinancials(
      months: 2,
      anchor: DateTime(2026, 1, 15),
    );

    expect(august.last.monthStart, DateTime(2026, 8, 1));
    expect(january.first.monthStart, DateTime(2025, 12, 1));
  });

  test(
    'activity feed is sorted newest first and capped by the limit',
    () async {
      final activity = await repository.recentActivity(
        limit: 3,
        anchor: DateTime(2026, 8, 24),
      );

      expect(activity, hasLength(3));
      for (var i = 1; i < activity.length; i++) {
        expect(
          activity[i - 1].at.isAfter(activity[i].at),
          isTrue,
          reason: 'feed must be ordered newest first',
        );
      }
      // The full mock feed has six items.
      expect(
        await repository.recentActivity(
          limit: DashboardRepository.defaultActivityLimit,
        ),
        hasLength(6),
      );
    },
  );
}
