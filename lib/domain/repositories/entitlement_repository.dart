import 'package:gewerber_app/domain/entities/entitlement.dart';

/// Contract for fetching the feature entitlements of the active business.
abstract interface class EntitlementRepository {
  /// Returns the entitlements for the current business context.
  Future<Entitlements> list();
}
