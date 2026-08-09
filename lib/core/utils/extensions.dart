/// Common Dart extensions used across layers.
library;

extension CapitalizeExtension on String {
  /// Returns a copy of this string with the first letter uppercased.
  String get capitalizeFirst =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);
}
