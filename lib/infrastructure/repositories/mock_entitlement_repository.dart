import 'package:injectable/injectable.dart';

import 'package:gewerber_app/core/config/app_environment.dart';
import 'package:gewerber_app/domain/entities/entitlement.dart';
import 'package:gewerber_app/domain/repositories/entitlement_repository.dart';

/// In-memory [EntitlementRepository] backing the demo experience and widget
/// tests. Returns all open-source features enabled by default.
@LazySingleton(as: EntitlementRepository, env: [AppEnvironment.authMock])
class MockEntitlementRepository implements EntitlementRepository {
  @override
  Future<Entitlements> list() async {
    // Open-source features — closed modules (banking, tax, employees,
    // subscriptions, aiAssistant, multiCurrency) are intentionally excluded.
    return const Entitlements(
      features: [
        Feature.invoicing,
        Feature.timeTracking,
        Feature.accounting,
        Feature.documents,
        Feature.guidance,
      ],
    );
  }
}
