/// Formatting helpers shared by the invoicing, time tracking and accounting
/// modules.
library;

/// Formats an amount in cents as a simple euro string (e.g. `1200` → `12.00 €`).
String formatCents(int cents) {
  final euros = cents ~/ 100;
  final rest = (cents % 100).abs().toString().padLeft(2, '0');
  final sign = cents < 0 ? '-' : '';
  return '$sign$euros.$rest €';
}

/// Parses a decimal euro input (e.g. `12,50` or `12.50`) into cents.
///
/// Returns `null` when the input is not a valid non-negative amount.
int? parseEuroInput(String input) {
  final normalized = input.trim().replaceAll(',', '.').replaceAll('€', '');
  if (normalized.isEmpty) return null;
  final value = double.tryParse(normalized);
  if (value == null || value < 0) return null;
  return (value * 100).round();
}

/// Formats a duration in minutes as `2h 05m` / `45m`.
String formatMinutes(int minutes) {
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  if (hours == 0) return '${rest}m';
  return '${hours}h ${rest.toString().padLeft(2, '0')}m';
}

/// Formats a date as `YYYY-MM-DD`.
String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

/// Formats a time of day as `HH:mm`.
String formatTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';
}
