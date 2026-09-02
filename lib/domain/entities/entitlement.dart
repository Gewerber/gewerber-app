import 'package:equatable/equatable.dart';

/// Domain-level feature flag mirroring the server's [Feature] enum.
///
/// Values use camelCase (Dart convention) while the SDK uses snake_case.
/// [fromName] normalises both forms so mapping is straightforward.
enum Feature {
  invoicing,
  timeTracking,
  accounting,
  documents,
  guidance,
  banking,
  tax,
  employees,
  subscriptions,
  aiAssistant,
  multiCurrency;

  /// Creates a [Feature] from either camelCase or snake_case [name].
  ///
  /// Falls back to [invoicing] when the name is unknown so callers never
  /// crash on an unexpected value from the server.
  static Feature fromName(String name) {
    return Feature.values.firstWhere(
      (f) => f.name == name || f.name == _toSnakeCase(name),
      orElse: () => Feature.invoicing,
    );
  }

  static String _toSnakeCase(String input) {
    // Insert an underscore before each uppercase letter, lowercase everything.
    return input
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (m) => '_${m.group(0)!.toLowerCase()}',
        )
        .replaceFirst(RegExp(r'^_'), '');
  }
}

/// Immutable snapshot of the features enabled for a business.
class Entitlements extends Equatable {
  const Entitlements({required this.features});

  /// The features the current business is entitled to use.
  final List<Feature> features;

  /// Whether [feature] is enabled.
  bool isEnabled(Feature feature) => features.contains(feature);

  /// Convenience: all enabled features.
  List<Feature> get enabled => features;

  @override
  List<Object?> get props => [features];
}
