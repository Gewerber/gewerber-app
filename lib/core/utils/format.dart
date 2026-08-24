/// Formatting helpers shared by the invoicing, time tracking and accounting
/// modules.
///
/// Currency and date formatting is locale-aware via `package:intl`. The
/// default locale is German (`de_DE`) — the product's primary market. The
/// settings cubit keeps [Intl.defaultLocale] in sync with the app language.
library;

import 'package:intl/intl.dart';

/// Locale used when neither an explicit locale nor [Intl.defaultLocale] is
/// available (e.g. plain unit tests).
const String defaultFormatLocale = 'de_DE';

String _resolveLocale(String? locale) =>
    locale ?? Intl.defaultLocale ?? defaultFormatLocale;

/// Formats an amount in cents as a localized euro string.
///
/// With the default German locale: `123450` → `1.234,50 €`.
String formatCents(int cents, {String? locale}) {
  return NumberFormat.currency(
    locale: _resolveLocale(locale),
    symbol: '€',
    decimalDigits: 2,
  ).format(cents / 100);
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

/// Formats a date for display, e.g. `22.08.2026` in the default German
/// locale.
String formatDate(DateTime date, {String? locale}) {
  return DateFormat.yMd(_resolveLocale(locale)).format(date);
}

/// Formats a date machine-readably as `YYYY-MM-DD`, independent of the app
/// language. Use it for file names, exports and other technical contexts.
String formatDateIso(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

/// Formats a time of day as `HH:mm`.
String formatTime(DateTime date, {String? locale}) {
  return DateFormat('HH:mm', _resolveLocale(locale)).format(date);
}

/// Formats a byte count in a compact human-readable form (`512 KB`,
/// `1.2 MB`).
String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) {
    return kb >= 100 ? '${kb.round()} KB' : '${kb.toStringAsFixed(1)} KB';
  }
  final mb = kb / 1024;
  return mb >= 100 ? '${mb.round()} MB' : '${mb.toStringAsFixed(1)} MB';
}
