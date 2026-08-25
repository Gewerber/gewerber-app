/// Calendar-month arithmetic shared by dashboard trends and period reports.
///
/// All values use the **local** wall clock, consistent with how the app
/// builds report periods (see `DashboardScreen` and the accounting module).
/// Server timestamps arrive in UTC; comparing them against these local
/// bounds relies on the absolute-time comparison of `DateTime`, which is
/// correct across time zones.
library;

/// First day of the month containing [date], at midnight (local time).
DateTime monthStart(DateTime date) => DateTime(date.year, date.month);

/// Last day of the month containing [date], at end of day (inclusive upper
/// bound for closed reporting periods).
DateTime monthEnd(DateTime date) =>
    DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);

/// Closed reporting range `[start, end]` of the month that is [offset]
/// months away from the month of [anchor].
///
/// `offset: 0` is the anchor's own month, `-1` the previous one, and so on.
(DateTime start, DateTime end) monthRange(DateTime anchor, int offset) {
  final start = DateTime(anchor.year, anchor.month + offset);
  return (start, monthEnd(start));
}

/// Starts of the last [count] months including the month of [anchor],
/// oldest first.
List<DateTime> lastNMonthStarts(DateTime anchor, int count) {
  return [
    for (var i = -count + 1; i <= 0; i++)
      DateTime(anchor.year, anchor.month + i),
  ];
}
