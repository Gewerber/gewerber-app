import 'package:gewerber_app/domain/entities/business.dart';

/// Contract for business operations used by the application layer.
///
/// Implementations live in the infrastructure layer and must never leak
/// framework or transport details into the domain.
abstract interface class BusinessRepository {
  /// Lists all businesses the signed-in user belongs to.
  Future<List<Business>> listMine();

  /// Creates a new business on behalf of the signed-in user.
  Future<Business> create({
    required String name,
    LegalForm legalForm,
    bool isKleinunternehmer,
    String? vatId,
    String? email,
    String? phone,
    Address? address,
    BusinessLocale locale,
    BusinessCurrency currency,
  });

  /// Updates an existing business.
  Future<Business> update(Business business);
}
